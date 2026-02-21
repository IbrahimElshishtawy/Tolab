from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select, desc
from api import deps
from models import AttendanceSession, AttendanceRecord, User, UserRole, Subject
from datetime import datetime, timedelta
import secrets
import string

router = APIRouter()

def generate_attendance_code(length=6):
    return ''.join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(length))

@router.post("/subjects/{subject_id}/attendance/sessions", response_model=AttendanceSession)
def create_attendance_session(
    subject_id: int,
    type: str, # "Lecture" or "Section"
    duration_mins: int = 15,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR, UserRole.ASSISTANT, UserRole.IT_ADMIN])),
) -> Any:
    subject = db.get(Subject, subject_id)
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")

    # Ownership Check
    if current_user.role == UserRole.DOCTOR and subject.doctor_id != current_user.id:
         raise HTTPException(status_code=403, detail="You do not teach this subject")
    # For Assistant, one would check enrollment or assignment table (future)

    # Unique code retry logic
    code = generate_attendance_code()
    attempts = 0
    while attempts < 5:
        existing = db.exec(select(AttendanceSession).where(AttendanceSession.code == code, AttendanceSession.ends_at > datetime.utcnow())).first()
        if not existing:
            break
        code = generate_attendance_code()
        attempts += 1

    starts_at = datetime.utcnow()
    ends_at = starts_at + timedelta(minutes=duration_mins)

    session = AttendanceSession(
        subject_id=subject_id,
        type=type,
        starts_at=starts_at,
        ends_at=ends_at,
        code=code,
        created_by=current_user.id
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session

@router.post("/attendance/sessions/{session_id}/checkin")
def student_checkin(
    session_id: int,
    code: str,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.STUDENT])),
) -> Any:
    session = db.get(AttendanceSession, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if datetime.utcnow() > session.ends_at:
        raise HTTPException(status_code=400, detail="Attendance code has expired")

    if session.code != code.upper():
        raise HTTPException(status_code=400, detail="Invalid attendance code")

    # Prevent double check-in
    existing = db.exec(
        select(AttendanceRecord).where(
            AttendanceRecord.session_id == session_id,
            AttendanceRecord.student_id == current_user.id
        )
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already checked in for this session")

    record = AttendanceRecord(session_id=session_id, student_id=current_user.id)
    db.add(record)

    deps.log_action(db, current_user.id, "check_in", "attendance", str(session_id))

    db.commit()
    return {"status": "success", "checked_in_at": record.checked_in_at}

@router.get("/subjects/{subject_id}/attendance")
def get_attendance_history(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    if current_user.role == UserRole.STUDENT:
        # Student sees their own records for this subject
        statement = select(AttendanceRecord).join(AttendanceSession).where(
            AttendanceSession.subject_id == subject_id,
            AttendanceRecord.student_id == current_user.id
        ).order_by(desc(AttendanceRecord.checked_in_at))
        return db.exec(statement).all()
    else:
        # Educators see all sessions for this subject
        statement = select(AttendanceSession).where(AttendanceSession.subject_id == subject_id).order_by(desc(AttendanceSession.starts_at))
        return db.exec(statement).all()
