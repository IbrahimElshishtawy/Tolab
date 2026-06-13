# Production Environment Variables Checklist

This checklist contains all the essential environment variables required for running the Tolab University Backend in a production environment. Copy this file or use it as a reference when configuring your `.env` files.

---

## 1. Core Application Settings

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `APP_NAME` | `"Tolab University API"` | The name of the application. Used in mail templates and logs. |
| `APP_ENV` | `production` | **MUST** be set to `production` in live environments. |
| `APP_KEY` | `base64:sOmERaNdOmKeY...` | **CRITICAL**: The encryption key (32 bytes). Generate via `php artisan key:generate`. |
| `APP_DEBUG` | `false` | **MUST** be set to `false` in production to prevent stack traces from exposing sensitive code. |
| `APP_URL` | `https://api.tolab.edu` | The public base URL of the API. Crucial for generating route URLs. |
| `APP_TIMEZONE` | `Africa/Cairo` | The default timezone for the application. |
| `APP_LOCALE` | `en` | Default translation language. |

---

## 2. Database Connections

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `DB_CONNECTION` | `mysql` | Database driver (should remain `mysql`). |
| `DB_HOST` | `127.0.0.1` | The database server address. Set to `db` if using the Docker Compose MySQL service, or your external DB endpoint. |
| `DB_PORT` | `3306` | Default MySQL port. |
| `DB_DATABASE` | `tolab_university` | The name of the MySQL database. |
| `DB_USERNAME` | `tolab_prod_user` | The MySQL user name. Avoid using `root` in production. |
| `DB_PASSWORD` | `HighlySecurePassword!` | The password for the MySQL user. |
| `DB_ROOT_PASSWORD` | `SuperSecureRootPassword!`| **Docker Only**: Set only if using the local MySQL service in `docker-compose.yml`. |

---

## 3. Redis, Queue, Session, and Cache Settings

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `REDIS_HOST` | `redis` | Redis server address. Set to `redis` if using the Docker Compose service. |
| `REDIS_PORT` | `6379` | Default Redis port. |
| `REDIS_PASSWORD` | `StrongRedisPassword` | The auth password for the Redis server. |
| `CACHE_STORE` | `redis` | The caching backend. Set to `redis` for optimal performance in production. |
| `SESSION_DRIVER` | `redis` | The session backend. Set to `redis` to share sessions across scaled web servers. |
| `QUEUE_CONNECTION` | `redis` | **MUST** be set to `redis` to use Laravel Horizon. |
| `REDIS_QUEUE_RETRY_AFTER` | `90` | Time (in seconds) before a job is considered timed out and made available again on the queue. |

---

## 4. Sanctum & Authentication Tokens

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `SANCTUM_ACCESS_TOKEN_MINUTES` | `15` | Expiration time for active API tokens. |
| `AUTH_REFRESH_TOKEN_DAYS` | `30` | Expiration time for refresh tokens. |
| `AUTH_REFRESH_TOKEN_PEPPER` | `long_random_salt_value_here` | **CRITICAL**: Salt pepper for refresh token hashing. Generate a long, secure random string. |

---

## 5. Microsoft OAuth Integration

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `MICROSOFT_CLIENT_ID` | `12345678-abcd-1234-abcd-1234567890ab` | Client ID from Microsoft Entra ID (Azure AD) Portal. |
| `MICROSOFT_CLIENT_SECRET` | `value_from_azure_portal` | Client Secret from Microsoft Entra ID Portal. |
| `MICROSOFT_REDIRECT_URI` | `https://api.tolab.edu/api/auth/microsoft/callback` | Callback URI registered in Microsoft Azure (must match `APP_URL`). |
| `MICROSOFT_TENANT_ID` | `organizations` | Microsoft Tenant ID. Set to `organizations` for multi-tenant school accounts. |

---

## 6. Frontend & CORS Configurations

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `FRONTEND_URL` | `https://university.tolab.edu` | The public base URL of the user interface (e.g. Next.js/Vite frontend). |
| `CORS_ALLOWED_ORIGINS` | `https://university.tolab.edu` | Comma-separated list of origins permitted to access this API. |

---

## 7. Mail Settings (Production Outbox)

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `MAIL_MAILER` | `smtp` | Mail driver (e.g., `smtp`, `ses`, `postmark`, `mailgun`). |
| `MAIL_HOST` | `smtp.mailgun.org` | SMTP server address. |
| `MAIL_PORT` | `587` | SMTP server port (usually `587` for TLS, or `465` for SSL). |
| `MAIL_USERNAME` | `postmaster@tolab.edu` | Mail account username. |
| `MAIL_PASSWORD` | `SMTPPasswordValue` | Mail account password. |
| `MAIL_ENCRYPTION` | `tls` | Encryption protocol (`tls` or `ssl`). |
| `MAIL_FROM_ADDRESS` | `noreply@tolab.edu` | Sender email address for system emails. |
| `MAIL_FROM_NAME` | `"Tolab University"` | Sender name displayed to users. |

---

## 8. Docker Runtime Directives

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `CONTAINER_ROLE` | `app` | Defines the container execution pathway. Valid roles: `app` (web), `worker` (Horizon queue), or `scheduler` (scheduler loop). |
| `RUN_MIGRATIONS` | `true` | Set to `true` on the `app` container to run database migrations automatically on startup. Set to `false` for others to prevent duplicate runs. |
| `APP_PORT` | `8000` | Local port mapped on host to expose the application (default `8000`). |

---

## 9. Seeded Administrative Accounts (First-Time Setup Only)

| Key | Example Value | Description |
| :--- | :--- | :--- |
| `DEFAULT_ADMIN_EMAIL` | `admin@tolab.edu` | Email of the default admin account created during database seed. |
| `DEFAULT_ADMIN_PASSWORD` | `Admin@123_ChangeMe!` | Password for the default admin account (ensure it is strong). |
| `DEFAULT_ACADEMY_PASSWORD` | `Academy@123_ChangeMe!`| Base password for mock students/doctors generated during seed. |
