from pydantic_settings import BaseSettings
from typing import Optional

class EmailSettings(BaseSettings):
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    FROM_EMAIL: str = ""
    EMAIL_TEMPLATE_PATH: str = "app/templates/email"
    
    class Config:
        env_file = ".env"
        env_prefix = "EMAIL_"
        extra = "ignore"  