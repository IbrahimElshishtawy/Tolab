from .user import User, UserRole, RefreshToken
from .subject import Subject, Enrollment
from .content import Lecture, Section
from .task import Task, Submission
from .other import Post, Comment, Notification, Schedule, Quiz, QuizAttempt, Reaction, Announcement, AttendanceSession, AttendanceRecord, AuditLog

# This is needed for Alembic or SQLModel to see all tables
from sqlmodel import SQLModel
