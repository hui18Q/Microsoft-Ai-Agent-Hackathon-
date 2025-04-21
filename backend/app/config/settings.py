# app/config/settings.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://postgres:123456@db:5432/user_db"
    
    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
