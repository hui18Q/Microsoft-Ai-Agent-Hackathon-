# 表单处理API
from fastapi import APIRouter, Depends, HTTPException, Query, Path, Body
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from app.db.database import get_db
from app.models.form_template import FormTemplate, FormField, FormSession
from app.schemas.form import (
    FormTemplate as FormTemplateSchema,
    FormField as FormFieldSchema,
    FormSession as FormSessionSchema,
    FormSessionCreate,
    FormSessionUpdate,
    FormSubmissionBase,
    FormSubmissionResponse,
    AutoFillRequest,
    AutoFillResponse
)
from app.services.form_service import FormService

router = APIRouter(prefix="/form", tags=["form"])

@router.get("/templates", response_model=List[FormTemplateSchema])
async def get_form_templates(
    db: Session = Depends(get_db),
    aid_program_id: Optional[int] = None
):
    """
    获取表单模板列表，可按援助项目筛选
    """
    form_service = FormService(db)
    return form_service.get_form_templates(aid_program_id=aid_program_id)

@router.get("/templates/{template_id}", response_model=FormTemplateSchema)
async def get_form_template(
    template_id: int = Path(..., title="表单模板ID"),
    db: Session = Depends(get_db)
):
    """
    获取特定表单模板的详细信息
    """
    form_service = FormService(db)
    template = form_service.get_form_template(template_id)
    if not template:
        raise HTTPException(status_code=404, detail="表单模板不存在")
    return template

@router.post("/sessions", response_model=FormSessionSchema)
async def start_form_session(
    session_data: FormSessionCreate,
    db: Session = Depends(get_db)
):
    """
    开始新的表单填写会话
    """
    form_service = FormService(db)
    return form_service.create_form_session(session_data)

@router.get("/sessions/{session_id}", response_model=FormSessionSchema)
async def get_form_session(
    session_id: int = Path(..., title="会话ID"),
    db: Session = Depends(get_db)
):
    """
    获取表单会话状态
    """
    form_service = FormService(db)
    session = form_service.get_form_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="表单会话不存在")
    return session

@router.put("/sessions/{session_id}", response_model=FormSessionSchema)
async def update_form_session(
    session_id: int = Path(..., title="会话ID"),
    update_data: FormSessionUpdate = Body(...),
    db: Session = Depends(get_db)
):
    """
    更新表单会话状态
    """
    form_service = FormService(db)
    updated_session = form_service.update_form_session(session_id, update_data)
    if not updated_session:
        raise HTTPException(status_code=404, detail="表单会话不存在")
    return updated_session

@router.get("/fields/{session_id}", response_model=List[FormFieldSchema])
async def get_form_fields(
    session_id: int = Path(..., title="会话ID"),
    section: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    获取表单字段，可按分区筛选
    """
    form_service = FormService(db)
    return form_service.get_form_fields(session_id, section=section)

@router.post("/submit/{session_id}", response_model=FormSubmissionResponse)
async def submit_form_data(
    session_id: int = Path(..., title="会话ID"),
    submission: FormSubmissionBase = Body(...),
    db: Session = Depends(get_db)
):
    """
    提交表单数据
    """
    form_service = FormService(db)
    return form_service.process_form_submission(session_id, submission.field_updates)

@router.post("/auto-fill", response_model=AutoFillResponse)
async def auto_fill_form(
    request: AutoFillRequest,
    db: Session = Depends(get_db)
):
    """
    自动填充表单
    """
    form_service = FormService(db)
    return form_service.auto_fill_form(
        form_template_id=request.form_template_id,
        user_id=request.user_id,
        sections=request.sections
    )

@router.post("/complete/{session_id}", response_model=Dict[str, Any])
async def complete_form(
    session_id: int = Path(..., title="会话ID"),
    db: Session = Depends(get_db)
):
    """
    完成表单并准备生成申请文档
    """
    form_service = FormService(db)
    result = form_service.complete_form(session_id)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result