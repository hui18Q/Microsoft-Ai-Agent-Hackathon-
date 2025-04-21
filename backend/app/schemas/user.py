from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str
    verification_code: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    
    class Config:
        orm_mode = True

class EmailVerificationRequest(BaseModel):
    email: EmailStr

class VerificationRequest(BaseModel):
    email: EmailStr
    code: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    old_password: str
    new_password: str

class ResetPasswordByCodeRequest(BaseModel):
    email: EmailStr
    verification_code: str
    new_password: str 