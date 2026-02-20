from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Post(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    author_id: int = Field(foreign_key="user.id")
    subject_id: Optional[int] = Field(default=None, foreign_key="subject.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    author: "User" = Relationship(back_populates="posts")
    subject: Optional["Subject"] = Relationship(back_populates="posts")
    comments: List["Comment"] = Relationship(back_populates="post")

class Comment(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    post_id: int = Field(foreign_key="post.id")
    author_id: int = Field(foreign_key="user.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    post: Post = Relationship(back_populates="comments")
    author: "User" = Relationship(back_populates="comments")

class Notification(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    title: str
    message: str
    deep_link: Optional[str] = None
    is_read: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Schedule(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    subject_id: int = Field(foreign_key="subject.id")
    day_of_week: int # 0-6
    start_time: str # "HH:MM"
    end_time: str
    location: str
    type: str # "Lecture" or "Section"
