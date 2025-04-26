from pydantic import BaseModel, EmailStr, Field, validator
from typing import List, Optional, Dict, Any, Union
from datetime import date, datetime

class AccessibilityNeed(BaseModel):
    type: str  # visual, hearing, motor, cognitive
    level: str  # mild, moderate, severe
    description: Optional[str] = None

class NotificationPreference(BaseModel):
    email: bool = True
    sms: bool = False
    push: bool = False
    voice: bool = False

class UIPreference(BaseModel):
    theme: str = "default"
    font_size: str = "medium"
    high_contrast: bool = False
    voice_feedback: bool = False
    simplified_ui: bool = False

class PrivacySetting(BaseModel):
    share_profile: bool = False
    save_history: bool = True
    use_for_recommendations: bool = True
    allow_auto_fill: bool = True

class UserProfileBase(BaseModel):
    full_name: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[str] = None
    id_number: Optional[str] = None
    phone_number: Optional[str] = None
    alternative_phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    preferred_language: str = "en"
    accessibility_needs: Optional[List[AccessibilityNeed]] = None
    income: Optional[str] = None
    employment_status: Optional[str] = None

class UserProfileCreate(UserProfileBase):
    user_id: int

class UserProfileUpdate(UserProfileBase):
    pass

class UserProfile(UserProfileBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True

class UserInteractionBase(BaseModel):
    user_profile_id: int
    interaction_type: str
    content: str
    metadata: Optional[Dict[str, Any]] = None

class UserInteractionCreate(UserInteractionBase):
    pass

class UserInteraction(UserInteractionBase):
    id: int
    timestamp: datetime
    
    class Config:
        orm_mode = True

class UserPreferenceBase(BaseModel):
    notification_preferences: Optional[NotificationPreference] = None
    ui_preferences: Optional[UIPreference] = None
    privacy_settings: Optional[PrivacySetting] = None

class UserPreferenceCreate(UserPreferenceBase):
    user_id: int

class UserPreferenceUpdate(UserPreferenceBase):
    pass

class UserPreference(UserPreferenceBase):
    id: int
    user_id: int
    
    class Config:
        orm_mode = True

class ApplicationRecordBase(BaseModel):
    user_profile_id: int
    aid_program_id: int
    status: str = "draft"
    application_data: Dict[str, Any]
    submission_date: Optional[datetime] = None
    reference_number: Optional[str] = None
    notes: Optional[str] = None

class ApplicationRecordCreate(ApplicationRecordBase):
    pass

class ApplicationRecordUpdate(BaseModel):
    status: Optional[str] = None
    application_data: Optional[Dict[str, Any]] = None
    submission_date: Optional[datetime] = None
    reference_number: Optional[str] = None
    notes: Optional[str] = None

class ApplicationRecord(ApplicationRecordBase):
    id: int
    
    class Config:
        orm_mode = True

class UserProfileWithDetails(UserProfile):
    interaction_history: List[UserInteraction] = []
    application_history: List[ApplicationRecord] = []
    preferences: Optional[UserPreference] = None
    
    class Config:
        orm_mode = True