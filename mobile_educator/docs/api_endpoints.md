# Tolab Educator API Endpoints

## Auth
- `POST /auth/login`
  - Request: `{"email": "...", "password": "..."}`
  - Response: `{"token": "...", "role": "doctor|assistant"}`
- `POST /auth/forgot-password`
  - Request: `{"email": "..."}`
- `POST /auth/verify-otp`
  - Request: `{"email": "...", "otp": "..."}`
- `POST /auth/reset-password`
  - Request: `{"email": "...", "password": "..."}`

## Subjects
- `GET /subjects`
- `GET /subjects/{id}/lectures`
- `POST /subjects/{id}/lectures`
  - Fields: `name`, `week`, `doctor`, `video_url` (optional), `file` (multipart)
- `GET /subjects/{id}/sections`
- `POST /subjects/{id}/sections`
- `GET /subjects/{id}/quizzes`
- `POST /subjects/{id}/quizzes`
- `GET /subjects/{id}/tasks`
- `POST /subjects/{id}/tasks`

## Community
- `GET /community/posts`
- `POST /community/posts`
- `POST /community/posts/{id}/comments`
- `POST /community/posts/{id}/reactions`

## Notifications
- `GET /notifications`
- `POST /notifications/{id}/read`
