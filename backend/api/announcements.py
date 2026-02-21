from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select, desc
from api import deps
from models import Announcement, User, UserRole, Subject
from datetime import datetime

router = APIRouter()

@router.get("/subjects/{subject_id}/announcements", response_model=List[Announcement])
def read_announcements(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    # Students can only see announcements for enrolled subjects
    # For now, just filtering by subject_id.
    # In production, we'd check enrollment for students.
    statement = select(Announcement).where(Announcement.subject_id == subject_id).order_by(desc(Announcement.pinned), desc(Announcement.created_at))
    return db.exec(statement.offset(skip).limit(limit)).all()

@router.post("/subjects/{subject_id}/announcements", response_model=Announcement)
def create_announcement(
    subject_id: int,
    announcement: Announcement,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT, UserRole.IT_ADMIN])),
) -> Any:
    announcement.subject_id = subject_id
    announcement.created_by = current_user.id
    db.add(announcement)
    db.commit()
    db.refresh(announcement)

    deps.log_action(db, current_user.id, "create", "announcement", str(announcement.id))

    return announcement

@router.put("/announcements/{id}", response_model=Announcement)
def update_announcement(
    id: int,
    announcement_update: Announcement,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT, UserRole.IT_ADMIN])),
) -> Any:
    db_announcement = db.get(Announcement, id)
    if not db_announcement:
        raise HTTPException(status_code=404, detail="Announcement not found")

    # Only creator or IT can update
    if db_announcement.created_by != current_user.id and current_user.role != UserRole.IT_ADMIN:
        raise HTTPException(status_code=403, detail="Not authorized to update this announcement")

    announcement_data = announcement_update.model_dump(exclude_unset=True)
    for key, value in announcement_data.items():
        setattr(db_announcement, key, value)

    db_announcement.updated_at = datetime.utcnow()
    db.add(db_announcement)
    db.commit()
    db.refresh(db_announcement)
    return db_announcement

@router.delete("/announcements/{id}")
def delete_announcement(
    id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT, UserRole.IT_ADMIN])),
) -> Any:
    db_announcement = db.get(Announcement, id)
    if not db_announcement:
        raise HTTPException(status_code=404, detail="Announcement not found")

    if db_announcement.created_by != current_user.id and current_user.role != UserRole.IT_ADMIN:
        raise HTTPException(status_code=403, detail="Not authorized to delete this announcement")

    db.delete(db_announcement)
    db.commit()
    return {"status": "success"}
