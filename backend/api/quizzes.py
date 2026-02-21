from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from api import deps
from models import Quiz, QuizAttempt, User, UserRole
from datetime import datetime

router = APIRouter()

@router.get("/", response_model=List[Quiz])
def read_quizzes(
    subject_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Quiz).where(Quiz.subject_id == subject_id)
    return db.exec(statement).all()

@router.post("/", response_model=Quiz)
def create_quiz(
    quiz: Quiz,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.RoleChecker([UserRole.DOCTOR])),
) -> Any:
    db.add(quiz)
    db.commit()
    db.refresh(quiz)
    return quiz

@router.post("/{quiz_id}/attempt", response_model=QuizAttempt)
def start_quiz_attempt(
    quiz_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    quiz = db.get(Quiz, quiz_id)
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")

    attempt = QuizAttempt(quiz_id=quiz_id, student_id=current_user.id)
    db.add(attempt)
    db.commit()
    db.refresh(attempt)
    return attempt

@router.post("/attempts/{attempt_id}/submit")
def submit_quiz_attempt(
    attempt_id: int,
    score: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    attempt = db.get(QuizAttempt, attempt_id)
    if not attempt or attempt.student_id != current_user.id:
        raise HTTPException(status_code=404, detail="Attempt not found")

    attempt.completed_at = datetime.utcnow()
    attempt.score = score
    db.add(attempt)
    db.commit()
    db.refresh(attempt)
    return attempt
