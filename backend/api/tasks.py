from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from backend.api import deps
from backend.models import Task, Submission, User

router = APIRouter()

@router.get("/subjects/{subject_id}/tasks", response_model=List[Task])
def read_tasks(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Task).where(Task.subject_id == subject_id)
    return db.exec(statement).all()

@router.post("/tasks/{task_id}/submissions")
def create_submission(
    task_id: int,
    file_url: str, # For simplicity, assuming file is already uploaded to storage
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    submission = Submission(
        task_id=task_id,
        student_id=current_user.id,
        file_url=file_url
    )
    db.add(submission)
    db.commit()
    db.refresh(submission)
    return submission
