from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Task(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    description: str
    due_date: datetime
    subject_id: int = Field(foreign_key="subject.id", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    subject: "Subject" = Relationship(back_populates="tasks")
    submissions: List["Submission"] = Relationship(back_populates="task")

class Submission(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    task_id: int = Field(foreign_key="task.id", index=True)
    student_id: int = Field(foreign_key="user.id", index=True)
    file_url: str
    submitted_at: datetime = Field(default_factory=datetime.utcnow)
    grade: Optional[float] = None
    feedback_comment: Optional[str] = None
    graded_at: Optional[datetime] = None
    graded_by: Optional[int] = Field(default=None, foreign_key="user.id")

    # Relationship
    task: Task = Relationship(back_populates="submissions")
