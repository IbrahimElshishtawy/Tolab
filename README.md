# LMS - Mobile-first Educational Platform

A complete Learning Management System with a FastAPI backend and Flutter mobile application.

## Project Structure
- `/backend`: FastAPI REST API with SQLModel & PostgreSQL.
- `/mobile`: Flutter application using Redux for state management.

## Tech Stack
- **Backend**: FastAPI, SQLModel (SQLAlchemy), PostgreSQL, JWT Auth.
- **Mobile**: Flutter, Redux, Microsoft Login (Optional), REST Integration.
- **Infrastructure**: Cloudflare (DNS/WAF/CDN).

## Milestones
- [x] M0: Planning & repo scaffolding
- [ ] M1: Database + migrations + seed
- [ ] M2: Auth & RBAC
- [ ] M3: Subjects & Enrollment
- [ ] M4: Content: Lectures/Sections
- [ ] M5: Tasks/Submissions
- [ ] M6: Schedule/Calendar
- [ ] M7: Notifications (deep_link)
- [ ] M8: Community
- [ ] M9: Admin minimal
- [ ] M10: Hardening: logging, rate limiting notes, basic tests, deployment notes

## Getting Started

### Backend
1. `cd backend`
2. `pip install -r requirements.txt`
3. `uvicorn main:app --reload`

### Mobile
1. `cd mobile/tolab_fci`
2. `flutter pub get`
3. `flutter run`
