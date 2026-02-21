from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Comment(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    post_id: int = Field(foreign_key="post.id")
    author_id: int = Field(foreign_key="user.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    post: "Post" = Relationship(back_populates="comments")
    author: "User" = Relationship(back_populates="comments")

class Reaction(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    post_id: int = Field(foreign_key="post.id")
    user_id: int = Field(foreign_key="user.id")
    type: str = Field(default="like")

    # Relationships
    post: "Post" = Relationship(back_populates="reactions")

class Post(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    content: str
    author_id: int = Field(foreign_key="user.id", index=True)
    subject_id: Optional[int] = Field(default=None, foreign_key="subject.id", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    author: "User" = Relationship(back_populates="posts")
    subject: Optional["Subject"] = Relationship(back_populates="posts")
    comments: List[Comment] = Relationship(back_populates="post")
    reactions: List[Reaction] = Relationship(back_populates="post")

class Notification(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", index=True)
    title: str
    message: str
    deep_link: Optional[str] = None
    is_read: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow, index=True)

class Announcement(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    subject_id: int = Field(foreign_key="subject.id", index=True)
    title: str
    body: str
    created_by: int = Field(foreign_key="user.id")
    pinned: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    subject: "Subject" = Relationship(back_populates="announcements")

class AttendanceSession(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    subject_id: int = Field(foreign_key="subject.id", index=True)
    type: str # "Lecture" or "Section"
    starts_at: datetime
    ends_at: datetime
    code: str
    created_by: int = Field(foreign_key="user.id")

    # Relationships
    subject: "Subject" = Relationship(back_populates="attendance_sessions")
    records: List["AttendanceRecord"] = Relationship(back_populates="session")

class AttendanceRecord(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    session_id: int = Field(foreign_key="attendancesession.id", index=True)
    student_id: int = Field(foreign_key="user.id", index=True)
    checked_in_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationship
    session: AttendanceSession = Relationship(back_populates="records")

class AuditLog(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: Optional[int] = Field(default=None, foreign_key="user.id")
    action: str
    resource: str
    resource_id: Optional[str] = None
    details: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Schedule(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    subject_id: int = Field(foreign_key="subject.id")
    day_of_week: int # 0-6
    start_time: str # "HH:MM"
    end_time: str
    location: str
    type: str # "Lecture" or "Section"

class Quiz(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    subject_id: int = Field(foreign_key="subject.id")
    start_at: datetime
    end_at: datetime
    duration_mins: int
    total_points: int

class QuizAttempt(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    quiz_id: int = Field(foreign_key="quiz.id")
    student_id: int = Field(foreign_key="user.id")
    started_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    score: Optional[int] = None
