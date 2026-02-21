from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from api import deps
from models import Post, Comment, User, Reaction

router = APIRouter()

@router.get("/posts", response_model=List[Post])
def read_posts(
    subject_id: Optional[int] = None,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
    skip: int = 0,
    limit: int = 100,
) -> Any:
    statement = select(Post)
    if subject_id:
        statement = statement.where(Post.subject_id == subject_id)
    return db.exec(statement.offset(skip).limit(limit)).all()

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

@router.post("/posts/{post_id}/comments", response_model=Comment)
def create_comment(
    post_id: int,
    content: str,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    comment = Comment(content=content, post_id=post_id, author_id=current_user.id)
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return comment

@router.post("/posts/{post_id}/react")
def toggle_reaction(
    post_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    existing = db.exec(
        select(Reaction).where(Reaction.post_id == post_id, Reaction.user_id == current_user.id)
    ).first()
    if existing:
        db.delete(existing)
        db.commit()
        return {"status": "removed"}

    reaction = Reaction(post_id=post_id, user_id=current_user.id)
    db.add(reaction)
    db.commit()
    return {"status": "added"}
