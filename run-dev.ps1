[CmdletBinding()]
param(
    [string]$HostAddress = "127.0.0.1",
    [int]$BackendPort = 8000,
    [int]$FrontendPort = 3000,
    [string]$Python = "python",
    [string]$DatabaseUrl = "",
    [switch]$InstallDeps,
    [switch]$StartDatabase,
    [switch]$SkipDatabase,
    [switch]$SkipSchemaInit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) {
    $RepoRoot = (Get-Location).Path
}

$FrontendDir = Join-Path $RepoRoot "frontend"
$RequirementsFile = Join-Path $RepoRoot "requirements.txt"
if (-not (Test-Path -LiteralPath $RequirementsFile)) {
    $RequirementsFile = Join-Path $RepoRoot "backend\requirements.txt"
}

if (-not $DatabaseUrl) {
    $DatabaseUrl = $env:DATABASE_URL
}

if (-not $DatabaseUrl) {
    $DatabaseUrl = "postgresql://cipher_user:cipher_password@localhost:5433/cipher_db"
}

$env:DATABASE_URL = $DatabaseUrl

function Quote-PowerShellString {
    param([Parameter(Mandatory = $true)][string]$Value)

    return "'" + $Value.Replace("'", "''") + "'"
}

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found on PATH."
    }
}

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Command,
        [Parameter(Mandatory = $true)][string]$FailureMessage
    )

    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw $FailureMessage
    }
}

function Stop-ProcessTree {
    param([Parameter(Mandatory = $true)][int]$RootProcessId)

    $children = Get-CimInstance Win32_Process `
        -Filter "ParentProcessId = $RootProcessId" `
        -ErrorAction SilentlyContinue

    foreach ($child in $children) {
        Stop-ProcessTree -RootProcessId ([int]$child.ProcessId)
    }

    Stop-Process -Id $RootProcessId -Force -ErrorAction SilentlyContinue
}

function Invoke-InRepoRoot {
    param([Parameter(Mandatory = $true)][scriptblock]$Command)

    Push-Location $RepoRoot
    try {
        & $Command
    } finally {
        Pop-Location
    }
}

function Test-BackendDatabaseConnection {
    & $Python -c "from backend.database import check_database_connection; raise SystemExit(0 if check_database_connection() else 1)" 2>$null
    return $LASTEXITCODE -eq 0
}

function Wait-BackendDatabase {
    param([int]$TimeoutSeconds = 60)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        if (Test-BackendDatabaseConnection) {
            return
        }

        Start-Sleep -Seconds 2
    }

    throw "Timed out waiting for the backend database at '$DatabaseUrl'."
}

function Initialize-BackendSchema {
    Invoke-InRepoRoot {
        & $Python -c "from backend.database import engine; from backend.models import Base; Base.metadata.create_all(bind=engine)"
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Database schema initialization failed."
    }
}

function Get-PowerShellHostPath {
    $currentProcess = Get-Process -Id $PID

    if ($currentProcess.Path -and (Test-Path -LiteralPath $currentProcess.Path)) {
        return $currentProcess.Path
    }

    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwsh) {
        return $pwsh.Source
    }

    return (Get-Command powershell -ErrorAction Stop).Source
}

function Start-DevProcess {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$PowerShellExe
    )

    $encodedCommand = [Convert]::ToBase64String(
        [Text.Encoding]::Unicode.GetBytes($Command)
    )

    Write-Host "Starting $Name..."

    $process = Start-Process `
        -FilePath $PowerShellExe `
        -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-EncodedCommand",
            $encodedCommand
        ) `
        -WorkingDirectory $WorkingDirectory `
        -NoNewWindow `
        -PassThru

    return [PSCustomObject]@{
        Name = $Name
        Process = $process
    }
}

Assert-Command $Python
Assert-Command "npm"

if (-not (Test-Path -LiteralPath $FrontendDir)) {
    throw "Frontend directory was not found at '$FrontendDir'."
}

$ShouldStartDatabase = $StartDatabase -or (-not $SkipDatabase)

if ($ShouldStartDatabase) {
    Assert-Command "docker"
    Invoke-InRepoRoot {
        Invoke-NativeCommand `
            -Command { docker compose up -d postgres } `
            -FailureMessage "Failed to start Postgres with docker compose."
    }
}

if ($InstallDeps) {
    Invoke-NativeCommand `
        -Command { & $Python -m pip install -r $RequirementsFile } `
        -FailureMessage "Backend dependency installation failed."

    Push-Location $FrontendDir
    try {
        Invoke-NativeCommand `
            -Command { npm install } `
            -FailureMessage "Frontend dependency installation failed."
    } finally {
        Pop-Location
    }
} else {
    $NodeModules = Join-Path $FrontendDir "node_modules"
    if (-not (Test-Path -LiteralPath $NodeModules)) {
        Write-Warning "frontend\node_modules is missing. Run '.\run-dev.ps1 -InstallDeps' before starting the app."
    }

    & $Python -c "import bcrypt, fastapi, jwt, psycopg, pydantic, sqlalchemy, uvicorn; import dotenv" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Backend Python packages are missing. Run '.\run-dev.ps1 -InstallDeps' before starting the app."
    }
}

Write-Host "Waiting for database..."
Wait-BackendDatabase

if (-not $SkipSchemaInit) {
    Write-Host "Ensuring database schema exists..."
    Initialize-BackendSchema
}

$ApiBaseUrl = "http://{0}:{1}" -f $HostAddress, $BackendPort
$PowerShellExe = Get-PowerShellHostPath
$PythonCommand = Quote-PowerShellString $Python
$HostCommand = Quote-PowerShellString $HostAddress
$ApiBaseUrlCommand = Quote-PowerShellString $ApiBaseUrl
$DatabaseUrlCommand = Quote-PowerShellString $DatabaseUrl

$BackendCommand = @"
`$env:PYTHONUNBUFFERED = '1'
`$env:DATABASE_URL = $DatabaseUrlCommand
& $PythonCommand -m uvicorn backend.main:app --reload --host $HostCommand --port $BackendPort
"@

$FrontendCommand = @"
`$env:NEXT_PUBLIC_API_BASE_URL = $ApiBaseUrlCommand
npm run dev -- --hostname $HostCommand --port $FrontendPort
"@

$started = @()

try {
    $started += Start-DevProcess `
        -Name "backend" `
        -Command $BackendCommand `
        -WorkingDirectory $RepoRoot `
        -PowerShellExe $PowerShellExe

    $started += Start-DevProcess `
        -Name "frontend" `
        -Command $FrontendCommand `
        -WorkingDirectory $FrontendDir `
        -PowerShellExe $PowerShellExe

    Write-Host ""
    Write-Host "Backend:  $ApiBaseUrl"
    Write-Host "Frontend: http://$HostAddress`:$FrontendPort"
    Write-Host "Press Ctrl+C to stop both servers."
    Write-Host ""

    while ($true) {
        foreach ($item in $started) {
            if ($item.Process.HasExited) {
                throw "$($item.Name) exited with code $($item.Process.ExitCode)."
            }
        }

        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host ""
    Write-Host "Stopping dev servers..."

    foreach ($item in $started) {
        if (-not $item.Process.HasExited) {
            Stop-ProcessTree -RootProcessId $item.Process.Id
        }
    }
}
