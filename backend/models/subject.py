from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class Enrollment(SQLModel, table=True):
    student_id: int = Field(foreign_key="user.id", primary_key=True, index=True)
    subject_id: int = Field(foreign_key="subject.id", primary_key=True, index=True)
    enrolled_at: datetime = Field(default_factory=datetime.utcnow)

    # Relationships
    student: "User" = Relationship(back_populates="enrollments")
    subject: "Subject" = Relationship(back_populates="enrollments")

class Subject(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    code: str = Field(index=True, unique=True)
    name: str
    description: Optional[str] = None
    doctor_id: int = Field(foreign_key="user.id")

    # Relationships
    doctor: "User" = Relationship(back_populates="subjects_taught")
    enrollments: List[Enrollment] = Relationship(back_populates="subject")
    lectures: List["Lecture"] = Relationship(back_populates="subject")
    sections: List["Section"] = Relationship(back_populates="subject")
    tasks: List["Task"] = Relationship(back_populates="subject")
    posts: List["Post"] = Relationship(back_populates="subject")
    announcements: List["Announcement"] = Relationship(back_populates="subject")
    attendance_sessions: List["AttendanceSession"] = Relationship(back_populates="subject")
