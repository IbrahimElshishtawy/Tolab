from enum import Enum
from typing import Optional, List
from datetime import datetime, date
from sqlmodel import SQLModel, Field, Relationship

class UserRole(str, Enum):
    STUDENT = "student"
    DOCTOR = "doctor"
    ASSISTANT = "assistant"
    IT_ADMIN = "it"

class RefreshToken(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    jti: str = Field(index=True, unique=True)
    user_id: int = Field(foreign_key="user.id")
    expires_at: datetime
    is_revoked: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationship
    user: "User" = Relationship(back_populates="refresh_tokens")

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True, unique=True)
    full_name: str
    hashed_password: str
    role: UserRole = Field(default=UserRole.STUDENT)
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    # Detailed Student/Staff Info (UC-3)
    student_code: Optional[str] = Field(default=None, index=True, unique=True)
    national_id: Optional[str] = Field(default=None, unique=True)
    dob: Optional[date] = Field(default=None)
    nationality: Optional[str] = Field(default=None)
    gender: Optional[str] = Field(default=None)

    # Academic Info (UC-5)
    department_id: Optional[int] = Field(default=None, foreign_key="department.id")
    academic_year_id: Optional[int] = Field(default=None, foreign_key="academicyear.id")
    enrollment_status: str = Field(default="Active") # Active, Suspended, Graduated, etc.
    year_of_admission: Optional[int] = Field(default=None)
    admission_type: Optional[str] = Field(default=None)

    # Relationships
    department: Optional["Department"] = Relationship(back_populates="users")
    academic_year: Optional["AcademicYear"] = Relationship(back_populates="users")
    enrollments: List["Enrollment"] = Relationship(back_populates="student")
    posts: List["Post"] = Relationship(back_populates="author")
    comments: List["Comment"] = Relationship(back_populates="author")
    refresh_tokens: List["RefreshToken"] = Relationship(back_populates="user")

    # Staff relationships
    subjects_taught: List["Subject"] = Relationship(back_populates="doctor")
    sections_taught: List["Section"] = Relationship(back_populates="assistant")
