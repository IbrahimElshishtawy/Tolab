# Grading Operations & Student Portal - Backend API Specification

This document outlines the backend database additions, API endpoints, payload models, and business logic required to support the new grading workflows and the student portal in Tolab LMS.

---

## 1. Database Schema Additions

To support detailed grade tracking, category-level publishing workflows, and shared official grade sheets, the following tables should be added to the database.

### 1.1 Grade Categories Table (`grade_categories`)
Stores the breakdown of grades for a specific subject (e.g., Midterm, Final, Oral, Coursework).

```sql
CREATE TABLE grade_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  key_name VARCHAR(50) NOT NULL, -- e.g., 'midterm', 'final', 'oral', 'coursework'
  label VARCHAR(100) NOT NULL, -- e.g., 'Midterm Exam', 'Final Exam'
  max_score DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
  status ENUM('draft', 'published') NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE(subject_id, key_name),
  INDEX idx_subject_categories (subject_id)
);
```

### 1.2 Student Grades Table (`student_grades`)
Stores the individual grade entries for each student per category.

```sql
CREATE TABLE student_grades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  grade_category_id UUID NOT NULL REFERENCES grade_categories(id) ON DELETE CASCADE,
  score DECIMAL(5, 2) DEFAULT NULL, -- NULL indicates missing/not graded
  status ENUM('draft', 'published') NOT NULL DEFAULT 'draft',
  note TEXT,
  graded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE(student_id, grade_category_id),
  INDEX idx_student_grades_lookup (student_id, grade_category_id)
);
```

### 1.3 Uploaded Grade Sheets Table (`uploaded_grade_sheets`)
Tracks official grade files (Excel, CSV, PDF) uploaded by instructors and shared with students.

```sql
CREATE TABLE uploaded_grade_sheets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  grade_category_id UUID NOT NULL REFERENCES grade_categories(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL, -- Path on S3 or local disk storage
  mime_type VARCHAR(100) NOT NULL, -- e.g., 'PDF', 'CSV', 'XLSX'
  file_size_bytes INT NOT NULL,
  uploaded_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_subject_sheets (subject_id)
);
```

---

## 2. API Endpoints Specification

### 2.1 GET `/api/v1/subjects/:subjectId/results`
Retrieve the comprehensive gradebook, categories, student list, and uploaded sheets for a subject.
- **Allowed Roles**: `doctor`, `assistant`, `admin`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "subject_id": 301,
    "subject_name": "Algorithms",
    "subject_code": "CS301",
    "status_label": "Active",
    "categories": [
      {
        "key": "midterm",
        "label": "Midterm Exam",
        "max_score": 20.0,
        "status_label": "Published",
        "average_score": 16.5,
        "graded_count": 45,
        "missing_count": 0,
        "is_editable": true
      },
      {
        "key": "coursework",
        "label": "Assignments / coursework",
        "max_score": 30.0,
        "status_label": "Draft",
        "average_score": 24.2,
        "graded_count": 42,
        "missing_count": 3,
        "is_editable": true
      }
    ],
    "students": [
      {
        "student_id": 102,
        "student_name": "Menna Adel",
        "student_code": "20230041",
        "status_label": "Active",
        "notes": "Excellent performance",
        "entries": {
          "midterm": {
            "score": 18.5,
            "max_score": 20.0,
            "status_label": "Published",
            "note": null
          },
          "coursework": {
            "score": 28.0,
            "max_score": 30.0,
            "status_label": "Draft",
            "note": null
          }
        }
      }
    ],
    "uploaded_sheets": [
      {
        "id": 1,
        "name": "CS301_Midterm_Official.pdf",
        "mimeType": "PDF",
        "sizeLabel": "142 KB",
        "url": "https://tolab-lms.s3.amazonaws.com/sheets/CS301_Midterm_Official.pdf"
      }
    ],
    "recent_activity": [
      {
        "id": 12,
        "title": "Published Midterm Exam grades",
        "subtitle": "Grades made visible to all 45 enrolled students",
        "status_label": "Published",
        "created_at": "2026-06-10T14:30:00Z"
      }
    ],
    "analytics": {
      "average_score": 78.4,
      "missing_grades": 3,
      "attendance_completion": 92,
      "graded_quizzes": 5,
      "pending_quizzes": 1
    }
  }
}
```

---

### 2.2 POST `/api/v1/subjects/:subjectId/grades/draft`
Save grades as draft (not visible to students).
- **Allowed Roles**: `doctor`, `assistant`

**Request Body:**
```json
{
  "category_key": "coursework",
  "max_score": 30.0,
  "entries": [
    {
      "student_code": "20230041",
      "score": 28.0
    },
    {
      "student_code": "20230042",
      "score": 25.5
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Draft grades saved successfully."
}
```

---

### 2.3 POST `/api/v1/subjects/:subjectId/grades/publish`
Publish grades for a specific category, making them visible to students immediately.
- **Allowed Roles**: `doctor`, `assistant` (subject to coordinator/doctor approval rules)

**Request Body:** Same as the draft payload.

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Grades published successfully. Students have been notified."
}
```

---

### 2.4 POST `/api/v1/subjects/:subjectId/grades/upload-sheet`
Upload an official grade sheet and link it to a specific category.
- **Allowed Roles**: `doctor`, `assistant`
- **Request Type**: `multipart/form-data`

**Request Parameters:**
- `category_key`: `String` (e.g. `"midterm"`)
- `file`: `<Binary File>` (PDF, CSV, Excel)

**CSV File Auto-Grading Logic (Crucial Backend Requirement):**
If the uploaded file is a `.csv` file, the backend must parse the file automatically to populate/overwrite the student grades database for that subject & category, and immediately set their status to `Published`.

**CSV Structure Requirement:**
The CSV file must contain at least two columns with no headers:
- Column 1: **Student Code** (`String`)
- Column 2: **Grade Score** (`Decimal`)

Example:
```csv
20230041,18.5
20230042,16.0
20230043,14.5
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid-of-sheet",
    "name": "CS301_Midterm_Scores.csv",
    "mimeType": "CSV",
    "sizeLabel": "12 KB",
    "url": "https://tolab-lms.s3.amazonaws.com/sheets/CS301_Midterm_Scores.csv"
  },
  "message": "Grade sheet uploaded and 45 student grades imported/published successfully."
}
```

---

### 2.5 GET `/api/v1/student/dashboard`
Retrieve academic grades, statistics, and shared grade files for the currently logged-in student.
- **Allowed Roles**: `student`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "student_name": "Menna Adel",
    "student_code": "20230041",
    "department": "Computer Science",
    "gpa": 3.9,
    "attendance_rate": 96,
    "subjects": [
      {
        "subject_id": 301,
        "subject_code": "CS301",
        "subject_name": "Algorithms",
        "instructor_name": "Dr. Salma Hassan",
        "grades": [
          {
            "category_label": "Midterm Exam",
            "score": 18.5,
            "max_score": 20.0,
            "status": "Published"
          },
          {
            "category_label": "Assignments / coursework",
            "score": null, -- Hidden from student because status is 'Draft'
            "max_score": 30.0,
            "status": "Draft"
          }
        ],
        "files": [
          {
            "id": 1,
            "name": "CS301_Midterm_Official.pdf",
            "mimeType": "PDF",
            "sizeLabel": "142 KB",
            "url": "https://tolab-lms.s3.amazonaws.com/sheets/CS301_Midterm_Official.pdf"
          }
        ]
      }
    ]
  }
}
```

---

## 3. Business Logic & Access Control Rules

1. **Grade Visibility Guard**: A student must **never** be able to view a grade entry whose status is `Draft`. Only entries with status `Published` should be returned in the student's dashboard grade listing.
2. **Score Bounds Check**: The backend must throw a validation error (400 Bad Request) if any grade entry score is less than `0.0` or exceeds the category's `max_score`.
3. **CSV Parsing Validation**: When uploading a CSV file, the backend must validate that the student codes exist in the course enrollment registry. Any unrecognized codes must be returned as warning logs in the API response.
4. **Audit Trail**: Every grade modification (draft save or publish) must log an entry in the system activity/notifications history tracking table to maintain accountability.
