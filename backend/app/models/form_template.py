from sqlalchemy import Column, Integer, String, Boolean, Text, JSON, ForeignKey, Enum, DateTime
from sqlalchemy.orm import relationship
from app.db.database import Base
from typing import List, Optional, Dict, Any
from datetime import datetime
import enum

class FieldType(enum.Enum):
    TEXT = "text"
    NUMBER = "number"
    EMAIL = "email"
    PHONE = "phone"
    DATE = "date"
    SELECT = "select"
    CHECKBOX = "checkbox"
    RADIO = "radio"
    TEXTAREA = "textarea"
    FILE = "file"
    ADDRESS = "address"
    ID_NUMBER = "id_number"

class FormTemplate(Base):
    __tablename__ = "form_templates"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    
    # 关联的援助项目
    aid_program_id = Column(Integer, ForeignKey("aid_programs.id"))
    aid_program = relationship("AidProgram", back_populates="form_templates")
    
    # 表单结构
    sections = Column(JSON)  # 表单分区定义
    help_text = Column(Text)  # 整体帮助文本
    
    # 元信息
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关联关系
    fields = relationship("FormField", back_populates="form_template")
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "aid_program": self.aid_program.name if self.aid_program else None,
            "sections": self.sections,
            "help_text": self.help_text,
            "fields": [field.to_dict() for field in self.fields]
        }

class FormField(Base):
    """表单字段模型"""
    __tablename__ = "form_fields"
    
    id = Column(Integer, primary_key=True, index=True)
    form_template_id = Column(Integer, ForeignKey("form_templates.id"))
    
    name = Column(String(100), nullable=False)
    label = Column(String(255), nullable=False)
    field_type = Column(Enum(FieldType), nullable=False)
    section = Column(String(100))  # 所属分区
    order = Column(Integer, default=0)  # 显示顺序
    
    # 字段属性
    is_required = Column(Boolean, default=False)
    validation_rules = Column(JSON)  # 验证规则
    default_value = Column(String(255))
    placeholder = Column(String(255))
    help_text = Column(String(500))
    options = Column(JSON)  # 选项（用于select、radio等）
    
    # 自动填充规则
    autofill_source = Column(String(100))  # 从用户档案中的哪个字段自动填充
    
    # 元信息
    is_sensitive = Column(Boolean, default=False)  # 是否敏感信息
    
    # 关联关系
    form_template = relationship("FormTemplate", back_populates="fields")
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "label": self.label,
            "field_type": self.field_type.value,
            "section": self.section,
            "order": self.order,
            "is_required": self.is_required,
            "validation_rules": self.validation_rules,
            "default_value": self.default_value,
            "placeholder": self.placeholder,
            "help_text": self.help_text,
            "options": self.options,
            "is_sensitive": self.is_sensitive
        }

class FormSession(Base):
    """用户表单填写会话"""
    __tablename__ = "form_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    form_template_id = Column(Integer, ForeignKey("form_templates.id"))
    
    # 会话状态
    current_section = Column(String(100))
    completed_fields = Column(JSON)  # 已完成的字段
    form_data = Column(JSON)  # 填写的数据
    
    # 会话信息
    started_at = Column(DateTime, default=datetime.utcnow)
    last_activity = Column(DateTime, default=datetime.utcnow)
    is_completed = Column(Boolean, default=False)
    
    # 关联关系
    user = relationship("User")
    form_template = relationship("FormTemplate")