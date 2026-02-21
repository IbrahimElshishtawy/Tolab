from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select, func
from api import deps
from models import Task, Submission, Quiz, QuizAttempt, User, UserRole, Subject, Enrollment

router = APIRouter()

@router.get("/subjects/{subject_id}/gradebook")
def get_gradebook(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT, UserRole.IT_ADMIN])),
) -> Any:
    # Get all students enrolled in the subject
    students = db.exec(
        select(User).join(Enrollment).where(Enrollment.subject_id == subject_id)
    ).all()

    # Get all tasks for the subject
    tasks = db.exec(select(Task).where(Task.subject_id == subject_id)).all()

    gradebook = []
    for student in students:
        student_data = {
            "student_id": student.id,
            "student_name": student.full_name,
            "tasks": []
        }
        for task in tasks:
            submission = db.exec(
                select(Submission).where(
                    Submission.task_id == task.id,
                    Submission.student_id == student.id
                )
            ).first()
            student_data["tasks"].append({
                "task_id": task.id,
                "task_title": task.title,
                "grade": submission.grade if submission else None,
                "status": "Submitted" if submission else "Missing"
            })
        gradebook.append(student_data)

    return gradebook

@router.get("/subjects/{subject_id}/progress")
def get_student_progress(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.STUDENT])),
) -> Any:
    tasks = db.exec(select(Task).where(Task.subject_id == subject_id)).all()

    submissions = db.exec(
        select(Submission).where(
            Submission.student_id == current_user.id
        ).join(Task).where(Task.subject_id == subject_id)
    ).all()

    total_tasks = len(tasks)
    completed_tasks = len(submissions)

    avg_grade = 0
    if completed_tasks > 0:
        grades = [s.grade for s in submissions if s.grade is not None]
        if grades:
            avg_grade = sum(grades) / len(grades)

    return {
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "average_grade": avg_grade,
        "submissions": submissions
    }
