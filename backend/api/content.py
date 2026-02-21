from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlmodel import Session, select
from api import deps
from models import Lecture, Section, User, UserRole
from core.storage import save_upload_file, validate_file

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

@router.post("/subjects/{subject_id}/lectures", response_model=Lecture)
def create_lecture(
    subject_id: int,
    title: str = Form(...),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.IT_ADMIN])),
) -> Any:
    content_url = None
    if file:
        validate_file(file)
        content_url = save_upload_file(file)

    lecture = Lecture(title=title, content_url=content_url, subject_id=subject_id)
    db.add(lecture)
    db.commit()
    db.refresh(lecture)
    return lecture

@router.post("/subjects/{subject_id}/sections", response_model=Section)
def create_section(
    subject_id: int,
    title: str = Form(...),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.ASSISTANT, UserRole.DOCTOR])),
) -> Any:
    content_url = None
    if file:
        validate_file(file)
        content_url = save_upload_file(file)

    section = Section(title=title, content_url=content_url, subject_id=subject_id, assistant_id=current_user.id)
    db.add(section)
    db.commit()
    db.refresh(section)
    return section
