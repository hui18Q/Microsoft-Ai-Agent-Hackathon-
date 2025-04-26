from sqlalchemy.orm import Session
from fastapi import UploadFile
from typing import List, Optional, Dict, Any
import os
import uuid
from datetime import datetime
import aiofiles
import json

from app.models.form_template import FormSession
from app.models.aid_program import AidProgram

class DocumentService:
    def __init__(self, db: Session):
        self.db = db
        # 文档存储目录
        self.document_dir = os.getenv("DOCUMENT_STORAGE_PATH", "./documents")
        os.makedirs(self.document_dir, exist_ok=True)
    
    async def generate_document(self, session_id: int, document_type: str = "application") -> Dict[str, Any]:
        """根据已完成的表单生成申请文档"""
        # 获取表单会话
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "表单会话不存在"
            }
        
        if not session.is_completed:
            return {
                "success": False,
                "message": "表单尚未完成"
            }
        
        # 获取援助项目信息
        template = self.db.query(FormTemplate).filter(FormTemplate.id == session.form_template_id).first()
        if not template:
            return {
                "success": False,
                "message": "表单模板不存在"
            }
        
        program = None
        if template.aid_program_id:
            program = self.db.query(AidProgram).filter(AidProgram.id == template.aid_program_id).first()
        
        # 生成文档标识符
        document_id = str(uuid.uuid4())
        
        # 生成文档内容
        document_content = self._generate_document_content(
            session=session,
            template=template,
            program=program,
            document_type=document_type
        )
        
        # 保存文档
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        self._save_document_as_pdf(document_content, document_path)
        
        # 创建文档记录
        document_info = {
            "id": document_id,
            "user_id": session.user_id,
            "session_id": session.id,
            "program_id": template.aid_program_id,
            "document_type": document_type,
            "created_at": datetime.utcnow().isoformat(),
            "filename": self._generate_filename(program, document_type)
        }
        
        # 保存元数据
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        with open(metadata_path, 'w') as f:
            json.dump(document_info, f)
        
        return {
            "success": True,
            "document_id": document_id,
            "message": "文档已生成",
            **document_info
        }
    
    def get_document_path(self, document_id: str) -> Optional[str]:
        """获取文档文件路径"""
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        if os.path.exists(document_path):
            return document_path
        return None
    
    def get_document_filename(self, document_id: str) -> str:
        """获取文档文件名"""
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        if os.path.exists(metadata_path):
            with open(metadata_path, 'r') as f:
                metadata = json.load(f)
                return metadata.get("filename", f"{document_id}.pdf")
        return f"{document_id}.pdf"
    
    async def analyze_document(self, file: UploadFile) -> Dict[str, Any]:
        """分析上传的文档，提取关键信息"""
        # 保存上传的文件
        temp_file_path = os.path.join(self.document_dir, f"temp_{uuid.uuid4()}.pdf")
        
        async with aiofiles.open(temp_file_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        try:
            # 这里可以调用文档分析API或库
            # 简单模拟分析结果
            analysis_result = {
                "document_type": "official_letter",
                "sender": "社会福利部门",
                "recipient": "申请人",
                "date": datetime.now().isoformat(),
                "key_items": [
                    "申请要求",
                    "截止日期",
                    "联系方式"
                ],
                "summary": "这是一封关于社会福利申请的官方信件，要求申请人在规定日期前提交相关材料。",
                "suggested_actions": [
                    "准备个人身份证明",
                    "填写申请表格",
                    "提交收入证明"
                ]
            }
            
            return {
                "success": True,
                "analysis": analysis_result
            }
        finally:
            # 清理临时文件
            if os.path.exists(temp_file_path):
                os.remove(temp_file_path)
    
    def get_document_templates(self, aid_program_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """获取可用的文档模板"""
        # 这里可以从数据库或文件系统中读取文档模板
        # 简单模拟模板列表
        templates = [
            {
                "id": "application_form",
                "name": "申请表格",
                "description": "标准申请表格模板",
                "document_type": "application"
            },
            {
                "id": "proof_of_eligibility",
                "name": "资格证明",
                "description": "证明申请人符合条件的文档",
                "document_type": "proof"
            },
            {
                "id": "income_statement",
                "name": "收入证明",
                "description": "申请人收入情况说明",
                "document_type": "statement"
            }
        ]
        
        if aid_program_id is not None:
            # 如果指定了援助项目，筛选相关模板
            program = self.db.query(AidProgram).filter(AidProgram.id == aid_program_id).first()
            if program:
                # 这里可以根据项目特性筛选模板
                pass
        
        return templates
    
    async def preview_document(self, session_id: int, document_type: str = "application") -> Dict[str, Any]:
        """预览将要生成的文档"""
        # 获取表单会话
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "表单会话不存在"
            }
        
        # 获取援助项目信息
        template = self.db.query(FormTemplate).filter(FormTemplate.id == session.form_template_id).first()
        if not template:
            return {
                "success": False,
                "message": "表单模板不存在"
            }
        
        program = None
        if template.aid_program_id:
            program = self.db.query(AidProgram).filter(AidProgram.id == template.aid_program_id).first()
        
        # 生成预览内容
        document_content = self._generate_document_content(
            session=session,
            template=template,
            program=program,
            document_type=document_type
        )
        
        return {
            "success": True,
            "preview_content": document_content
        }
    
    async def upload_completed_document(self, file: UploadFile, session_id: int) -> Dict[str, Any]:
        """上传已完成的文档"""
        # 获取表单会话
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "表单会话不存在"
            }
        
        # 生成文档标识符
        document_id = str(uuid.uuid4())
        
        # 保存上传的文件
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        
        async with aiofiles.open(document_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # 创建文档记录
        document_info = {
            "id": document_id,
            "user_id": session.user_id,
            "session_id": session.id,
            "document_type": "uploaded",
            "created_at": datetime.utcnow().isoformat(),
            "filename": file.filename or f"{document_id}.pdf",
            "original_filename": file.filename
        }
        
        # 保存元数据
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        with open(metadata_path, 'w') as f:
            json.dump(document_info, f)
        
        return {
            "success": True,
            "document_id": document_id,
            "message": "文档已上传",
            **document_info
        }
    
    async def explain_document(self, file: UploadFile, preferred_language: Optional[str] = None) -> Dict[str, Any]:
        """解释上传的文档内容，使用简单语言"""
        # 保存上传的文件
        temp_file_path = os.path.join(self.document_dir, f"temp_{uuid.uuid4()}.pdf")
        
        async with aiofiles.open(temp_file_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # try:
        #     # 这里可以调用文档分析