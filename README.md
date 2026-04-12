# 🎓 EduGate — Smart University Academic Platform

> A scalable academic ecosystem that streamlines the university experience for students, educators, and administrators through structured course management, academic communication, scheduling, and performance tracking.

---

## Overview

**EduGate** is a role-based university platform designed to digitize and simplify the academic journey across the entire institution.

The system is organized into two dedicated applications:

- **EduGate Student** — a focused student experience for accessing courses, study materials, grades, schedules, and course groups.
- **EduGate Admin & Staff** — an operational platform for administrators, doctors, and teaching assistants to manage academic workflows, content, enrollments, and communication.

EduGate is built around clarity, access control, and maintainability, ensuring that every user interacts only with the features and data relevant to their role.

---

## Core Vision

EduGate is designed to solve common academic management challenges by providing:

- A centralized academic content hub
- Structured course enrollment and organization
- Secure role-based access control
- Real-time academic communication
- Scalable scheduling and notification workflows
- A maintainable architecture ready for institutional growth

---

## Applications

### EduGate Student

A dedicated application built around the student’s academic journey.

#### Course Access
Students can browse all enrolled courses and open each course into a detailed academic workspace containing:

- **Lectures** — uploaded lecture materials and resources
- **Section Sessions** — practical or assistant-led learning content
- **Summaries** — concise course study materials
- **Assessments** — quizzes, tasks, and sheets with deadlines
- **Exams** — exam details and attached files
- **Course Files** — general course-related documents

#### Grades Tracking
Students can review their grades per course in a structured format, including:

- Midterms
- Quizzes
- Tasks
- Finals
- Attendance
- Additional grading items

#### Smart Timetable
A dynamic academic timetable that supports:

- **Odd / Even week scheduling**
- Lecture sessions
- Section sessions
- Quiz dates
- Task deadlines
- Exam dates

#### Course Groups
Each course has its own dedicated group space where students can:

- Create posts
- Add comments
- Send messages
- Interact within course-specific academic discussions

Participation permissions are fully controlled by the admin to maintain structure and relevance.

#### Notifications
Students receive targeted academic notifications for:

- New uploaded content
- Exam and quiz announcements
- Schedule changes
- Course-specific updates
- General academic alerts

---

### EduGate Admin & Staff

A management-focused application for academic and operational control.

#### User Management
Administrators can fully manage users across the platform:

- Create student and staff accounts
- Edit user information
- Activate or deactivate accounts
- Reset passwords
- Import students and staff in bulk through Excel or CSV

#### Academic Structure Management
The platform supports full academic structure setup, including:

- **Departments**
- **Sections**
- **Subjects**
- Academic years and semester mapping

#### Course Offerings
Subjects can be assigned to sections for a specific semester and academic year.  
Each course offering automatically generates its own dedicated group space.

Admins can also assign:

- Doctors
- Teaching assistants

to the appropriate course offerings.

#### Enrollment Management
Students can be enrolled:

- Individually
- In bulk by section

This gives the institution full control over subject registration and visibility.

#### Content Management
Academic content can be uploaded and managed per course offering, including:

- Lectures
- Section materials
- Summaries
- Assessments
- Exams
- General course files

#### Grades Management
Staff and admins can manage student performance through:

- Grade entry
- Grade editing
- Grade review
- Categorized grading by item type
- Optional notes and score breakdowns

#### Timetable Management
Admins can build and maintain the weekly academic schedule with support for:

- Odd / Even week logic
- Event-based scheduling
- Room and hall assignment
- Lecture and section time slots
- Assessment and exam scheduling

#### Broadcast Notifications
The system allows targeted notifications to be sent to:

- Individual users
- Entire sections
- Students enrolled in a specific course

#### Moderation
To maintain a healthy academic communication environment, admins can review and remove:

- Posts
- Comments
- Messages

from course groups when necessary.

---

## User Roles

| Role | Responsibility |
|------|----------------|
| **Admin** | Full system control, including user management, academic setup, content administration, permissions, notifications, moderation, and enrollments |
| **Student** | Access enrolled courses, content, grades, timetable, notifications, and participate in course groups according to system policy |
| **Doctor** | Access assigned academic subjects and, when granted by the admin, manage course content and academic actions |
| **TA** | Access assigned subjects and assist with academic management based on permissions configured by the admin |

---

## Authentication & Access Control

EduGate follows a strict and secure authentication model:

- Students log in using their **university email**
- The default initial password may be based on the student’s **national ID**, according to system configuration
- Staff accounts are created and controlled entirely by the admin
- Password reset is **admin-controlled only**
- No self-registration is allowed
- All data access is controlled by role and enrollment rules

This ensures that:

- Students only access their own enrolled courses
- Staff only access their assigned academic content
- Admin-only operations remain protected at the API level

---

## Academic Workflow

A typical semester setup within EduGate follows this lifecycle:

1. Import students and staff in bulk
2. Create departments, sections, and subjects
3. Create course offerings for the semester
4. Auto-generate course groups
5. Enroll students into course offerings
6. Upload course content and configure schedules
7. Enable notifications and manage ongoing academic communication

This workflow makes the system efficient, repeatable, and easy to operate at scale.

---

## Main Screens

### Student Application
- Login
- Home Dashboard
- Courses List
- Course Details
- Lectures
- Sections
- Summaries
- Assessments
- Exams
- Course Files
- Grades
- Course Group
- Timetable
- Notifications
- Profile

### Admin & Staff Application
- Login
- Dashboard
- User Management
- Academic Setup
- Course Offerings
- Enrollments
- Content Manager
- Timetable Manager
- Notifications Broadcast
- Moderation
- Profile

---

## Technical Stack

| Layer | Technology |
|------|------------|
| **Mobile Applications** | Flutter |
| **Backend** | REST API |
| **Authentication** | JWT (Access Token + Refresh Token) |
| **File Uploads** | Multipart Upload Service |
| **Academic Communication** | Course-based group interactions |
| **Architecture Goal** | Scalable, maintainable, role-driven system design |

---

## Repository Structure

```bash
edugate/
├── student_app/     # Flutter application for students
├── admin_app/       # Flutter application for admins, doctors, and TAs
└── backend/         # REST API backend

## Security Highlights

EduGate is designed with access control and data isolation in mind:

- Role-protected API endpoints
- Enrollment-based course access control
- Course-group participation restricted by registration rules
- No unauthorized self-registration
- Admin-only control over account provisioning and resets
- Structured moderation support for academic discussions

---

## Why EduGate

EduGate is more than a classroom utility. It is a structured academic platform designed to support real university operations through:

- Organized academic delivery
- Controlled user access
- Streamlined course workflows
- Centralized communication
- Scalable administration

It aims to reduce operational friction while improving visibility, coordination, and engagement across the academic environment.

---

## Maintainer

For support, collaboration, or project inquiries, please contact the project maintainer.

**By Ibrahim Elshishtawy**

---

> Built to modernize university life with a secure, scalable, and user-focused academic experience.
