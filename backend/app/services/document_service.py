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
        # Document storage directory
        self.document_dir = os.getenv("DOCUMENT_STORAGE_PATH", "./documents")
        os.makedirs(self.document_dir, exist_ok=True)
    
    async def generate_document(self, session_id: int, document_type: str = "application") -> Dict[str, Any]:
        """Generate application document based on completed form"""
        # Get form session
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "Form session does not exist"
            }
        
        if not session.is_completed:
            return {
                "success": False,
                "message": "Form is not completed yet"
            }
        
        # Get aid program information
        template = self.db.query(FormTemplate).filter(FormTemplate.id == session.form_template_id).first()
        if not template:
            return {
                "success": False,
                "message": "Form template does not exist"
            }
        
        program = None
        if template.aid_program_id:
            program = self.db.query(AidProgram).filter(AidProgram.id == template.aid_program_id).first()
        
        # Generate document identifier
        document_id = str(uuid.uuid4())
        
        # Generate document content
        document_content = self._generate_document_content(
            session=session,
            template=template,
            program=program,
            document_type=document_type
        )
        
        # Save document
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        self._save_document_as_pdf(document_content, document_path)
        
        # Create document record
        document_info = {
            "id": document_id,
            "user_id": session.user_id,
            "session_id": session.id,
            "program_id": template.aid_program_id,
            "document_type": document_type,
            "created_at": datetime.utcnow().isoformat(),
            "filename": self._generate_filename(program, document_type)
        }
        
        # Save metadata
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        with open(metadata_path, 'w') as f:
            json.dump(document_info, f)
        
        return {
            "success": True,
            "document_id": document_id,
            "message": "Document generated",
            **document_info
        }
    
    def get_document_path(self, document_id: str) -> Optional[str]:
        """Get document file path"""
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        if os.path.exists(document_path):
            return document_path
        return None
    
    def get_document_filename(self, document_id: str) -> str:
        """Get document file name"""
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        if os.path.exists(metadata_path):
            with open(metadata_path, 'r') as f:
                metadata = json.load(f)
                return metadata.get("filename", f"{document_id}.pdf")
        return f"{document_id}.pdf"
    
    async def analyze_document(self, file: UploadFile) -> Dict[str, Any]:
        """Analyze uploaded document and extract key information"""
        # Save uploaded file
        temp_file_path = os.path.join(self.document_dir, f"temp_{uuid.uuid4()}.pdf")
        
        async with aiofiles.open(temp_file_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        try:
            # Here you can call document analysis API or library
            # Simple mock analysis result
            analysis_result = {
                "document_type": "official_letter",
                "sender": "Social Welfare Department",
                "recipient": "Applicant",
                "date": datetime.now().isoformat(),
                "key_items": [
                    "Application Requirements",
                    "Deadline",
                    "Contact Information"
                ],
                "summary": "This is an official letter regarding social welfare application, requiring the applicant to submit relevant materials before the specified date.",
                "suggested_actions": [
                    "Prepare personal identification",
                    "Fill out application form",
                    "Submit income proof"
                ]
            }
            
            return {
                "success": True,
                "analysis": analysis_result
            }
        finally:
            # Clean up temporary file
            if os.path.exists(temp_file_path):
                os.remove(temp_file_path)
    
    def get_document_templates(self, aid_program_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get available document templates"""
        # This can retrieve document templates from database or file system
        # Simple mock template list
        templates = [
            {
                "id": "application_form",
                "name": "Application Form",
                "description": "Standard application form template",
                "document_type": "application"
            },
            {
                "id": "proof_of_eligibility",
                "name": "Eligibility Proof",
                "description": "Document proving applicant meets eligibility criteria",
                "document_type": "proof"
            },
            {
                "id": "income_statement",
                "name": "Income Statement",
                "description": "Statement explaining applicant's income situation",
                "document_type": "statement"
            }
        ]
        
        if aid_program_id is not None:
            # If specified aid program, filter related templates
            program = self.db.query(AidProgram).filter(AidProgram.id == aid_program_id).first()
            if program:
                # Here you can filter templates based on program characteristics
                pass
        
        return templates
    
    async def preview_document(self, session_id: int, document_type: str = "application") -> Dict[str, Any]:
        """Preview document to be generated"""
        # Get form session
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "Form session does not exist"
            }
        
        # Get aid program information
        template = self.db.query(FormTemplate).filter(FormTemplate.id == session.form_template_id).first()
        if not template:
            return {
                "success": False,
                "message": "Form template does not exist"
            }
        
        program = None
        if template.aid_program_id:
            program = self.db.query(AidProgram).filter(AidProgram.id == template.aid_program_id).first()
        
        # Generate preview content
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
        """Upload completed document"""
        # Get form session
        session = self.db.query(FormSession).filter(FormSession.id == session_id).first()
        if not session:
            return {
                "success": False,
                "message": "Form session does not exist"
            }
        
        # Generate document identifier
        document_id = str(uuid.uuid4())
        
        # Save uploaded file
        document_path = os.path.join(self.document_dir, f"{document_id}.pdf")
        
        async with aiofiles.open(document_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # Create document record
        document_info = {
            "id": document_id,
            "user_id": session.user_id,
            "session_id": session.id,
            "document_type": "uploaded",
            "created_at": datetime.utcnow().isoformat(),
            "filename": file.filename or f"{document_id}.pdf",
            "original_filename": file.filename
        }
        
        # Save metadata
        metadata_path = os.path.join(self.document_dir, f"{document_id}.json")
        with open(metadata_path, 'w') as f:
            json.dump(document_info, f)
        
        return {
            "success": True,
            "document_id": document_id,
            "message": "Document uploaded",
            **document_info
        }
    
    async def explain_document(self, file: UploadFile, preferred_language: Optional[str] = None) -> Dict[str, Any]:
        """Explain uploaded document content, using simple language"""
        # Save uploaded file
        temp_file_path = os.path.join(self.document_dir, f"temp_{uuid.uuid4()}.pdf")
        
        async with aiofiles.open(temp_file_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # try:
        #     # 这里可以调用文档分析