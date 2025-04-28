import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.config.email import EmailSettings
import random
import string
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.models.user import VerificationCode
import logging

class EmailService:
    def __init__(self):
        self.settings = EmailSettings()
    
    def generate_verification_code(self) -> str:
        """Generate 6-digit verification code"""
        return ''.join(random.choices(string.digits, k=6))
    
    async def send_email_with_code(self, to_email: str, code: str, is_password_reset: bool = False) -> bool:
        """Send email with verification code, can be used for registration or password reset"""
        try:
            purpose = "Password Reset" if is_password_reset else "Verification"
            logging.info(f"Attempting to send {purpose} code to email: {to_email}")
            
            msg = MIMEMultipart()
            msg['From'] = self.settings.FROM_EMAIL
            msg['To'] = to_email
            msg['Subject'] = f"{purpose} Code"
            
            # Build email content
            extra_text = '<p>If you did not request a password reset, please ignore this email.</p>' if is_password_reset else ''
            body = f"""
            <html>
                <body>
                    <h2>{purpose} Code</h2>
                    <p>Your {purpose} code is: <strong>{code}</strong></p>
                    <p>The code will expire in 5 minutes.</p>
                    {extra_text}
                </body>
            </html>
            """
            
            msg.attach(MIMEText(body, 'html'))
            
            logging.info(f"Connecting to SMTP server: {self.settings.SMTP_SERVER}:{self.settings.SMTP_PORT}")
            
            with smtplib.SMTP(self.settings.SMTP_SERVER, self.settings.SMTP_PORT) as server:
                server.set_debuglevel(1)
                server.starttls()
                server.login(self.settings.SMTP_USERNAME, self.settings.SMTP_PASSWORD)
                server.send_message(msg)
                logging.info(f"{purpose} email sent successfully")
            
            return True
        except Exception as e:
            logging.error(f"Failed to send {purpose} email: {str(e)}")
            return False
    
    async def send_verification_email(self, to_email: str, code: str) -> bool:
        """Send verification code email"""
        return await self.send_email_with_code(to_email, code, is_password_reset=False)
    
    async def send_password_reset_email(self, to_email: str, code: str) -> bool:
        """Send password reset email"""
        return await self.send_email_with_code(to_email, code, is_password_reset=True)
    
    def can_send_verification_code(self, db: Session, email: str) -> bool:
        """Check if verification code can be sent (only once per minute)"""
        one_minute_ago = datetime.utcnow() - timedelta(minutes=1)
        recent_code = db.query(VerificationCode).filter(
            VerificationCode.email == email,
            VerificationCode.created_at >= one_minute_ago
        ).first()
        
        return recent_code is None
    
    def is_verification_code_valid(self, db: Session, email: str, code: str) -> bool:
        """Verify if the verification code is valid (valid for 5 minutes)"""
        five_minutes_ago = datetime.utcnow() - timedelta(minutes=5)
        valid_code = db.query(VerificationCode).filter(
            VerificationCode.email == email,
            VerificationCode.code == code,
            VerificationCode.created_at >= five_minutes_ago,
            VerificationCode.is_used == False
        ).first()
        
        return valid_code is not None
    
    def mark_verification_code_as_used(self, db: Session, email: str, code: str) -> bool:
        """Mark verification code as used"""
        valid_code = db.query(VerificationCode).filter(
            VerificationCode.email == email,
            VerificationCode.code == code,
            VerificationCode.is_used == False
        ).first()
        
        if valid_code:
            valid_code.is_used = True
            db.commit()
            return True
        
        return False 