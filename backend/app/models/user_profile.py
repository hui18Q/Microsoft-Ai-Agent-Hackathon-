from sqlalchemy import Column, Integer, String, Boolean, Date, JSON, ForeignKey, Table, Text, DateTime
from sqlalchemy.orm import relationship
from app.db.database import Base
from app.models.user import User  # 导入现有用户模型
from typing import List, Optional, Dict, Any
from datetime import datetime

class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    
    # 基本个人信息
    full_name = Column(String(255))
    birth_date = Column(Date)
    gender = Column(String(50))
    id_number = Column(String(50))  # 身份证号码
    
    # 联系信息
    phone_number = Column(String(50))
    alternative_phone = Column(String(50))
    address = Column(Text)
    city = Column(String(100))
    state = Column(String(100))
    postal_code = Column(String(20))
    country = Column(String(100))
    
    # 特定需求
    preferred_language = Column(String(50), default="en")
    accessibility_needs = Column(JSON)  # 无障碍需求
    
    # 财务信息
    income = Column(String(50))  # 收入范围
    employment_status = Column(String(100))
    
    # 元数据
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关联关系
    user = relationship("User", back_populates="profile")
    interaction_history = relationship("UserInteraction", back_populates="user_profile")
    application_history = relationship("ApplicationRecord", back_populates="user_profile")
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "user_id": self.user_id,
            "full_name": self.full_name,
            "birth_date": self.birth_date.isoformat() if self.birth_date else None,
            "gender": self.gender,
            "id_number": self.id_number,
            "phone_number": self.phone_number,
            "address": self.address,
            "city": self.city,
            "state": self.state,
            "postal_code": self.postal_code,
            "country": self.country,
            "preferred_language": self.preferred_language,
            "accessibility_needs": self.accessibility_needs,
            "income": self.income,
            "employment_status": self.employment_status
        }

# 修改现有User模型，添加关联
User.profile = relationship("UserProfile", uselist=False, back_populates="user")

class UserInteraction(Base):
    """用户交互历史记录"""
    __tablename__ = "user_interactions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_profile_id = Column(Integer, ForeignKey("user_profiles.id"))
    
    interaction_type = Column(String(50))  # chat, form_filling, document, etc.
    content = Column(Text)  # 交互内容
    interaction_metadata = Column(JSON)  # 额外元数据
    
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    user_profile = relationship("UserProfile", back_populates="interaction_history")

class UserPreference(Base):
    """用户偏好设置"""
    __tablename__ = "user_preferences"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    
    notification_preferences = Column(JSON)  # 通知偏好
    ui_preferences = Column(JSON)  # UI偏好
    privacy_settings = Column(JSON)  # 隐私设置
    
    user = relationship("User")

class ApplicationRecord(Base):
    """用户申请记录"""
    __tablename__ = "application_records"
    
    id = Column(Integer, primary_key=True, index=True)
    user_profile_id = Column(Integer, ForeignKey("user_profiles.id"))
    aid_program_id = Column(Integer, ForeignKey("aid_programs.id"))
    
    status = Column(String(50))  # 申请状态：draft, submitted, approved, rejected, etc.
    application_data = Column(JSON)  # 申请数据
    submission_date = Column(DateTime)
    
    # 跟踪信息
    reference_number = Column(String(100))
    notes = Column(Text)
    
    # 关联关系
    user_profile = relationship("UserProfile", back_populates="application_history")
    aid_program = relationship("AidProgram")