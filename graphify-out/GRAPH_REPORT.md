# Graph Report - .  (2026-07-14)

## Corpus Check
- 61 files · ~51,257 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 427 nodes · 935 edges · 26 communities (16 shown, 10 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 102 edges (avg confidence: 0.8)
- Token cost: 0 input · 290,822 output

## Community Hubs (Navigation)
- Admin API & Schemas
- Authentication Flow
- Docs: Schema & Process Reference
- Course Models & Seeding
- Frontend Admin API Client
- Backend Core & Courses API
- Frontend Dependencies & Tooling
- TypeScript Configuration
- Admin Dashboard UI
- Project Setup & Onboarding Docs
- Student Dashboard & Lessons
- Units Pages
- Module Detail Page
- Brand Identity (banner, space variant)
- Brand Identity (banner, hyphen variant)
- ESLint Config
- Next.js Config
- PostCSS Config
- File Icon Asset
- Globe Icon Asset
- Next.js Logo Asset
- Vercel Icon Asset
- Window Icon Asset

## God Nodes (most connected - your core abstractions)
1. `apiRequest()` - 29 edges
2. `compilerOptions` - 16 edges
3. `Week 2 Notes (core stack implementation notes)` - 14 edges
4. `Base` - 13 edges
5. `User` - 13 edges
6. `Unit` - 12 edges
7. `Lesson` - 12 edges
8. `Quiz` - 11 edges
9. `getToken()` - 11 edges
10. `get_db()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `SessionLocal (backend/database.py)` --shares_data_with--> `get_db()`  [EXTRACTED]
  docs/week-2-notes.md → backend/database.py
- `auth utilities: hashing, jwt, current user (backend/auth.py)` --shares_data_with--> `User`  [INFERRED]
  docs/week-2-notes.md → backend/models.py
- `ProtectedPage()` --shares_data_with--> `session storage helper (frontend/lib/auth.ts)`  [INFERRED]
  frontend/app/components/protected-page.tsx → docs/week-2-notes.md
- `docker-compose postgres service (cipher-postgres)` --shares_data_with--> `Settings`  [INFERRED]
  docker-compose.yml → backend/config.py
- `Week 2 Notes (core stack implementation notes)` --references--> `Settings`  [EXTRACTED]
  docs/week-2-notes.md → backend/config.py

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Weekly manual browser test plans (week 2-5)** — docs_week_2_test_plan_week_2_test_plan, docs_week_3_test_plan_week_3_test_plan, docs_week_4_test_plan_week_4_test_plan, docs_week_5_test_plan_week_5_test_plan [INFERRED 0.85]
- **Authentication flow participants (roles, backend auth stack, frontend auth stack)** — docs_authentication_authentication_flow, docs_authentication_student_role, docs_authentication_admin_role, docs_database_schema_users, backend_models_user, backend_auth_auth_utilities, backend_routers_auth_register, backend_routers_auth_login, backend_routers_auth_me, frontend_lib_auth_session_storage, frontend_app_components_auth_form_authform, frontend_app_components_protected_page_protectedpage [INFERRED 0.85]
- **Relational schema tables forming the course/quiz/progress data model** — docs_database_schema_users, docs_database_schema_units, docs_database_schema_modules, docs_database_schema_lessons, docs_database_schema_quizzes, docs_database_schema_quiz_questions, docs_database_schema_quiz_options, docs_database_schema_quiz_attempts, docs_database_schema_lesson_progress, docs_database_schema_case_study_responses [INFERRED 0.90]

## Communities (26 total, 10 thin omitted)

### Community 0 - "Admin API & Schemas"
Cohesion: 0.09
Nodes (66): create_lesson(), create_module(), create_quiz(), create_quiz_option(), create_quiz_question(), create_unit(), delete_lesson(), delete_module() (+58 more)

### Community 1 - "Authentication Flow"
Cohesion: 0.08
Nodes (31): auth utilities: hashing, jwt, current user (backend/auth.py), FastAPI app instance (backend/main.py), POST /auth/login (backend/routers/auth.py), GET /auth/me (backend/routers/auth.py), POST /auth/register (backend/routers/auth.py), request/response schemas (backend/schemas.py), Week 2 Notes (core stack implementation notes), AppNav() (+23 more)

### Community 2 - "Docs: Schema & Process Reference"
Cohesion: 0.08
Nodes (40): Settings, psycopg[binary], python-dotenv, docker-compose postgres service (cipher-postgres), Admin Dashboard (course structure management), Admin role, Authentication Flow, Student role (+32 more)

### Community 3 - "Course Models & Seeding"
Cohesion: 0.14
Nodes (36): Base, Lesson, LessonProgress, Module, Quiz, QuizAttempt, QuizOption, QuizQuestion (+28 more)

### Community 4 - "Frontend Admin API Client"
Cohesion: 0.08
Nodes (35): apiRequest(), completeLesson(), createLesson(), createModule(), createQuiz(), createQuizQuestion(), createUnit(), deleteLesson() (+27 more)

### Community 5 - "Backend Core & Courses API"
Cohesion: 0.13
Nodes (27): create_access_token(), get_current_user(), hash_password(), Session, User, require_admin(), verify_password(), check_database_connection() (+19 more)

### Community 6 - "Frontend Dependencies & Tooling"
Cohesion: 0.06
Nodes (32): eslint, eslint-config-next, dependencies, next, react, react-dom, devDependencies, eslint (+24 more)

### Community 7 - "TypeScript Configuration"
Cohesion: 0.06
Nodes (30): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+22 more)

### Community 8 - "Admin Dashboard UI"
Cohesion: 0.09
Nodes (18): EditTarget, emptyLessonForm, emptyModuleForm, emptyQuizForm, emptyQuizQuestionForm, emptyUnitForm, LessonFormState, lessonPayload() (+10 more)

### Community 9 - "Project Setup & Onboarding Docs"
Cohesion: 0.11
Nodes (25): engine (backend/database.py), SessionLocal (backend/database.py), bcrypt, email-validator, backend/requirements.txt dependency manifest, PyJWT, SQLAlchemy, uvicorn[standard] (+17 more)

### Community 10 - "Student Dashboard & Lessons"
Cohesion: 0.18
Nodes (14): CourseLoader(), CourseLoaderProps, StudentDashboard(), LessonDetailPage(), LessonLearningPanel(), renderContent(), ApiError, fetchLesson() (+6 more)

### Community 11 - "Units Pages"
Cohesion: 0.28
Nodes (7): AdminDashboard(), UnitsPage(), UnitDetailPage(), fetchAdminLessonQuiz(), fetchUnit(), fetchUnits(), Unit

### Community 12 - "Module Detail Page"
Cohesion: 0.67
Nodes (3): ModuleDetailPage(), CourseModule, fetchModule()

## Knowledge Gaps
- **93 isolated node(s):** `lessonTypes`, `EditTarget`, `UnitFormState`, `ModuleFormState`, `LessonFormState` (+88 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Week 2 Notes (core stack implementation notes)` connect `Authentication Flow` to `Project Setup & Onboarding Docs`, `Docs: Schema & Process Reference`, `Backend Core & Courses API`?**
  _High betweenness centrality (0.346) - this node is a cross-community bridge._
- **Why does `User` connect `Backend Core & Courses API` to `Admin API & Schemas`, `Authentication Flow`, `Course Models & Seeding`?**
  _High betweenness centrality (0.268) - this node is a cross-community bridge._
- **Why does `ProtectedPage()` connect `Authentication Flow` to `Admin Dashboard UI`, `Student Dashboard & Lessons`?**
  _High betweenness centrality (0.262) - this node is a cross-community bridge._
- **What connects `lessonTypes`, `EditTarget`, `UnitFormState` to the rest of the system?**
  _93 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Admin API & Schemas` be split into smaller, more focused modules?**
  _Cohesion score 0.09306409130816505 - nodes in this community are weakly interconnected._
- **Should `Authentication Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.08170731707317073 - nodes in this community are weakly interconnected._
- **Should `Docs: Schema & Process Reference` be split into smaller, more focused modules?**
  _Cohesion score 0.08048780487804878 - nodes in this community are weakly interconnected._