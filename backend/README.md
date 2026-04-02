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
