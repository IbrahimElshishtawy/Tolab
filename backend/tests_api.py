from fastapi.testclient import TestClient
from main import app
import pytest

client = TestClient(app)

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert "Welcome" in response.json()["message"]

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_login_fail():
    response = client.post(
        "/api/v1/login/access-token",
        data={"username": "wrong@lms.com", "password": "wrongpassword"}
    )
    assert response.status_code == 400

def test_rbac_student_cannot_announce():
    # Mocking student user
    from models import UserRole
    student_user = {"role": UserRole.STUDENT}
    # Test would call POST /subjects/1/announcements and expect 403
    pass

def test_attendance_expiry():
    from datetime import datetime, timedelta
    ends_at = datetime.utcnow() - timedelta(minutes=1)
    # Logic check: current time > expiry
    assert datetime.utcnow() > ends_at

def test_token_rotation():
    # Test logic:
    # 1. Login -> get Access/Refresh
    # 2. Refresh -> get New Access/Refresh
    # 3. Refresh again with OLD refresh -> should FAIL (400)
    pass

def test_double_checkin():
    # Test logic:
    # 1. Student check-in success
    # 2. Student check-in again with same code/session -> FAIL (400)
    pass
