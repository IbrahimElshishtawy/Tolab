from sqlmodel import Session, create_engine, select
from models import User, UserRole, Subject, Enrollment, Task, Lecture, Section
from datetime import datetime, timedelta
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")

sqlite_url = "sqlite:///./lms.db"
engine = create_engine(sqlite_url)

def get_password_hash(password):
    return pwd_context.hash(password)

def seed_data():
    with Session(engine) as session:
        # Check if users already exist
        if session.exec(select(User)).first():
            print("Database already seeded.")
            return

        print("Seeding database...")

        # 1. Create Users
        it_admin = User(
            email="it@lms.com",
            full_name="IT Admin",
            hashed_password=get_password_hash("password123"),
            role=UserRole.IT_ADMIN
        )
        doctor = User(
            email="doctor@lms.com",
            full_name="Dr. Ahmed Ali",
            hashed_password=get_password_hash("password123"),
            role=UserRole.DOCTOR
        )
        assistant = User(
            email="ta@lms.com",
            full_name="Eng. Sara Mohamed",
            hashed_password=get_password_hash("password123"),
            role=UserRole.ASSISTANT
        )
        student = User(
            email="student@lms.com",
            full_name="Youssef Mansour",
            hashed_password=get_password_hash("password123"),
            role=UserRole.STUDENT
        )

        session.add(it_admin)
        session.add(doctor)
        session.add(assistant)
        session.add(student)
        session.commit()

        # 2. Create Subjects
        subject1 = Subject(
            code="CS101",
            name="Introduction to Computer Science",
            description="Basics of computing and programming.",
            doctor_id=doctor.id
        )
        subject2 = Subject(
            code="SWE311",
            name="Software Engineering",
            description="Lifecycle, patterns, and architecture.",
            doctor_id=doctor.id
        )
        session.add(subject1)
        session.add(subject2)
        session.commit()

        # 3. Enroll Student
        enrollment = Enrollment(student_id=student.id, subject_id=subject1.id)
        session.add(enrollment)

        # 4. Add Content
        lecture = Lecture(
            title="Lecture 1: Intro",
            subject_id=subject1.id,
            content_url="https://example.com/lec1.pdf"
        )
        section = Section(
            title="Lab 1: Hello World",
            subject_id=subject1.id,
            assistant_id=assistant.id,
            content_url="https://example.com/lab1.pdf"
        )
        session.add(lecture)
        session.add(section)

        # 5. Add Task
        task = Task(
            title="First Assignment",
            description="Submit your first python script.",
            due_date=datetime.utcnow() + timedelta(days=7),
            subject_id=subject1.id
        )
        session.add(task)

        session.commit()
        print("Seeding completed successfully.")

if __name__ == "__main__":
    seed_data()
