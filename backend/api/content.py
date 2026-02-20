from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from backend.api import deps
from backend.models import Lecture, Section, User

router = APIRouter()

@router.get("/subjects/{subject_id}/lectures", response_model=List[Lecture])
def read_lectures(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Lecture).where(Lecture.subject_id == subject_id)
    return db.exec(statement).all()

@router.get("/subjects/{subject_id}/sections", response_model=List[Section])
def read_sections(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Section).where(Section.subject_id == subject_id)
    return db.exec(statement).all()
