# 🎓 EduGate — University Academic Platform

> A comprehensive mobile platform built for universities to digitize the full academic experience — from content delivery and grade tracking to real-time group communication and scheduling.

---

## 📱 Overview

**EduGate** is a dual-app mobile system designed to serve every stakeholder in the academic environment:

- **EduGate Student** — A dedicated app for students to access their courses, content, grades, timetable, and group discussions.
- **EduGate Admin/Staff** — A powerful management app for administrators, doctors, and teaching assistants to run and control the entire academic lifecycle.

The platform is built around a role-based access model that ensures every user sees only what they need, with security and simplicity at the core.

---

## ✨ Features

### 🎒 Student App

#### 📚 My Courses
Students can browse all their enrolled courses in one place. Each course opens into a rich detail view with tabbed content covering:
- **Lectures** — uploaded lecture files and materials
- **Section Sessions** — practical session content
- **Summaries** — condensed study materials
- **Assessments** — tasks, quizzes, and sheets with due dates
- **Exams** — exam details and attached files
- **Course Files** — any general course-related files

#### 📊 Grades
Students can view their grades per course in real time, broken down by item type — midterms, quizzes, tasks, finals, attendance, and more.

#### 🗓️ Smart Timetable
A dynamic timetable that supports **Odd/Even week patterns**, showing lectures, section sessions, quiz dates, and exam schedules — all in one view.

#### 💬 Group Discussions
Every course has its own group chat where students can post, comment, and message. Participation permissions are configured by the admin, keeping conversations organized and on-topic.

#### 🔔 Notifications
Real-time notifications delivered by the admin for course updates, exam announcements, new content, and more.

---

### 🛠️ Admin & Staff App

#### 👥 User Management
Full control over all platform users:
- Create, edit, activate, or deactivate student and staff accounts
- Bulk-import students and staff via Excel/CSV files
- Reset passwords individually or in bulk

#### 🏛️ Academic Structure Setup
Build the entire university structure from scratch:
- **Departments** — organize faculties and divisions
- **Sections** — manage class groups by year and department
- **Subjects** — define courses with codes, years, and semesters

#### 📋 Course Offerings
Link subjects to sections per semester and academic year. Each offering automatically generates a dedicated group chat. Assign doctors and TAs to offerings as needed.

#### 🎯 Enrollments
Enroll students into course offerings individually or in bulk by section. Full control over who is registered in each course.

#### 📤 Content Management
Upload and manage all course content:
- Lecture files and descriptions
- Section session materials
- Summaries
- Assessments (Tasks / Quizzes / Sheets) with due dates
- Exam details and schedules
- General course files

#### 📈 Grades Management
Enter, edit, and review student grades per course offering. Grades are categorized by type and include score, max score, and optional notes.

#### 📅 Timetable Manager
Create and manage the weekly schedule with support for:
- **Odd/Even week patterns** — perfect for rotating schedules
- Event types: Lectures, Sections, Quizzes, Task Deadlines, Exams
- Location and time slot configuration

#### 📢 Broadcast Notifications
Send targeted notifications to individual users, an entire section, or all students in a specific course — all from a single screen.

#### 🛡️ Moderation
Maintain a healthy academic environment by reviewing and removing inappropriate posts, comments, or messages from any course group.

---

## 👤 User Roles

| Role | Description |
|------|-------------|
| **Admin** | Full platform control — the only role that can create structure, manage users, upload content, and configure permissions |
| **Student** | Access enrolled courses, view content & grades, participate in groups (based on admin settings) |
| **Doctor** *(optional)* | View course content by default; can be granted upload/editing permissions by admin |
| **TA** *(optional)* | Same as Doctor — view-only by default with optional elevated permissions |

---

## 🔐 Authentication

- Students log in using their **university email + national ID** (as default password)
- Staff accounts are created and configured entirely by the Admin
- Password reset is **admin-controlled only** — no self-reset flow
- Optional password change available for students after first login

---

## 🚀 Platform Workflow

The typical setup flow for a new semester:

1. **Import** students and staff via bulk CSV/Excel upload
2. **Create** departments, sections, and subjects
3. **Set up** course offerings — groups are auto-created for each
4. **Enroll** students in bulk per section
5. **Upload** content and configure the odd/even timetable
6. **Activate** notifications and moderate group activity throughout the semester

---

## 📐 App Screens

### Student App
- Login
- Home Dashboard (today's schedule + notifications + enrolled courses)
- Courses List
- Course Detail (Lectures / Sections / Summaries / Assessments / Exams / Files / Grades / Group)
- Group Screen (Posts, Comments, Live Chat)
- Timetable (Odd/Even toggle)
- Notifications
- Profile (optional password change)

### Admin/Staff App
- Dashboard
- Users (import, create, edit, reset password, activate/deactivate)
- Academic Setup (Departments / Sections / Subjects)
- Course Offerings + Auto Group Creation
- Enrollments (bulk assignment)
- Content Manager (per course)
- Timetable Manager (Odd/Even)
- Notification Broadcast
- Moderation (Posts / Comments / Messages)

---

## 🧰 Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Framework | Flutter |
| Backend API | REST API |
| Authentication | JWT (Access + Refresh Tokens) |
| File Uploads | Multipart upload service |
| Real-time Groups | Group messaging per course |

---

## 📁 Project Structure

```
edugate/
├── student_app/          # Flutter app for students
├── admin_app/            # Flutter app for admins, doctors & TAs
└── backend/              # REST API server
```

---

## 🔒 Security Highlights

- All endpoints are role-protected — students can only access their own enrolled courses
- Admin-only routes are strictly enforced at the API level
- Group participation requires active enrollment in the linked course offering
- No self-registration — all accounts are created and managed by the Admin

---

## 📬 Contact

For support or inquiries, please reach out to the project maintainer.

---

> Built with ❤️ to simplify university life — for students, educators, and administrators alike.
