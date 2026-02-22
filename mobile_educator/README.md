# Tolab Educator App

Production-ready Flutter application for Doctors and Assistants.

## Tech Stack
- **State Management**: Riverpod
- **Networking**: Dio
- **Routing**: GoRouter
- **Persistence**: Flutter Secure Storage + Shared Preferences
- **UI**: Material 3

## Project Structure
Following Clean Architecture + Feature-first pattern.
- `lib/core`: Global infrastructure (Network, Storage, Localization, Widgets).
- `lib/features`: Feature-specific modules (Auth, Home, Subjects, Community, etc.).

## Setup & Running
1. `cd mobile_educator`
2. `flutter pub get`
3. `flutter run`

## Environment Variables
- `BASE_URL`: API root (configured in `lib/core/network/api_endpoints.dart`).

## Roles
- **Doctor**: Can upload lectures, quizzes, tasks.
- **Assistant**: Can upload sections, quizzes, tasks.
