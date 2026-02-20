from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Task(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    description: str
    due_date: datetime
    subject_id: int = Field(foreign_key="subject.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    subject: "Subject" = Relationship(back_populates="tasks")
    submissions: List["Submission"] = Relationship(back_populates="task")

class Submission(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    task_id: int = Field(foreign_key="task.id")
    student_id: int = Field(foreign_key="user.id")
    file_url: str
    submitted_at: datetime = Field(default_factory=datetime.utcnow)
    grade: Optional[float] = None
    feedback: Optional[str] = None

    # Relationship
    task: Task = Relationship(back_populates="submissions")
