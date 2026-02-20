from enum import Enum
from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class UserRole(str, Enum):
    STUDENT = "student"
    DOCTOR = "doctor"
    ASSISTANT = "assistant"
    IT_ADMIN = "it"

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True, unique=True)
    full_name: str
    hashed_password: str
    role: UserRole = Field(default=UserRole.STUDENT)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    enrollments: List["Enrollment"] = Relationship(back_populates="student")
    posts: List["Post"] = Relationship(back_populates="author")
    comments: List["Comment"] = Relationship(back_populates="author")
