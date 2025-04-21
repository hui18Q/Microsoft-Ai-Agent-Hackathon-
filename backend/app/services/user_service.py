from sqlalchemy.orm import Session
from app.models.user import User, VerificationCode
from app.services.email_service import EmailService
from passlib.hash import bcrypt
from typing import Optional, Tuple, Dict, Any
from app.services.auth_service import AuthService

class UserService:
    def __init__(self):
        self.email_service = EmailService()
        self.auth_service = AuthService()

    def create_user(self, db: Session, email: str, username: str, password: str) -> User:
        """Create new user"""
        hashed_password = self.auth_service.get_password_hash(password)
        user = User(email=email, username=username, password=hashed_password)
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    
    def get_user_by_email(self, db: Session, email: str) -> Optional[User]:
        """Get user by email"""
        return db.query(User).filter(User.email == email).first()
    
    def get_user_by_username(self, db: Session, username: str) -> Optional[User]:
        """Get user by username"""
        return db.query(User).filter(User.username == username).first()
    
    async def send_verification_code(self, db: Session, email: str) -> Tuple[bool, str, str]:
        """Send verification code and save it to database"""
        # Check if verification code can be sent
        if not self.email_service.can_send_verification_code(db, email):
            return False, "Request too frequent, please try again later", ""
        
        # Generate verification code
        code = self.email_service.generate_verification_code()
        
        # Save verification code to database
        verification = VerificationCode(email=email, code=code)
        db.add(verification)
        db.commit()
        
        # Send verification code email
        sent = await self.email_service.send_verification_email(email, code)
        if not sent:
            return False, "Failed to send verification code", ""
        
        return True, "Verification code sent", code
    
    def verify_code(self, db: Session, email: str, code: str) -> bool:
        """Verify if the verification code is valid"""
        return self.email_service.is_verification_code_valid(db, email, code)
    
    def register_with_verification(self, db: Session, email: str, username: str, 
                                password: str, code: str) -> Tuple[bool, str, Optional[User]]:
        """Register user with verification code"""
        # Check if email already exists
        if self.get_user_by_email(db, email):
            return False, "Email already registered", None
        
        # Check if username already exists
        if self.get_user_by_username(db, username):
            return False, "Username already registered", None
        
        # Verify verification code
        if not self.verify_code(db, email, code):
            return False, "Invalid or expired verification code", None
        
        # Create user
        user = self.create_user(db, email, username, password)
        
        # Mark verification code as used
        self.email_service.mark_verification_code_as_used(db, email, code)
        
        # Set user email as verified
        user.is_verified = True
        db.commit()
        
        return True, "Registration successful", user
    
    # User login
    def authenticate_user(self, db: Session, email: str, password: str) -> Tuple[bool, str, Optional[Dict[str, Any]]]:
        """Authenticate user login"""
        user = self.get_user_by_email(db, email)
        
        # Check if user exists
        if not user:
            return False, "User does not exist", None
        
        # Check if password is correct
        if not self.auth_service.verify_password(password, user.password):
            return False, "Incorrect password", None
        
        # Check if user is verified
        if not user.is_verified:
            return False, "User email not verified", None
        
        # Check if user is active
        if not user.is_active:
            return False, "User is disabled", None
        
        # Generate access token
        access_token = self.auth_service.create_access_token(data={"sub": user.email})
        
        return True, "Login successful", {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user
        }
    
    # Forgot password, send verification code
    async def forgot_password(self, db: Session, email: str) -> Tuple[bool, str, str]:
        """Handle forgot password request, send verification code"""
        # Check if user exists
        user = self.get_user_by_email(db, email)
        if not user:
            return False, "User does not exist", ""
        
        # Check if verification code can be sent
        if not self.email_service.can_send_verification_code(db, email):
            return False, "Request too frequent, please try again later", ""
        
        # Generate verification code
        code = self.email_service.generate_verification_code()
        
        # Save verification code to database
        verification = VerificationCode(email=email, code=code)
        db.add(verification)
        db.commit()
        
        # Send password reset verification code email
        sent = await self.email_service.send_password_reset_email(email, code)
        if not sent:
            return False, "Failed to send verification code", ""
        
        return True, "Password reset verification code sent", code
    
    # Reset password
    def reset_password(self, db: Session, email: str, old_password: str, new_password: str) -> Tuple[bool, str]:
        """Reset user password"""
        # Check if user exists
        user = self.get_user_by_email(db, email)
        if not user:
            return False, "User does not exist"
        
        # Verify old password is correct
        if not self.auth_service.verify_password(old_password, user.password):
            return False, "Old password is incorrect"
        
        # Update password
        user.password = self.auth_service.get_password_hash(new_password)
        db.commit()
        
        return True, "Password reset successful"
    
    # Reset password by code
    def reset_password_by_code(self, db: Session, email: str, verification_code: str, new_password: str) -> Tuple[bool, str]:
        """Reset user password by verification code"""
        # Check if user exists
        user = self.get_user_by_email(db, email)
        if not user:
            return False, "User does not exist"
        
        # Verify verification code
        if not self.verify_code(db, email, verification_code):
            return False, "Invalid or expired verification code"
        
        # Update password
        user.password = self.auth_service.get_password_hash(new_password)
        db.commit()
        
        # Mark verification code as used
        self.email_service.mark_verification_code_as_used(db, email, verification_code)
        
        return True, "Password reset successful" 