from typing import List, Any
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from backend.api import deps
from backend.models import Post, Comment, User

router = APIRouter()

@router.get("/posts", response_model=List[Post])
def read_posts(
    subject_id: Optional[int] = None,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    statement = select(Post)
    if subject_id:
        statement = statement.where(Post.subject_id == subject_id)
    return db.exec(statement).all()

@router.post("/posts", response_model=Post)
def create_post(
    content: str,
    subject_id: Optional[int] = None,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    post = Post(content=content, author_id=current_user.id, subject_id=subject_id)
    db.add(post)
    db.commit()
    db.refresh(post)
    return post
