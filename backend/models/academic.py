from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship

class Department(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    code: str = Field(index=True, unique=True)
    is_active: bool = Field(default=True)

    # Relationships
    users: List["User"] = Relationship(back_populates="department")

class AcademicYear(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    is_active: bool = Field(default=True)

    # Relationships
    users: List["User"] = Relationship(back_populates="academic_year")

class SystemSettings(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    default_language: str = Field(default="en")
    allow_students_change_lang: bool = Field(default=True)
    allow_staff_change_lang: bool = Field(default=True)
    enable_notifications: bool = Field(default=True)
    min_password_length: int = Field(default=8)
    require_complex_password: bool = Field(default=False)
    session_timeout_mins: int = Field(default=60)
