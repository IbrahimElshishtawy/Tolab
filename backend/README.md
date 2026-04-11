# Tolab University Backend

Production-grade modular Laravel backend for the university academic platform.

## Project Tree

```text
backend/
  app/
    Core/
      Base/
      Enums/
      Exceptions/
      Helpers/
      Middleware/
      Services/
    Modules/
      Auth/
      UserManagement/
      Academic/
      Enrollment/
      Content/
      Grades/
      Group/
      Schedule/
      Notifications/
      Moderation/
      Shared/
    Providers/
    Support/
    Traits/
    Enums/
    Exceptions/
    Helpers/
  bootstrap/
  config/
  database/
    factories/
    migrations/
    seeders/
  public/
  routes/
  storage/
  tests/
```

## Installation

1. Install PHP 8.3+, Composer, MySQL 8+.
2. From `backend/`, run `composer install`.
3. Copy `.env.example` to `.env`.
4. Run `php artisan key:generate`.
5. Configure database and auth env keys.
6. Run `php artisan migrate --seed`.
7. Run `php artisan storage:link`.
8. Run queue worker: `php artisan queue:work`.
9. Start API: `php artisan serve`.

## Important Env Keys

```dotenv
APP_NAME="Tolab University Backend"
APP_URL=http://localhost:8000
APP_TIMEZONE=Africa/Cairo

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tolab_university
DB_USERNAME=root
DB_PASSWORD=

FILESYSTEM_DISK=public
QUEUE_CONNECTION=database
CACHE_STORE=database
SESSION_DRIVER=database

SANCTUM_ACCESS_TOKEN_MINUTES=15
AUTH_REFRESH_TOKEN_DAYS=30
AUTH_REFRESH_TOKEN_PEPPER=change-me

DEFAULT_ADMIN_EMAIL=admin@tolab.edu
DEFAULT_ADMIN_PASSWORD=Admin@123
DEFAULT_ACADEMY_PASSWORD=Admin@123
```

## Seeded Accounts

- Admin: `admin@tolab.edu`
- Student: `student@tolab.edu`
- Doctor: `doctor@tolab.edu`
- Shared password: value of `DEFAULT_ACADEMY_PASSWORD` or `DEFAULT_ADMIN_PASSWORD`

## Notes

- Refresh tokens are rotated and revoked on logout.
- Admin broadcasts are queued through `BroadcastNotificationJob`.
- Student access to course content, grades, and groups is enrollment-scoped.
- Staff feature flags are stored in `staff_permissions`.

## Student Module

### What Was Added

- Hardened student-only route protection through `student` middleware.
- Enrollment-aware access control for courses, grades, groups, posts, messages, and timetable.
- Request validation for student social actions and timetable filtering.
- Richer API resources for student-facing payloads.
- Optional `StudentModuleDemoSeeder` plus supporting factories for feature coverage.
- Feature tests covering course isolation, grade isolation, group access, notifications, and timetable filtering.

### Student Endpoints

- `GET /api/student/courses`
- `GET /api/student/courses/{courseOffering}`
- `GET /api/student/courses/{courseOffering}/content`
- `GET /api/student/courses/{courseOffering}/grades`
- `GET /api/student/timetable?week=ALL|ODD|EVEN`
- `GET /api/student/courses/{courseOffering}/group`
- `GET /api/groups/{group}`
- `GET /api/groups/{group}/posts`
- `POST /api/groups/{group}/posts`
- `GET /api/posts/{post}/comments`
- `POST /api/posts/{post}/comments`
- `GET /api/groups/{group}/messages`
- `POST /api/groups/{group}/messages`
- `GET /api/notifications`
- `PATCH /api/notifications/{notification}/read`
- `GET /api/me`
- `GET /api/me/profile`
- `PUT /api/me/profile`
- `POST /api/auth/change-password`

### Access Rules

- Student routes require authenticated active users with role `STUDENT`.
- Course access requires an active enrollment with status `enrolled`.
- Group access and posting require the student to be enrolled in the group course offering.
- Grade access is scoped to the authenticated student only.
- Post/comment/message deletion is reserved for admin moderation routes.

### Testing

- Run migrations: `php artisan migrate`
- Optional demo data: `php artisan db:seed --class=StudentModuleDemoSeeder`
- Run tests: `php artisan test --filter=StudentModuleTest`

### Assumptions

- Student login uses the existing auth flow and accepts the university email through the same `email` field.
- A usable enrollment for student access is an enrollment with status `enrolled`.
- Global notifications are still supported, but the current broadcast flow creates per-user notification rows.

## Student Registration And Microsoft Login

### What Was Added

- Admin-only student import flow at `POST /api/admin/import/students` with column validation, row-level error reporting, and idempotent create/update behavior.
- Microsoft OAuth login endpoints at `GET /api/auth/microsoft/redirect` and `GET /api/auth/microsoft/callback`.
- First-login linking flow with short-lived link tokens at `POST /api/auth/microsoft/complete-link`.
- Secure student matching by university email first, then national ID confirmation before the first Microsoft link is saved.
- User and student profile schema support for Microsoft identifiers and `student_code`.

### Microsoft App Registration

Register an application in Microsoft Entra ID and configure:

- Redirect URI: `${APP_URL}/api/auth/microsoft/callback`
- Supported account type: usually `organizations` for university work/school accounts
- Delegated permissions: `openid`, `profile`, `User.Read`

### Required Environment Variables

```dotenv
MICROSOFT_CLIENT_ID=
MICROSOFT_CLIENT_SECRET=
MICROSOFT_REDIRECT_URI="${APP_URL}/api/auth/microsoft/callback"
MICROSOFT_TENANT_ID=organizations
FRONTEND_URL=http://localhost:3000
```

### Student Import File Format

Required columns:

- `student_name`
- `university_email`
- `national_id`
- `department_name`
- `section_name`
- `grade_year`

Optional columns:

- `student_code`
- `gpa`

### First Microsoft Login Flow

1. Admin imports students from Excel or CSV.
2. Student starts login at `GET /api/auth/microsoft/redirect`.
3. Microsoft returns to `GET /api/auth/microsoft/callback`.
4. Backend matches the student by `university_email`.
5. If the student is not linked yet, backend returns `link_required` with a short-lived `link_token`.
6. Student submits `link_token` plus `national_id` to `POST /api/auth/microsoft/complete-link`.
7. Backend links the Microsoft account, updates `last_login_at`, and returns the same Sanctum access token plus refresh token shape already used by the project.

### Response Shapes

Success:

```json
{
  "success": true,
  "message": "....",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "....",
  "errors": {}
}
```

### Commands

```bash
php artisan migrate
php artisan test --filter=StudentRegistrationMicrosoftAuthTest
```
