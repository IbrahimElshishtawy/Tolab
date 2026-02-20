from typing import List, Any
from fastapi import APIRouter, Depends
from sqlmodel import Session, select
from backend.api import deps
from backend.models import Notification, User

router = APIRouter()

@router.get("/", response_model=List[Notification])
def read_notifications(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Notification).where(Notification.user_id == current_user.id)
    return db.exec(statement).all()

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
