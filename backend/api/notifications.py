from typing import List, Any
from fastapi import APIRouter, Depends
from sqlmodel import Session, select
from api import deps
from models import Notification, User

router = APIRouter()

@router.get("/", response_model=List[Notification])
def read_notifications(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    statement = select(Notification).where(Notification.user_id == current_user.id).order_by(Notification.created_at.desc())
    return db.exec(statement.offset(skip).limit(limit)).all()

@router.post("/", response_model=Notification)
def create_notification(
    notification: Notification,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    db.add(notification)
    db.commit()
    db.refresh(notification)
    return notification

@router.put("/{id}/read")
def mark_notification_as_read(
    id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    notification = db.get(Notification, id)
    if notification and notification.user_id == current_user.id:
        notification.is_read = True
        db.add(notification)
        db.commit()
    return {"status": "success"}
