# API Contract

## Base URL: `/api/v1`

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/login/access-token` | Login with username/password |
| POST | `/auth/refresh` | Refresh access token using refresh token |
| POST | `/auth/logout` | Revoke user tokens |
| GET | `/me` | Get current user profile |

### Subjects & Content
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/subjects` | List subjects (role-based filter) |
| GET | `/subjects/{id}/announcements` | List subject announcements |
| POST | `/subjects/{id}/announcements` | Create announcement (Educator) |
| GET | `/subjects/{id}/lectures` | List lectures |
| POST | `/subjects/{id}/lectures` | Upload lecture material (Educator) |

### Attendance
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/subjects/{id}/attendance/sessions` | Start attendance session (Educator) |
| POST | `/attendance/sessions/{id}/checkin` | Student check-in with code |
| GET | `/subjects/{id}/attendance` | Attendance history |

### Reporting
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/subjects/{id}/gradebook` | Full gradebook (Educator) |
| GET | `/subjects/{id}/progress` | Student individual progress |
| POST | `/submissions/{id}/grade` | Grade a student submission |
