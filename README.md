# University Portal - Mobile App

A complete professional-grade Learning Management System (LMS) Flutter application.

## 🚀 Overview
This repository contains the hardened, production-ready Flutter application for the University Portal. It includes a comprehensive Design System, role-based navigation (Admin/Student), and robust Redux state management.

## 🛠️ Tech Stack
- **Framework**: Flutter (Material 3)
- **State Management**: Redux (with Thunks & Middleware)
- **Navigation**: GoRouter (Role-based guards)
- **Local Storage**: Flutter Secure Storage (JWT Handling)
- **Animations**: Flutter Staggered Animations & Shimmer

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (Stable)
- Dart SDK

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Set up environment variables in `lib/config/env.dart`.
4. Run the app: `flutter run`.

## 🧪 Documentation
Detailed architectural and production documents are available in the `/docs` directory:
- `docs/TECHNICAL_AUDIT.md`: Enterprise-level technical evaluation.
- `docs/PRODUCTION_READINESS.md`: Final CTO-level deployment checklist.
- `docs/csv_templates/`: Templates for bulk user and subject imports.

## 💎 Features

### Student Experience
- **Courses**: Multi-tab subject details (Lectures, Tasks, Grades, etc.).
- **Timetable**: ODD/EVEN week toggle with modern event cards.
- **Community**: Post feed with staggered animations and real-time interaction.
- **Profile**: Detailed user settings and academic progress.

### Admin Panel (In-App)
- **User Management**: Search, filter, and bulk import students/staff via CSV.
- **Subject & Offerings**: CRUD operations for curriculum management.
- **Content Manager**: Centralized file upload and material distribution.
- **Moderation**: Queue for reporting and deleting community content.
- **Broadcast**: System-wide push notification broadcasting.

### Integration Checklist (PHASE 1)
- [x] **Auth**: Login with `student@lms.com` / `password123` or `doctor@lms.com`.
- [x] **Announcements**: Official tab with pinning support.
- [x] **Attendance**: Code-based check-in with 15-minute expiry.
- [x] **Gradebook**: Educator-only view with aggregate results.
- [x] **Progress**: Student-only view showing own completion/average.
- [x] **Security**: JWT refresh token rotation enforced.
- [x] **Audit Logs**: Core actions recorded in DB.
