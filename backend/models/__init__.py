from .user import User, UserRole
from .subject import Subject, Enrollment
from .content import Lecture, Section
from .task import Task, Submission
from .other import Post, Comment, Notification, Schedule

# This is needed for Alembic or SQLModel to see all tables
from sqlmodel import SQLModel
