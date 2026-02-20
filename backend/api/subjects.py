from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from backend.api import deps
from backend.models import Subject, User, Enrollment, UserRole

router = APIRouter()

@router.get("/", response_model=List[Subject])
def read_subjects(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Retrieve subjects based on user role.
    Students see enrolled subjects, Doctors see their own.
    """
    if current_user.role == UserRole.STUDENT:
        statement = select(Subject).join(Enrollment).where(Enrollment.student_id == current_user.id)
    elif current_user.role == UserRole.DOCTOR:
        statement = select(Subject).where(Subject.doctor_id == current_user.id)
    else:
        statement = select(Subject)

    return db.exec(statement).all()

@router.get("/{id}", response_model=Subject)
def read_subject_by_id(
    id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    subject = db.get(Subject, id)
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")
    return subject
