from typing import Optional
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Lecture(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    content_url: Optional[str] = None
    subject_id: int = Field(foreign_key="subject.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationship
    subject: "Subject" = Relationship(back_populates="lectures")

class Section(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    content_url: Optional[str] = None
    subject_id: int = Field(foreign_key="subject.id")
    assistant_id: int = Field(foreign_key="user.id")
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationship
    subject: "Subject" = Relationship(back_populates="sections")
