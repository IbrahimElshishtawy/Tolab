# LMS Mobile Application

Educational Platform Mobile Client built with Flutter and Redux.

## Tech Stack
- **State Management**: Redux (`flutter_redux`, `redux_thunk`).
- **Routing**: `go_router` with shell routing and deep links.
- **Networking**: `dio` with JWT interceptors.
- **Storage**: `flutter_secure_storage` for credentials.

## Demo Mode

The application includes a robust mock layer to test features without a live backend.

### Setup
1. Open `lib/config/env.dart`.
2. Set `useMock = true`.

### Mock Credentials
Any email containing the following keywords will assign the respective role:
- **Student**: `student@lms.com` (or any string)
- **Doctor**: `doctor@lms.com`
- **Assistant/TA**: `ta@lms.com`
- **Password**: Any string (e.g., `password`)

### Manual Test Steps
1. **Login**: Enter mock credentials.
2. **Dashboard**: Observe different widgets for Students vs. Doctors.
3. **Subjects**: Navigate to a subject, explore all 5 tabs.
4. **Tasks**: Click a task, click 'Submit Assignment', and observe the loading state and success feedback.
5. **Notifications**: Open the notifications list (icon in Home AppBar) and tap a notification to test deep link routing.
6. **Community**: Browse the feed and tap a post to view comments.

## Project Structure
- `lib/core/`: Networking, Routing, Storage, Theme, and common UI widgets.
- `lib/features/`: Feature-first modules (Auth, Home, Subjects, Tasks, etc.).
- `lib/redux/`: Global Redux store, root state, and navigation middleware.
- `lib/mock/`: Fake repositories and demo data.
