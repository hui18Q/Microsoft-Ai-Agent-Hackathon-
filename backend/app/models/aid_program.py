from sqlalchemy import Column, Integer, String, Float, Boolean, Text, JSON, ForeignKey, Table, DateTime
from sqlalchemy.orm import relationship
from app.db.database import Base
from typing import List, Optional, Dict, Any
from datetime import datetime

# 项目与标签的多对多关联表
aid_program_tag = Table(
    "aid_program_tag",
    Base.metadata,
    Column("aid_program_id", Integer, ForeignKey("aid_programs.id")),
    Column("tag_id", Integer, ForeignKey("tags.id"))
)

# 项目与地区的多对多关联表
aid_program_region = Table(
    "aid_program_region",
    Base.metadata,
    Column("aid_program_id", Integer, ForeignKey("aid_programs.id")),
    Column("region_id", Integer, ForeignKey("regions.id"))
)

class AidProgram(Base):
    __tablename__ = "aid_programs"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, index=True)  # 项目代码，如BWE-JKM
    name = Column(String(255), nullable=False)
    program_type = Column(String(50), nullable=False)  # 金融援助、医疗补助等
    
    # 详细信息
    short_description = Column(String(500))
    full_description = Column(Text)
    benefit_amount = Column(String(255))  # 福利金额描述
    
    # 结构化数据
    eligibility_criteria = Column(JSON)  # 存储资格条件列表
    application_process = Column(JSON)  # 申请步骤
    
    # 申请信息
    application_url = Column(String(255))
    application_phone = Column(String(50))
    application_email = Column(String(255))
    
    # 元信息
    priority = Column(Integer, default=0)  # 推荐排序优先级
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow) #TODO: 修改为当前时间
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关联关系
    tags = relationship("Tag", secondary=aid_program_tag, back_populates="aid_programs")
    regions = relationship("Region", secondary=aid_program_region, back_populates="aid_programs")
    form_templates = relationship("FormTemplate", back_populates="aid_program")
    
    def to_dict(self) -> Dict[str, Any]:
        """将模型转换为字典，便于API响应"""
        return {
            "id": self.id,
            "code": self.code,
            "name": self.name,
            "program_type": self.program_type,
            "short_description": self.short_description,
            "full_description": self.full_description,
            "benefit_amount": self.benefit_amount,
            "eligibility_criteria": self.eligibility_criteria,
            "application_process": self.application_process,
            "application_url": self.application_url,
            "priority": self.priority,
            "tags": [tag.name for tag in self.tags],
            "regions": [region.name for region in self.regions],
            "created_at": self.created_at,
            "updated_at": self.updated_at
        }

class Tag(Base):
    """标签模型，用于分类援助项目"""
    __tablename__ = "tags"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, index=True)
    description = Column(String(255))
    category = Column(String(50))  # 标签类别：人群、服务类型等
    
    aid_programs = relationship("AidProgram", secondary=aid_program_tag, back_populates="tags")

class Region(Base):
    """地区模型，用于地域限制"""
    __tablename__ = "regions"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, index=True)
    country = Column(String(100), index=True)
    code = Column(String(20), unique=True)  # 地区代码
    
    aid_programs = relationship("AidProgram", secondary=aid_program_region, back_populates="regions")