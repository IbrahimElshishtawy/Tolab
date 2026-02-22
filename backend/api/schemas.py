from typing import Generic, List, TypeVar, Optional
from pydantic import BaseModel, EmailStr
from datetime import date
from models.user import UserRole

T = TypeVar("T")

class Page(BaseModel, Generic[T]):
    items: List[T]
    total: int
    page: int
    size: int

class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    role: UserRole = UserRole.STUDENT
    is_active: bool = True

class UserCreate(UserBase):
    password: str
    student_code: Optional[str] = None
    national_id: Optional[str] = None
    dob: Optional[date] = None
    nationality: Optional[str] = None
    gender: Optional[str] = None
    department_id: Optional[int] = None
    academic_year_id: Optional[int] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = None
    role: Optional[UserRole] = None
    student_code: Optional[str] = None
    national_id: Optional[str] = None
    dob: Optional[date] = None
    nationality: Optional[str] = None
    gender: Optional[str] = None
    department_id: Optional[int] = None
    academic_year_id: Optional[int] = None
    enrollment_status: Optional[str] = None

class DepartmentBase(BaseModel):
    name: str
    code: str
    is_active: bool = True

class DepartmentCreate(DepartmentBase):
    pass

class AcademicYearBase(BaseModel):
    name: str
    is_active: bool = True

class AcademicYearCreate(AcademicYearBase):
    pass

class SubjectCreate(BaseModel):
    name: str
    code: str
    description: Optional[str] = None
    doctor_id: int

class SystemSettingsUpdate(BaseModel):
    default_language: Optional[str] = None
    allow_students_change_lang: Optional[bool] = None
    allow_staff_change_lang: Optional[bool] = None
    enable_notifications: Optional[bool] = None
    min_password_length: Optional[int] = None
    require_complex_password: Optional[bool] = None
    session_timeout_mins: Optional[int] = None
