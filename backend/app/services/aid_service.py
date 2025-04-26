from sqlalchemy.orm import Session
from sqlalchemy import func, or_
from typing import List, Optional, Dict, Any
from datetime import datetime

from app.models.aid_program import AidProgram, Tag, Region
from app.models.user_profile import UserProfile
from app.schemas.aid import AidProgramCreate

class AidService:
    def __init__(self, db: Session):
        self.db = db

    def get_aid_programs(
        self, 
        skip: int = 0, 
        limit: int = 100, 
        program_type: Optional[str] = None,
        tag: Optional[str] = None,
        region: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """获取援助项目列表，支持筛选"""
        query = self.db.query(AidProgram).filter(AidProgram.is_active == True)
        
        if program_type:
            query = query.filter(AidProgram.program_type == program_type)
            
        if tag:
            query = query.join(AidProgram.tags).filter(Tag.name == tag)
            
        if region:
            query = query.join(AidProgram.regions).filter(Region.name == region)
            
        # 按优先级排序
        query = query.order_by(AidProgram.priority.desc())
        
        programs = query.offset(skip).limit(limit).all()
        # 使用 to_dict 方法
        return [program.to_dict() for program in programs]

    def get_aid_program_by_id(self, program_id: int) -> Optional[Dict[str, Any]]:
        """根据ID获取援助项目"""
        program = self.db.query(AidProgram).filter(
            AidProgram.id == program_id,
            AidProgram.is_active == True
        ).first()
        if not program:
            return None
    
        # 转换为符合 schema 的字典
        return {
            "id": program.id,
            "code": program.code,
            "name": program.name,
            "program_type": program.program_type,
            "short_description": program.short_description,
            "full_description": program.full_description,
            "benefit_amount": program.benefit_amount,
            "eligibility_criteria": program.eligibility_criteria,
            "application_process": program.application_process,
            "application_url": program.application_url,
            "application_phone": program.application_phone,
            "application_email": program.application_email,
            "priority": program.priority,
            "tags": [tag.name for tag in program.tags],
            "regions": [region.name for region in program.regions],
            "created_at": program.created_at,
            "updated_at": program.updated_at
        }
    def get_tags(self, category: Optional[str] = None) -> List[Tag]:
        """获取所有标签，可按类别筛选"""
        query = self.db.query(Tag)
        if category:
            query = query.filter(Tag.category == category)
        return query.all()

    def get_regions(self, country: Optional[str] = None) -> List[Region]:
        """获取所有地区，可按国家筛选"""
        query = self.db.query(Region)
        if country:
            query = query.filter(Region.country == country)
        return query.all()

    def recommend_aid_programs(self, user_id: int, limit: int = 5) -> List[Dict[str, Any]]:
        """根据用户信息推荐援助项目"""
        # 获取用户信息
        user_profile = self.db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        
        if not user_profile:
            # 如果找不到用户档案，返回按优先级排序的默认结果
            programs = self.db.query(AidProgram).filter(
                AidProgram.is_active == True
            ).order_by(AidProgram.priority.desc()).limit(limit).all()
            return [program.to_dict() for program in programs]
        
        # 基于用户信息构建筛选条件
        query = self.db.query(AidProgram).filter(AidProgram.is_active == True)
        
        # 年龄相关推荐
        if user_profile.birth_date:
            age = self._calculate_age(user_profile.birth_date)
            query = query.join(AidProgram.tags).filter(
                or_(
                    Tag.name.ilike(f"%senior%") if age >= 60 else False,
                    Tag.name.ilike(f"%adult%") if 18 <= age < 60 else False,
                    Tag.name.ilike(f"%youth%") if age < 18 else False
                )
            )
        
        # 收入相关推荐
        if user_profile.income:
            query = query.join(AidProgram.tags).filter(
                Tag.name.ilike(f"%low-income%") if "low" in user_profile.income.lower() else True
            )
        
        # 按优先级排序
        query = query.order_by(AidProgram.priority.desc())
        
        programs = query.limit(limit).all()
        return [program.to_dict() for program in programs]
    
    def search_aid_programs(self, query: str) -> List[Dict[str, Any]]:
        """
        搜索援助项目
        
        参数:
            query (str): 搜索关键词，将在以下字段中进行模糊匹配:
                - 项目名称
                - 项目代码
                - 项目简短描述
                - 项目详细描述
        
        返回:
            List[Dict[str, Any]]: 符合搜索条件的援助项目列表，每个项目包含完整的信息
            包括ID、名称、描述、标签、地区等。返回的是已经转换为字典的项目，
            便于API直接返回。
        """
        search_term = f"%{query}%"
        programs = self.db.query(AidProgram).filter(
            AidProgram.is_active == True,
            or_(
                AidProgram.name.ilike(search_term),
                AidProgram.short_description.ilike(search_term),
                AidProgram.full_description.ilike(search_term),
                AidProgram.code.ilike(search_term)
            )
        ).all()
        return [program.to_dict() for program in programs]
    
    def create_aid_program(self, program: AidProgramCreate) -> Dict[str, Any]:
        """创建新的援助项目"""
        db_program = AidProgram(
            code=program.code,
            name=program.name,
            program_type=program.program_type,
            short_description=program.short_description,
            full_description=program.full_description,
            benefit_amount=program.benefit_amount,
            eligibility_criteria=program.eligibility_criteria,
            application_process=program.application_process,
            application_url=program.application_url,
            application_phone=program.application_phone,
            application_email=program.application_email,
            priority=program.priority
        )
        
        self.db.add(db_program)
        self.db.commit()
        self.db.refresh(db_program)
        
        return db_program.to_dict()
    
    def _calculate_age(self, birth_date: datetime.date) -> int:
        """计算年龄"""
        today = datetime.now().date()
        return today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))