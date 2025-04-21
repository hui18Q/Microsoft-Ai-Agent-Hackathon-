from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.services.user_service import UserService
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse, EmailVerificationRequest, UserLogin, TokenResponse, ForgotPasswordRequest, ResetPasswordRequest, ResetPasswordByCodeRequest
from typing import Dict, Any
import os
from app.services.auth_service import AuthService, oauth2_scheme

router = APIRouter(prefix="/users", tags=["users"])

# Initialize user service
user_service = UserService()
auth_service = AuthService()

# Send verification code endpoint
@router.post("/send-verification-code")
async def send_verification_code(
    request: EmailVerificationRequest, 
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    # success, message, _ = await user_service.send_verification_code(db, request.email)
    success, message, code = await user_service.send_verification_code(db, request.email)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    # TODO: Return verification code for testing, remove later
    return {
        "message": message,
        "code": code  
    }

# User registration endpoint
@router.post("/register", response_model=UserResponse)
async def register_user(
    user_data: UserCreate, 
    db: Session = Depends(get_db)
) -> User:
    success, message, user = user_service.register_with_verification(
        db, 
        user_data.email, 
        user_data.username,
        user_data.password, 
        user_data.verification_code
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    return user

# User login endpoint
@router.post("/login", response_model=TokenResponse)
async def login(
    user_data: UserLogin,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    success, message, data = user_service.authenticate_user(
        db,
        user_data.email,
        user_data.password
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=message,
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    return data

# Get current user information
@router.get("/me", response_model=UserResponse)
async def get_current_user(
    current_user: User = Depends(auth_service.get_current_user)
) -> User:
    return current_user

# Forgot password, send verification code
@router.post("/forgot-password")
async def forgot_password(
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    success, message, code = await user_service.forgot_password(db, request.email)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    # TODO: Return verification code for testing, remove later
    return {
        "message": message,
        "code": code
    }

# Reset password
@router.post("/reset-password")
async def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    success, message = user_service.reset_password(
        db,
        request.email,
        request.old_password,
        request.new_password
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    return {"message": message}

# Reset password by verification code
@router.post("/reset-password-by-code")
async def reset_password_by_code(
    request: ResetPasswordByCodeRequest,
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    success, message = user_service.reset_password_by_code(
        db,
        request.email,
        request.verification_code,
        request.new_password
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )
    
    return {"message": message}
