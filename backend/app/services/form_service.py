from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
from datetime import datetime

from app.models.form_template import FormTemplate, FormField, FormSession
from app.models.user_profile import UserProfile
from app.schemas.form import FormSessionCreate, FormSessionUpdate

class FormService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_form_templates(self, aid_program_id: Optional[int] = None) -> List[FormTemplate]:
        """Get list of form templates, can be filtered by aid program"""
        query = self.db.query(FormTemplate).filter(FormTemplate.is_active == True)
        
        if aid_program_id is not None:
            query = query.filter(FormTemplate.aid_program_id == aid_program_id)
            
        return query.all()
    
    def get_form_template(self, template_id: int) -> Optional[FormTemplate]:
        """Get detailed information for a specific form template"""
        return self.db.query(FormTemplate).filter(
            FormTemplate.id == template_id,
            FormTemplate.is_active == True
        ).first()
    
    def create_form_session(self, session_data: FormSessionCreate) -> FormSession:
        """Start a new form filling session"""
        # Get form template
        template = self.get_form_template(session_data.form_template_id)
        if not template:
            raise ValueError("Form template does not exist")
        
        # Find the first section
        first_section = None
        if template.sections and len(template.sections) > 0:
            sections = sorted(template.sections, key=lambda x: x.get('order', 0))
            first_section = sections[0].get('name')
        
        # Create session
        db_session = FormSession(
            user_id=session_data.user_id,
            form_template_id=session_data.form_template_id,
            current_section=first_section or session_data.current_section,
            completed_fields=session_data.completed_fields or [],
            form_data=session_data.form_data or {},
            started_at=datetime.utcnow(),
            last_activity=datetime.utcnow(),
            is_completed=False
        )
        
        self.db.add(db_session)
        self.db.commit()
        self.db.refresh(db_session)
        
        return db_session
    
    def get_form_session(self, session_id: int) -> Optional[FormSession]:
        """获取表单会话状态"""
        return self.db.query(FormSession).filter(FormSession.id == session_id).first()
    
    def update_form_session(self, session_id: int, update_data: FormSessionUpdate) -> Optional[FormSession]:
        """更新表单会话状态"""
        db_session = self.get_form_session(session_id)
        if not db_session:
            return None
        
        # 更新字段
        if update_data.current_section is not None:
            db_session.current_section = update_data.current_section
            
        if update_data.completed_fields is not None:
            db_session.completed_fields = update_data.completed_fields
            
        if update_data.form_data is not None:
            # 合并现有数据和新数据
            form_data = db_session.form_data or {}
            form_data.update(update_data.form_data)
            db_session.form_data = form_data
            
        if update_data.is_completed is not None:
            db_session.is_completed = update_data.is_completed
        
        # 更新最后活动时间
        db_session.last_activity = datetime.utcnow()
        
        self.db.commit()
        self.db.refresh(db_session)
        
        return db_session
    
    def get_form_fields(self, session_id: int, section: Optional[str] = None) -> List[FormField]:
        """获取表单字段，可按分区筛选"""
        db_session = self.get_form_session(session_id)
        if not db_session:
            raise ValueError("表单会话不存在")
        
        query = self.db.query(FormField).filter(
            FormField.form_template_id == db_session.form_template_id
        )
        
        if section:
            query = query.filter(FormField.section == section)
        elif db_session.current_section:
            # 如果未指定分区但会话有当前分区，则使用会话的当前分区
            query = query.filter(FormField.section == db_session.current_section)
        
        # 按显示顺序排序
        return query.order_by(FormField.order).all()
    
    def process_form_submission(self, session_id: int, field_updates: Dict[str, Any]) -> Dict[str, Any]:
        """处理表单提交"""
        db_session = self.get_form_session(session_id)
        if not db_session:
            raise ValueError("表单会话不存在")
        
        # 获取表单模板
        template = self.db.query(FormTemplate).filter(
            FormTemplate.id == db_session.form_template_id
        ).first()
        
        if not template:
            raise ValueError("表单模板不存在")
        
        # 验证字段更新
        errors = self._validate_field_updates(db_session, field_updates)
        if errors:
            return {
                "success": False,
                "errors": errors
            }
        
        # 更新表单数据
        form_data = db_session.form_data or {}
        form_data.update(field_updates)
        
        # 更新已完成字段
        completed_fields = set(db_session.completed_fields or [])
        completed_fields.update(field_updates.keys())
        
        # 确定下一个分区
        current_section = db_session.current_section
        next_section = self._get_next_section(template, current_section)
        
        # 更新会话
        db_session.form_data = form_data
        db_session.completed_fields = list(completed_fields)
        if next_section != current_section:
            db_session.current_section = next_section
        db_session.last_activity = datetime.utcnow()
        
        self.db.commit()
        
        # 获取下一分区的字段
        next_fields = []
        if next_section:
            next_fields = self.db.query(FormField).filter(
                FormField.form_template_id == template.id,
                FormField.section == next_section
            ).order_by(FormField.order).all()
        
        # 检查是否完成
        is_completed = not next_section
        if is_completed:
            db_session.is_completed = True
            self.db.commit()
        
        return {
            "success": True,
            "next_section": next_section,
            "next_fields": next_fields,
            "completed": is_completed,
            "errors": None
        }
    
    def auto_fill_form(
        self,
        form_template_id: int,
        user_id: int,
        sections: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """自动填充表单"""
        # 获取用户档案
        user_profile = self.db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not user_profile:
            return {
                "filled_fields": {},
                "missing_fields": []
            }
        
        # 获取表单字段
        query = self.db.query(FormField).filter(FormField.form_template_id == form_template_id)
        
        if sections:
            query = query.filter(FormField.section.in_(sections))
        
        form_fields = query.all()
        
        # 自动填充映射
        profile_data = user_profile.to_dict()
        filled_fields = {}
        missing_fields = []
        
        for field in form_fields:
            if field.autofill_source and field.autofill_source in profile_data:
                # 如果有自动填充来源并且用户档案中有对应数据
                filled_fields[field.name] = profile_data[field.autofill_source]
            else:
                # 尝试通过字段名称匹配
                if field.name in profile_data and profile_data[field.name] is not None:
                    filled_fields[field.name] = profile_data[field.name]
                else:
                    missing_fields.append(field.name)
        
        return {
            "filled_fields": filled_fields,
            "missing_fields": missing_fields
        }
    
    def complete_form(self, session_id: int) -> Dict[str, Any]:
        """完成表单并准备生成申请文档"""
        db_session = self.get_form_session(session_id)
        if not db_session:
            return {
                "success": False,
                "message": "表单会话不存在"
            }
        
        # 验证所有必填字段是否已填写
        missing_fields = self._check_required_fields(db_session)
        
        if missing_fields:
            return {
                "success": False,
                "message": "缺少必填字段",
                "missing_fields": missing_fields
            }
        
        # 标记表单为已完成
        db_session.is_completed = True
        db_session.last_activity = datetime.utcnow()
        
        self.db.commit()
        
        return {
            "success": True,
            "message": "表单已完成",
            "session_id": db_session.id,
            "form_data": db_session.form_data
        }
    
    def _validate_field_updates(self, session: FormSession, field_updates: Dict[str, Any]) -> Dict[str, str]:
        """Validate field updates"""
        errors = {}
        
        # Get field definitions
        fields = self.db.query(FormField).filter(
            FormField.form_template_id == session.form_template_id,
            FormField.name.in_(field_updates.keys())
        ).all()
        
        field_dict = {field.name: field for field in fields}
        
        for field_name, value in field_updates.items():
            if field_name not in field_dict:
                errors[field_name] = "Field does not exist"
                continue
            
            field = field_dict[field_name]
            
            # Check required fields
            if field.is_required and (value is None or value == ""):
                errors[field_name] = "This field is required"
                continue
            
            # Check validation rules
            if field.validation_rules and value is not None:
                for rule in field.validation_rules:
                    # Implementation of various validation rules
                    # Simple examples:
                    rule_type = rule.get("type")
                    rule_value = rule.get("value")
                    
                    if rule_type == "min" and isinstance(value, (int, float)) and value < rule_value:
                        errors[field_name] = rule.get("message", f"Value must be greater than or equal to {rule_value}")
                    
                    elif rule_type == "max" and isinstance(value, (int, float)) and value > rule_value:
                        errors[field_name] = rule.get("message", f"Value must be less than or equal to {rule_value}")
                    
                    elif rule_type == "min_length" and isinstance(value, str) and len(value) < rule_value:
                        errors[field_name] = rule.get("message", f"Length must be greater than or equal to {rule_value}")
                    
                    elif rule_type == "max_length" and isinstance(value, str) and len(value) > rule_value:
                        errors[field_name] = rule.get("message", f"Length must be less than or equal to {rule_value}")
        
        return errors
    
    def _get_next_section(self, template: FormTemplate, current_section: Optional[str]) -> Optional[str]:
        """确定下一个表单分区"""
        if not template.sections or not current_section:
            return None
        
        # 按顺序排列分区
        sections = sorted(template.sections, key=lambda x: x.get('order', 0))
        section_names = [s.get('name') for s in sections]
        
        if current_section not in section_names:
            return sections[0].get('name') if sections else None
        
        current_index = section_names.index(current_section)
        if current_index < len(section_names) - 1:
            return section_names[current_index + 1]
        
        return None  # 已是最后一个分区
    
    def _check_required_fields(self, session: FormSession) -> List[str]:
        """检查所有必填字段是否已填写"""
        # 获取所有必填字段
        required_fields = self.db.query(FormField).filter(
            FormField.form_template_id == session.form_template_id,
            FormField.is_required == True
        ).all()
        
        form_data = session.form_data or {}
        missing_fields = []
        
        for field in required_fields:
            if field.name not in form_data or form_data[field.name] is None or form_data[field.name] == "":
                missing_fields.append(field.name)
        
        return missing_fields