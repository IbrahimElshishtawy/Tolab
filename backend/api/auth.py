from datetime import timedelta, datetime
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, Body
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from api import deps
from core import security
from core.config import settings
from models import User, RefreshToken

router = APIRouter()

@router.post("/login/access-token")
def login_access_token(
    db: Session = Depends(deps.get_db), form_data: OAuth2PasswordRequestForm = Depends()
) -> Any:
    user = db.exec(select(User).where(User.email == form_data.username)).first()
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    elif not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    refresh_token_expires = timedelta(minutes=settings.REFRESH_TOKEN_EXPIRE_MINUTES)

    access_token = security.create_access_token(user.email, expires_delta=access_token_expires)
    refresh_token = security.create_refresh_token(user.email, expires_delta=refresh_token_expires)

    # Store refresh token jti
    from jose import jwt
    payload = jwt.decode(refresh_token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])

    db_refresh = RefreshToken(
        jti=payload["jti"],
        user_id=user.id,
        expires_at=datetime.utcnow() + refresh_token_expires
    )
    db.add(db_refresh)

    deps.log_action(db, user.id, "login", "auth")

    db.commit()

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "role": user.role
    }

@router.post("/auth/refresh")
def refresh_token(
    db: Session = Depends(deps.get_db),
    refresh_token: str = Body(..., embed=True)
) -> Any:
    from jose import jwt
    try:
        payload = jwt.decode(refresh_token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=400, detail="Invalid token type")
        email = payload.get("sub")
    except jwt.JWTError:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    db_token = db.exec(select(RefreshToken).where(RefreshToken.jti == payload.get("jti"))).first()
    if not db_token or db_token.is_revoked or db_token.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Refresh token expired or revoked")

    # Invalidate old token (Rotation)
    db_token.is_revoked = True
    db.add(db_token)

    user = db.exec(select(User).where(User.email == email)).first()
    access_token = security.create_access_token(user.email)
    new_refresh_token = security.create_refresh_token(user.email)

    # Store new refresh token
    new_payload = jwt.decode(new_refresh_token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])
    new_db_token = RefreshToken(
        jti=new_payload["jti"],
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(minutes=settings.REFRESH_TOKEN_EXPIRE_MINUTES)
    )
    db.add(new_db_token)
    db.commit()

    return {
        "access_token": access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer"
    }

@router.post("/auth/logout")
def logout(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user)
) -> Any:
    # Revoke all tokens for user
    tokens = db.exec(select(RefreshToken).where(RefreshToken.user_id == current_user.id)).all()
    for t in tokens:
        t.is_revoked = True
        db.add(t)

    deps.log_action(db, current_user.id, "logout", "auth")

    db.commit()
    return {"status": "success"}

@router.get("/me", response_model=User)
def read_user_me(
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get current user.
    """
    return current_user
