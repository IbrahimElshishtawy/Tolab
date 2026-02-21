from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from api import deps
from models import Schedule, User

router = APIRouter()

@router.get("/", response_model=List[Schedule])
def read_schedule(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    # Simplified: return all schedules for now
    return db.exec(select(Schedule)).all()
