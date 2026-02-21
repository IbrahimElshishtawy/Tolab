from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlmodel import Session, select
from api import deps
from models import Task, Submission, User, UserRole
from core.storage import save_upload_file, validate_file
from datetime import datetime

router = APIRouter()

@router.get("/subjects/{subject_id}/tasks", response_model=List[Task])
def read_tasks(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    statement = select(Task).where(Task.subject_id == subject_id)
    return db.exec(statement.offset(skip).limit(limit)).all()

@router.post("/subjects/{subject_id}/tasks", response_model=Task)
def create_task(
    subject_id: int,
    title: str = Form(...),
    description: str = Form(...),
    due_date: datetime = Form(...),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT])),
) -> Any:
    task = Task(title=title, description=description, due_date=due_date, subject_id=subject_id)
    db.add(task)
    db.commit()
    db.refresh(task)

    deps.log_action(db, current_user.id, "create", "task", str(task.id))

    return task

@router.post("/tasks/{task_id}/submissions", response_model=Submission)
def create_submission(
    task_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    validate_file(file)
    file_url = save_upload_file(file)
    submission = Submission(
        task_id=task_id,
        student_id=current_user.id,
        file_url=file_url
    )
    db.add(submission)
    db.commit()
    db.refresh(submission)
    return submission

@router.get("/tasks/{task_id}/submissions")
def read_submissions(
    task_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT])),
) -> Any:
    # Join with User to get student name
    statement = select(Submission, User.full_name).join(User, Submission.student_id == User.id).where(Submission.task_id == task_id)
    results = db.exec(statement).all()

    submissions = []
    for sub, name in results:
        sub_dict = sub.model_dump()
        sub_dict["student_name"] = name
        submissions.append(sub_dict)
    return submissions

@router.post("/submissions/{submission_id}/grade")
def grade_submission(
    submission_id: int,
    grade: float = Form(...),
    feedback: Optional[str] = Form(None),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT])),
) -> Any:
    submission = db.get(Submission, submission_id)
    if not submission:
        raise HTTPException(status_code=404, detail="Submission not found")
    submission.grade = grade
    submission.feedback_comment = feedback
    submission.graded_at = datetime.utcnow()
    submission.graded_by = current_user.id
    db.add(submission)

    deps.log_action(db, current_user.id, "grade", "submission", str(submission_id))

    db.commit()
    db.refresh(submission)
    return submission
