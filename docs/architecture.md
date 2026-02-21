# LMS Architecture Overview

## Project Structure
- `backend/`: FastAPI backend with Clean Architecture.
- `mobile/`: Flutter mobile app with feature-first Redux architecture.
- `docker-compose.yml`: Local production-grade environment (PostgreSQL + API).

## Backend Layers
1. **Core**: Configuration, security (JWT), storage providers, logging.
2. **Models**: SQLModel definitions (PostgreSQL schema).
3. **API (Routers)**: REST endpoints with RBAC enforcement.
4. **Services**: Business logic (attendance code generation, aggregate progress).

## Security
- **Auth**: JWT Access + Refresh tokens with rotation.
- **RBAC**: Role-based access control (Student, Doctor, Assistant, IT).
- **Data Privacy**: Students can only access their own submissions and progress.

## Storage
- Pluggable storage interface (currently LocalStorageProvider).
- Submissions and materials stored outside the database.

## Redux Architecture (Mobile)
- **Features**: Modularized state, UI, and data layers per feature.
- **Middleware**: Intercepts actions for API calls or mock data switching.
- **StateView**: Reusable widget for handling Loading/Empty/Error states consistently.
