# tolab_fci

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Demo Mode (Mock Data)

The app is currently configured to use mock data for demonstration purposes.

### Student Flow
1. **Login**: Use any email/password. Role defaults to 'student'.
2. **Home**: View enrolled courses and upcoming deadlines.
3. **Subjects**: Browse subjects, view lectures, sections, and tasks.
4. **Tasks**: Submit assignments via the task details screen.
5. **Quizzes**: View and attempt quizzes with a mock timer and questions.
6. **Community**: Create posts, like posts, and add comments.
7. **Calendar**: View schedule and tap events to navigate to subjects.
8. **Profile**: Toggle notifications and logout.

### Educator Flow (Doctor/Assistant)
1. **Login**: Role is determined by the mock backend (change in `auth_reducer` or mock repo if needed).
2. **Dashboard**: View metrics like "Pending Submissions" and use "Quick Actions" to create content.
3. **Content Creation**: Use the floating '+' button in Lectures, Sections, Tasks, or Quizzes tabs to add new materials.
4. **Grading**: Navigate to the "Submissions" tab in any subject or task to view student uploads and assign grades.
