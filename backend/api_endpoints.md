# Tolab University LMS - Grading & Student Portal API Endpoints

This document lists all the new URL routes and endpoints implemented under the `/api/v1` prefix for grading operations and the student portal.

---

## Base URLs Reference
- **Local Development (Web/Desktop/Postman):** `http://localhost:8000/api`
- **Android Emulator:** `http://10.0.2.2:8000/api`
- **iOS Simulator:** `http://localhost:8000/api`

---

## 1. Staff Grading Operations

### 1.1 GET `/api/v1/subjects/:subjectId/results`
Retrieve the comprehensive gradebook, categories, student list, uploaded sheets, activity log, and statistics.
- **Method:** `GET`
- **Allowed Roles:** `ADMIN`, `DOCTOR`, `TA`
- **Headers:** `Authorization: Bearer <token>`
- **Response Format (200 OK):**
```json
{
  "success": true,
  "data": {
    "subject_id": 1,
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
        "url": "http://localhost:8000/storage/sheets/CS301_Midterm_Official.pdf"
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

### 1.2 POST `/api/v1/subjects/:subjectId/grades/draft`
Save student grade entries as drafts (not visible to students).
- **Method:** `POST`
- **Allowed Roles:** `ADMIN`, `DOCTOR` (only for midterm/final), `TA` (only for quiz/oral/sheets/attendance/coursework)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body (JSON):**
```json
{
  "category_key": "coursework",
  "max_score": 30.0,
  "entries": [
    {
      "student_code": "20230041",
      "score": 28.0,
      "note": "Excellent work"
    },
    {
      "student_code": "20230042",
      "score": 25.5,
      "note": "Good effort"
    }
  ]
}
```
- **Response Format (200 OK):**
```json
{
  "success": true,
  "message": "Draft grades saved successfully."
}
```

---

### 1.3 POST `/api/v1/subjects/:subjectId/grades/publish`
Publish grades for a specific category, making them visible to students immediately and sending notifications.
- **Method:** `POST`
- **Allowed Roles:** `ADMIN`, `DOCTOR` (only for midterm/final), `TA` (only for quiz/oral/sheets/attendance/coursework)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body (JSON):** Same as the draft payload.
- **Response Format (200 OK):**
```json
{
  "success": true,
  "message": "Grades published successfully. Students have been notified."
}
```

---

### 1.4 POST `/api/v1/subjects/:subjectId/grades/upload-sheet`
Upload a shared grade file (PDF, Excel, CSV). If the uploaded file is a `.csv` file, the backend automatically parses it to populate/overwrite the student grades and publishes them.
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Allowed Roles:** `ADMIN`, `DOCTOR`, `TA`
- **Headers:** `Authorization: Bearer <token>`
- **Request Parameters:**
  - `category_key` (String): e.g., `"midterm"`
  - `file` (Binary File): PDF, CSV, Excel
- **CSV Structure Requirement (No Headers):**
  - Column 1: Student Code (e.g. `20230041`)
  - Column 2: Score Decimal (e.g. `18.5`)
- **Response Format (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "CS301_Midterm_Scores.csv",
    "mimeType": "CSV",
    "sizeLabel": "12 KB",
    "url": "http://localhost:8000/storage/sheets/CS301_Midterm_Scores.csv"
  },
  "message": "Grade sheet uploaded and 45 student grades imported/published successfully."
}
```

---

## 2. Student Portal Dashboard

### 2.1 GET `/api/v1/student/dashboard`
Retrieve academic grades, statistics, and shared grade files for the currently logged-in student.
- **Method:** `GET`
- **Allowed Roles:** `STUDENT`
- **Headers:** `Authorization: Bearer <token>`
- **Response Format (200 OK):**
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
        "subject_id": 1,
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
            "score": null,
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
            "url": "http://localhost:8000/storage/sheets/CS301_Midterm_Official.pdf"
          }
        ]
      }
    ]
  }
}
```
*Note: Any grade entry whose status is `Draft` has its score masked (`null`) to protect visibility.*
