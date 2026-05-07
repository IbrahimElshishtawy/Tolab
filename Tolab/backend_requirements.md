# Backend Requirements Documentation

## Project Overview
Tolab LMS is a comprehensive Learning Management System for universities. This document specifies all API endpoints, data models, database relations, and business logic required for the Node.js backend implementation.

## Technology Stack Recommendations
- **Runtime**: Node.js 18+
- **Framework**: Express.js or NestJS
- **Database**: PostgreSQL (primary), Redis (caching)
- **Authentication**: JWT with refresh tokens
- **File Storage**: AWS S3 or similar
- **Real-time**: WebSocket or Socket.io
- **API Documentation**: Swagger/OpenAPI

---

## Database Schema & Relations

### Core Entities

#### 1. Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20),
  profile_image_url TEXT,
  role ENUM('student', 'staff', 'doctor', 'admin', 'superAdmin') NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  department_id UUID REFERENCES departments(id),
  bio TEXT,
  
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_department_id (department_id)
);
```

#### 2. Departments Table
```sql
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  head_id UUID REFERENCES users(id),
  total_students INT DEFAULT 0,
  total_staff INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  location VARCHAR(255),
  phone_number VARCHAR(20),
  email VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_code (code),
  INDEX idx_head_id (head_id)
);
```

#### 3. Courses Table
```sql
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  department_id UUID NOT NULL REFERENCES departments(id),
  credit_hours INT NOT NULL,
  max_students INT NOT NULL,
  enrolled_students INT DEFAULT 0,
  instructor_id UUID NOT NULL REFERENCES users(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  syllabus TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_code (code),
  INDEX idx_department_id (department_id),
  INDEX idx_instructor_id (instructor_id),
  INDEX idx_start_date (start_date)
);
```

#### 4. Course Prerequisites Table
```sql
CREATE TABLE course_prerequisites (
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  prerequisite_course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, prerequisite_course_id)
);
```

#### 5. Students Table
```sql
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  student_id VARCHAR(50) UNIQUE NOT NULL,
  department_id UUID NOT NULL REFERENCES departments(id),
  academic_year INT NOT NULL,
  status ENUM('active', 'inactive', 'graduated', 'suspended') DEFAULT 'active',
  gpa DECIMAL(3,2) DEFAULT 0.00,
  total_credits_completed INT DEFAULT 0,
  enrollment_date DATE NOT NULL,
  advisor_id UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_student_id (student_id),
  INDEX idx_department_id (department_id),
  INDEX idx_status (status)
);
```

#### 6. Staff Table
```sql
CREATE TABLE staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  staff_id VARCHAR(50) UNIQUE NOT NULL,
  department_id UUID NOT NULL REFERENCES departments(id),
  role ENUM('instructor', 'lecturer', 'assistant', 'coordinator', 'admin') NOT NULL,
  office_location VARCHAR(255),
  office_hours TEXT,
  join_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  specialization VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_staff_id (staff_id),
  INDEX idx_department_id (department_id),
  INDEX idx_role (role)
);
```

#### 7. Staff Qualifications Table
```sql
CREATE TABLE staff_qualifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  qualification VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 8. Enrollments Table
```sql
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  status ENUM('pending', 'active', 'completed', 'dropped', 'failed') DEFAULT 'pending',
  enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completion_date TIMESTAMP,
  grade DECIMAL(5,2),
  letter_grade VARCHAR(2),
  attendance_percentage INT DEFAULT 0,
  is_dropped BOOLEAN DEFAULT false,
  drop_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(student_id, course_id),
  INDEX idx_student_id (student_id),
  INDEX idx_course_id (course_id),
  INDEX idx_status (status)
);
```

#### 9. Schedules Table
```sql
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  instructor_id UUID NOT NULL REFERENCES users(id),
  day_of_week VARCHAR(10) NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  location VARCHAR(255) NOT NULL,
  building_name VARCHAR(100),
  room_number VARCHAR(50),
  capacity INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_course_id (course_id),
  INDEX idx_instructor_id (instructor_id),
  INDEX idx_day_of_week (day_of_week)
);
```

#### 10. Assignments Table
```sql
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('draft', 'published', 'closed', 'graded') DEFAULT 'draft',
  max_score DECIMAL(5,2) NOT NULL,
  attachment_url TEXT,
  total_submissions INT DEFAULT 0,
  graded_submissions INT DEFAULT 0,
  created_by UUID NOT NULL REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_course_id (course_id),
  INDEX idx_due_date (due_date),
  INDEX idx_status (status)
);
```

#### 11. Submissions Table
```sql
CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_url TEXT,
  content TEXT,
  status ENUM('submitted', 'graded', 'late') DEFAULT 'submitted',
  score DECIMAL(5,2),
  feedback TEXT,
  graded_by UUID REFERENCES users(id),
  graded_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(assignment_id, student_id),
  INDEX idx_assignment_id (assignment_id),
  INDEX idx_student_id (student_id),
  INDEX idx_status (status)
);
```

#### 12. Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('announcement', 'assignment', 'grade', 'schedule', 'system', 'message') NOT NULL,
  related_entity_id UUID,
  related_entity_type VARCHAR(50),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP,
  action_url TEXT,
  
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
);
```

---

## API Endpoints

### Authentication Endpoints

#### POST /api/v1/auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "student@university.edu",
  "password": "SecurePassword123!",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "role": "student",
  "phoneNumber": "+20 100 123 4567"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "student@university.edu",
    "firstName": "Ahmed",
    "lastName": "Hassan",
    "role": "student",
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

#### POST /api/v1/auth/login
Authenticate user and return tokens.

**Request Body:**
```json
{
  "email": "student@university.edu",
  "password": "SecurePassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "student@university.edu",
      "firstName": "Ahmed",
      "lastName": "Hassan",
      "role": "student"
    },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

#### POST /api/v1/auth/refresh
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "refresh_token"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "new_jwt_token"
  }
}
```

#### POST /api/v1/auth/logout
Logout user and invalidate tokens.

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### User Endpoints

#### GET /api/v1/users
Get all users (admin only).

**Query Parameters:**
- `role`: Filter by role (student, staff, doctor, admin)
- `departmentId`: Filter by department
- `isActive`: Filter by active status
- `page`: Pagination page (default: 1)
- `limit`: Items per page (default: 20)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "email": "user@university.edu",
      "firstName": "Ahmed",
      "lastName": "Hassan",
      "role": "student",
      "isActive": true,
      "departmentId": "uuid",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

#### GET /api/v1/users/:id
Get user by ID.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@university.edu",
    "firstName": "Ahmed",
    "lastName": "Hassan",
    "phoneNumber": "+20 100 123 4567",
    "profileImageUrl": "https://...",
    "role": "student",
    "isActive": true,
    "departmentId": "uuid",
    "bio": "Computer Science Student",
    "createdAt": "2024-01-15T10:30:00Z",
    "lastLoginAt": "2024-05-07T14:20:00Z"
  }
}
```

#### PUT /api/v1/users/:id
Update user profile.

**Request Body:**
```json
{
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "phoneNumber": "+20 100 123 4567",
  "bio": "Updated bio"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* updated user */ }
}
```

#### DELETE /api/v1/users/:id
Delete user (admin only).

**Response (200):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

### Course Endpoints

#### GET /api/v1/courses
Get all courses.

**Query Parameters:**
- `departmentId`: Filter by department
- `instructorId`: Filter by instructor
- `isActive`: Filter by active status
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "code": "CS101",
      "name": "Introduction to Programming",
      "description": "Learn programming fundamentals...",
      "departmentId": "uuid",
      "creditHours": 3,
      "maxStudents": 40,
      "enrolledStudents": 38,
      "instructorId": "uuid",
      "startDate": "2024-09-01",
      "endDate": "2024-12-20",
      "isActive": true,
      "prerequisites": ["CS100"]
    }
  ],
  "pagination": { /* ... */ }
}
```

#### POST /api/v1/courses
Create new course (admin/staff only).

**Request Body:**
```json
{
  "code": "CS101",
  "name": "Introduction to Programming",
  "description": "Learn programming fundamentals...",
  "departmentId": "uuid",
  "creditHours": 3,
  "maxStudents": 40,
  "instructorId": "uuid",
  "startDate": "2024-09-01",
  "endDate": "2024-12-20",
  "prerequisites": ["CS100"]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* created course */ }
}
```

#### GET /api/v1/courses/:id
Get course by ID.

**Response (200):**
```json
{
  "success": true,
  "data": { /* course details */ }
}
```

#### PUT /api/v1/courses/:id
Update course (admin/instructor only).

**Request Body:**
```json
{
  "name": "Updated Course Name",
  "description": "Updated description",
  "maxStudents": 45
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* updated course */ }
}
```

#### DELETE /api/v1/courses/:id
Delete course (admin only).

**Response (200):**
```json
{
  "success": true,
  "message": "Course deleted successfully"
}
```

---

### Enrollment Endpoints

#### GET /api/v1/enrollments
Get enrollments (filtered by user role).

**Query Parameters:**
- `studentId`: Filter by student
- `courseId`: Filter by course
- `status`: Filter by status
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "studentId": "uuid",
      "courseId": "uuid",
      "status": "active",
      "enrollmentDate": "2024-09-01T10:00:00Z",
      "grade": null,
      "letterGrade": null,
      "attendancePercentage": 85,
      "isDropped": false
    }
  ],
  "pagination": { /* ... */ }
}
```

#### POST /api/v1/enrollments
Enroll student in course.

**Request Body:**
```json
{
  "studentId": "uuid",
  "courseId": "uuid"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* enrollment */ }
}
```

#### PUT /api/v1/enrollments/:id
Update enrollment (grade, attendance, status).

**Request Body:**
```json
{
  "status": "completed",
  "grade": 85.5,
  "letterGrade": "A",
  "attendancePercentage": 92
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* updated enrollment */ }
}
```

#### DELETE /api/v1/enrollments/:id
Drop course (student or admin).

**Response (200):**
```json
{
  "success": true,
  "message": "Enrollment dropped successfully"
}
```

---

### Assignment Endpoints

#### GET /api/v1/assignments
Get assignments for course.

**Query Parameters:**
- `courseId`: Filter by course (required)
- `status`: Filter by status
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "courseId": "uuid",
      "title": "Assignment 1",
      "description": "Complete the following tasks...",
      "dueDate": "2024-09-15T23:59:59Z",
      "status": "published",
      "maxScore": 100,
      "attachmentUrl": "https://...",
      "totalSubmissions": 35,
      "gradedSubmissions": 20,
      "createdBy": "uuid"
    }
  ],
  "pagination": { /* ... */ }
}
```

#### POST /api/v1/assignments
Create assignment (instructor only).

**Request Body:**
```json
{
  "courseId": "uuid",
  "title": "Assignment 1",
  "description": "Complete the following tasks...",
  "dueDate": "2024-09-15T23:59:59Z",
  "maxScore": 100,
  "attachmentUrl": "https://..."
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* created assignment */ }
}
```

#### PUT /api/v1/assignments/:id
Update assignment (instructor only).

**Request Body:**
```json
{
  "title": "Updated Title",
  "dueDate": "2024-09-20T23:59:59Z",
  "status": "published"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* updated assignment */ }
}
```

---

### Submission Endpoints

#### GET /api/v1/submissions
Get submissions for assignment.

**Query Parameters:**
- `assignmentId`: Filter by assignment (required)
- `studentId`: Filter by student
- `status`: Filter by status
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "assignmentId": "uuid",
      "studentId": "uuid",
      "submissionDate": "2024-09-14T15:30:00Z",
      "fileUrl": "https://...",
      "status": "submitted",
      "score": null,
      "feedback": null,
      "gradedBy": null,
      "gradedAt": null
    }
  ],
  "pagination": { /* ... */ }
}
```

#### POST /api/v1/submissions
Submit assignment (student).

**Request Body (multipart/form-data):**
```
assignmentId: uuid
file: <binary file>
content: "Optional text submission"
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* submission */ }
}
```

#### PUT /api/v1/submissions/:id
Grade submission (instructor only).

**Request Body:**
```json
{
  "score": 85,
  "feedback": "Great work! Consider improving..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": { /* graded submission */ }
}
```

---

### Notification Endpoints

#### GET /api/v1/notifications
Get user notifications.

**Query Parameters:**
- `isRead`: Filter by read status
- `type`: Filter by type
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "userId": "uuid",
      "title": "New Assignment",
      "message": "Dr. Ali posted a new assignment...",
      "type": "assignment",
      "relatedEntityId": "uuid",
      "relatedEntityType": "assignment",
      "isRead": false,
      "createdAt": "2024-05-07T10:30:00Z",
      "actionUrl": "/assignments/uuid"
    }
  ],
  "pagination": { /* ... */ }
}
```

#### PUT /api/v1/notifications/:id
Mark notification as read.

**Response (200):**
```json
{
  "success": true,
  "data": { /* updated notification */ }
}
```

#### PUT /api/v1/notifications/mark-all-read
Mark all notifications as read.

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

### Schedule Endpoints

#### GET /api/v1/schedules
Get course schedules.

**Query Parameters:**
- `courseId`: Filter by course
- `instructorId`: Filter by instructor
- `dayOfWeek`: Filter by day
- `page`: Pagination page
- `limit`: Items per page

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "courseId": "uuid",
      "instructorId": "uuid",
      "dayOfWeek": "Monday",
      "startTime": "09:00",
      "endTime": "10:30",
      "location": "Building A, Room 101",
      "buildingName": "Building A",
      "roomNumber": "101",
      "capacity": 40,
      "startDate": "2024-09-01",
      "endDate": "2024-12-20",
      "isActive": true
    }
  ],
  "pagination": { /* ... */ }
}
```

#### POST /api/v1/schedules
Create schedule (admin/instructor).

**Request Body:**
```json
{
  "courseId": "uuid",
  "instructorId": "uuid",
  "dayOfWeek": "Monday",
  "startTime": "09:00",
  "endTime": "10:30",
  "location": "Building A, Room 101",
  "buildingName": "Building A",
  "roomNumber": "101",
  "capacity": 40,
  "startDate": "2024-09-01",
  "endDate": "2024-12-20"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": { /* created schedule */ }
}
```

---

## Error Handling

### Standard Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input provided",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  }
}
```

### Error Codes
- `VALIDATION_ERROR` (400) - Input validation failed
- `UNAUTHORIZED` (401) - Authentication required
- `FORBIDDEN` (403) - Insufficient permissions
- `NOT_FOUND` (404) - Resource not found
- `CONFLICT` (409) - Resource already exists
- `INTERNAL_ERROR` (500) - Server error

---

## Authentication & Authorization

### JWT Token Structure
```json
{
  "sub": "user_id",
  "email": "user@university.edu",
  "role": "student",
  "departmentId": "dept_id",
  "iat": 1620000000,
  "exp": 1620003600
}
```

### Role-Based Access Control (RBAC)
- **superAdmin**: Full system access
- **admin**: Department/course management
- **doctor**: Course creation, grading, scheduling
- **staff**: Course assistance, grading support
- **student**: Course enrollment, submissions

### Protected Routes
- All endpoints require valid JWT token in Authorization header
- Format: `Authorization: Bearer <token>`

---

## Rate Limiting

- **Default**: 100 requests per minute per user
- **Auth endpoints**: 5 requests per minute per IP
- **File upload**: 10 requests per minute per user

---

## Pagination

All list endpoints support pagination:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)

Response includes:
```json
{
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

---

## File Upload

### Supported File Types
- Documents: PDF, DOC, DOCX, XLS, XLSX
- Images: JPG, PNG, GIF
- Videos: MP4, AVI, MOV
- Archives: ZIP, RAR

### File Size Limits
- Documents: 50MB
- Images: 10MB
- Videos: 500MB
- Total per user: 5GB

### Upload Endpoint
```
POST /api/v1/files/upload
Content-Type: multipart/form-data

file: <binary>
type: "assignment" | "profile" | "course_material"
```

---

## Real-time Features (WebSocket)

### Connection
```
ws://api.university.edu/ws?token=<jwt_token>
```

### Events

#### Notification Event
```json
{
  "type": "notification",
  "data": {
    "id": "uuid",
    "title": "New Assignment",
    "message": "...",
    "type": "assignment"
  }
}
```

#### Grade Update Event
```json
{
  "type": "grade_update",
  "data": {
    "submissionId": "uuid",
    "score": 85,
    "feedback": "..."
  }
}
```

#### Enrollment Update Event
```json
{
  "type": "enrollment_update",
  "data": {
    "enrollmentId": "uuid",
    "status": "active"
  }
}
```

---

## Database Indexes

### Performance Indexes
```sql
-- User lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_department ON users(department_id);

-- Course lookups
CREATE INDEX idx_courses_code ON courses(code);
CREATE INDEX idx_courses_department ON courses(department_id);
CREATE INDEX idx_courses_instructor ON courses(instructor_id);

-- Enrollment lookups
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);

-- Assignment lookups
CREATE INDEX idx_assignments_course ON assignments(course_id);
CREATE INDEX idx_assignments_due_date ON assignments(due_date);

-- Notification lookups
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
```

---

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] JWT secret keys generated
- [ ] File storage configured (S3/local)
- [ ] Email service configured
- [ ] WebSocket server configured
- [ ] Redis cache configured
- [ ] CORS settings configured
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Monitoring/alerting setup
- [ ] Backup strategy implemented
- [ ] SSL/TLS certificates installed
- [ ] API documentation deployed

---

## Performance Targets

- **API Response Time**: < 200ms (p95)
- **Database Query Time**: < 100ms (p95)
- **File Upload**: < 5MB/s
- **Concurrent Users**: 10,000+
- **Uptime**: 99.9%

---

## Security Requirements

- ✅ HTTPS/TLS for all endpoints
- ✅ Password hashing (bcrypt, min 12 rounds)
- ✅ JWT token expiration (15 min access, 7 day refresh)
- ✅ CORS properly configured
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS protection (input sanitization)
- ✅ CSRF tokens for state-changing operations
- ✅ Rate limiting on auth endpoints
- ✅ Audit logging for sensitive operations
- ✅ Data encryption at rest

---

## Testing Requirements

- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests for all endpoints
- [ ] Load testing (10,000+ concurrent users)
- [ ] Security testing (OWASP Top 10)
- [ ] Database migration testing
- [ ] File upload testing
- [ ] WebSocket connection testing
- [ ] Error handling testing

---

## Documentation

- [ ] API documentation (Swagger/OpenAPI)
- [ ] Database schema documentation
- [ ] Deployment guide
- [ ] Environment setup guide
- [ ] Troubleshooting guide
- [ ] API client examples (cURL, Postman)

---

**Document Version**: 1.0  
**Last Updated**: 2024-05-07  
**Status**: Ready for Backend Development
