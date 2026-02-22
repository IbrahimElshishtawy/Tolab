from typing import List, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select, func, or_
from api import deps, schemas
from models import User, UserRole, Department, AcademicYear, Subject, SystemSettings, Enrollment, Schedule
from core import security

router = APIRouter()

def check_admin(current_user: User = Depends(deps.get_current_active_user)):
    if current_user.role != UserRole.IT_ADMIN:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    return current_user

@router.get("/students", response_model=schemas.Page[User])
def read_students(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    department_id: Optional[int] = None,
    academic_year_id: Optional[int] = None,
    status: Optional[str] = None,
) -> Any:
    statement = select(User).where(User.role == UserRole.STUDENT)

    if search:
        search_filter = or_(
            User.full_name.ilike(f"%{search}%"),
            User.email.ilike(f"%{search}%"),
            User.student_code.ilike(f"%{search}%")
        )
        statement = statement.where(search_filter)

    if department_id:
        statement = statement.where(User.department_id == department_id)
    if academic_year_id:
        statement = statement.where(User.academic_year_id == academic_year_id)
    if status:
        statement = statement.where(User.enrollment_status == status)

    total = db.exec(select(func.count()).select_from(statement.subquery())).one()
    items = db.exec(statement.offset((page - 1) * size).limit(size)).all()

    return {
        "items": items,
        "total": total,
        "page": page,
        "size": size
    }

@router.post("/students", response_model=User)
def create_student(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    user_in: schemas.UserCreate
) -> Any:
    user = db.exec(select(User).where(User.email == user_in.email)).first()
    if user:
        raise HTTPException(status_code=400, detail="User with this email already exists")

    if user_in.student_code:
        user_code = db.exec(select(User).where(User.student_code == user_in.student_code)).first()
        if user_code:
            raise HTTPException(status_code=400, detail="Student code already exists")

    db_obj = User(
        email=user_in.email,
        full_name=user_in.full_name,
        hashed_password=security.get_password_hash(user_in.password),
        role=UserRole.STUDENT,
        student_code=user_in.student_code,
        national_id=user_in.national_id,
        dob=user_in.dob,
        nationality=user_in.nationality,
        gender=user_in.gender,
        department_id=user_in.department_id,
        academic_year_id=user_in.academic_year_id,
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

# Academic Structure CRUD

@router.get("/departments", response_model=List[Department])
def read_departments(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
) -> Any:
    return db.exec(select(Department)).all()

@router.post("/departments", response_model=Department)
def create_department(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    dept_in: schemas.DepartmentCreate
) -> Any:
    db_obj = Department(**dept_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.get("/academic-years", response_model=List[AcademicYear])
def read_academic_years(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
) -> Any:
    return db.exec(select(AcademicYear)).all()

@router.post("/academic-years", response_model=AcademicYear)
def create_academic_year(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    year_in: schemas.AcademicYearCreate
) -> Any:
    db_obj = AcademicYear(**year_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

# Schedule & Settings

@router.get("/schedule", response_model=List[Schedule])
def read_schedule_admin(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
) -> Any:
    return db.exec(select(Schedule)).all()

@router.post("/schedule", response_model=Schedule)
def create_schedule(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    schedule_in: Schedule
) -> Any:
    db.add(schedule_in)
    db.commit()
    db.refresh(schedule_in)
    return schedule_in

@router.get("/settings", response_model=SystemSettings)
def read_settings(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
) -> Any:
    settings = db.exec(select(SystemSettings)).first()
    if not settings:
        # Create default
        settings = SystemSettings()
        db.add(settings)
        db.commit()
        db.refresh(settings)
    return settings

@router.patch("/settings", response_model=SystemSettings)
def update_settings(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    settings_in: schemas.SystemSettingsUpdate
) -> Any:
    settings = db.exec(select(SystemSettings)).first()
    if not settings:
        settings = SystemSettings()

    update_data = settings_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(settings, field, update_data[field])

    db.add(settings)
    db.commit()
    db.refresh(settings)
    return settings

@router.get("/subjects", response_model=List[Subject])
def read_subjects_admin(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
) -> Any:
    return db.exec(select(Subject)).all()

@router.post("/subjects", response_model=Subject)
def create_subject(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    subject_in: schemas.SubjectCreate
) -> Any:
    db_obj = Subject(**subject_in.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

# Enrollment & Assignment

@router.get("/students/{student_id}/enrollments", response_model=List[Enrollment])
def read_student_enrollments(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    student_id: int = None
) -> Any:
    return db.exec(select(Enrollment).where(Enrollment.student_id == student_id)).all()

@router.post("/enrollments", response_model=List[Enrollment])
def enroll_student_in_subjects(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    student_id: int,
    subject_ids: List[int]
) -> Any:
    student = db.get(User, student_id)
    if not student or student.role != UserRole.STUDENT:
        raise HTTPException(status_code=404, detail="Student not found")

    # Remove old enrollments not in new list
    statement = select(Enrollment).where(Enrollment.student_id == student_id)
    existing_enrollments = db.exec(statement).all()
    for enr in existing_enrollments:
        if enr.subject_id not in subject_ids:
            db.delete(enr)

    # Add new enrollments
    existing_subject_ids = [enr.subject_id for enr in existing_enrollments]
    for subject_id in subject_ids:
        if subject_id not in existing_subject_ids:
            enr = Enrollment(student_id=student_id, subject_id=subject_id)
            db.add(enr)

    db.commit()
    return db.exec(select(Enrollment).where(Enrollment.student_id == student_id)).all()

@router.post("/assign-staff", response_model=Subject)
def assign_staff_to_subject(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    subject_id: int,
    staff_id: int,
    role: UserRole
) -> Any:
    subject = db.get(Subject, subject_id)
    if not subject:
        raise HTTPException(status_code=404, detail="Subject not found")

    staff = db.get(User, staff_id)
    if not staff or staff.role != role:
        raise HTTPException(status_code=404, detail="Staff member not found or role mismatch")

    if role == UserRole.DOCTOR:
        subject.doctor_id = staff_id
    # If we had assistant_id in Subject, we'd set it here.
    # Currently assistants are assigned to Sections, which are created by doctors/admins.
    # UC-7 says "Assign staff member to Subject".

    db.add(subject)
    db.commit()
    db.refresh(subject)
    return subject

@router.get("/staff", response_model=schemas.Page[User])
def read_staff(
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    role: Optional[UserRole] = None
) -> Any:
    statement = select(User).where(or_(User.role == UserRole.DOCTOR, User.role == UserRole.ASSISTANT))
    if role:
        statement = statement.where(User.role == role)

    total = db.exec(select(func.count()).select_from(statement.subquery())).one()
    items = db.exec(statement.offset((page - 1) * size).limit(size)).all()

    return {
        "items": items,
        "total": total,
        "page": page,
        "size": size
    }

@router.get("/users/{user_id}", response_model=User)
def read_user(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    user_id: int
) -> Any:
    db_obj = db.get(User, user_id)
    if not db_obj:
        raise HTTPException(status_code=404, detail="User not found")
    return db_obj

@router.patch("/users/{user_id}", response_model=User)
def update_user(
    *,
    db: Session = Depends(deps.get_db),
    admin: User = Depends(check_admin),
    user_id: int,
    user_in: schemas.UserUpdate
) -> Any:
    db_obj = db.get(User, user_id)
    if not db_obj:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = user_in.dict(exclude_unset=True)
    for field in update_data:
        setattr(db_obj, field, update_data[field])

    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj
