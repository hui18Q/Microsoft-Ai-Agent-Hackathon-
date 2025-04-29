# 文档生成和管理API
from fastapi import APIRouter, Depends, HTTPException, Path, Query, Body, UploadFile, File
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from app.db.database import get_db
from app.services.document_service import DocumentService

router = APIRouter(prefix="/document", tags=["document"])

@router.post("/generate/{session_id}")
async def generate_document(
    session_id: int = Path(..., title="表单会话ID"),
    document_type: str = Query("application", title="文档类型"),
    db: Session = Depends(get_db)
):
    """
    根据已完成的表单生成申请文档
    """
    document_service = DocumentService(db)
    result = document_service.generate_document(session_id, document_type)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result

@router.get("/download/{document_id}")
async def download_document(
    document_id: str = Path(..., title="文档ID"),
    db: Session = Depends(get_db)
):
    """
    下载生成的文档
    """
    document_service = DocumentService(db)
    document_path = document_service.get_document_path(document_id)
    if not document_path:
        raise HTTPException(status_code=404, detail="文档不存在")
    
    return FileResponse(
        path=document_path,
        filename=document_service.get_document_filename(document_id),
        media_type="application/pdf"
    )

@router.post("/analyze")
async def analyze_document(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    分析上传的文档，提取关键信息
    """
    document_service = DocumentService(db)
    return await document_service.analyze_document(file)

@router.get("/templates")
async def get_document_templates(
    aid_program_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    获取可用的文档模板
    """
    document_service = DocumentService(db)
    return document_service.get_document_templates(aid_program_id)

@router.post("/preview/{session_id}")
async def preview_document(
    session_id: int = Path(..., title="表单会话ID"),
    document_type: str = Query("application", title="文档类型"),
    db: Session = Depends(get_db)
):
    """
    预览将要生成的文档
    """
    document_service = DocumentService(db)
    result = document_service.preview_document(session_id, document_type)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result

@router.post("/upload")
async def upload_completed_document(
    file: UploadFile = File(...),
    session_id: int = Query(..., title="表单会话ID"),
    db: Session = Depends(get_db)
):
    """
    上传已完成的文档（如用户手动填写并扫描）
    """
    document_service = DocumentService(db)
    return await document_service.upload_completed_document(file, session_id)

@router.post("/explain")
async def explain_document(
    file: UploadFile = File(...),
    preferred_language: Optional[str] = Query(None, title="首选语言"),
    db: Session = Depends(get_db)
):
    """
    解释上传的文档内容，使用简单语言
    """
    document_service = DocumentService(db)
    return await document_service.explain_document(file, preferred_language)

@router.get("/history/{user_id}")
async def get_document_history(
    user_id: int = Path(..., title="用户ID"),
    db: Session = Depends(get_db)
):
    """
    获取用户的文档历史
    """
    document_service = DocumentService(db)
    return document_service.get_document_history(user_id)