# 援助项目查询API
from fastapi import APIRouter, Depends, HTTPException, Query, Path
from sqlalchemy.orm import Session
from typing import List, Optional

from app.db.database import get_db
from app.models.aid_program import AidProgram, Tag, Region
from app.schemas.aid import AidProgram as AidProgramSchema
from app.schemas.aid import AidProgramCreate, Tag, Region
from app.services.aid_service import AidService

router = APIRouter(prefix="/aid", tags=["aid"])

@router.get("/programs", response_model=List[AidProgramSchema])
async def get_aid_programs(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    program_type: Optional[str] = None,
    tag: Optional[str] = None,
    region: Optional[str] = None
):
    """
    获取援助项目列表，支持分页和筛选
    """
    aid_service = AidService(db)
    return aid_service.get_aid_programs(
        skip=skip, 
        limit=limit, 
        program_type=program_type, 
        tag=tag, 
        region=region
    )

@router.get("/programs/{program_id}", response_model=AidProgramSchema)
async def get_aid_program(
    program_id: int = Path(..., title="援助项目ID"),
    db: Session = Depends(get_db)
):
    """
    获取特定援助项目的详细信息
    """
    aid_service = AidService(db)
    program = aid_service.get_aid_program_by_id(program_id)
    if not program:
        raise HTTPException(status_code=404, detail="援助项目不存在")
    return program

@router.get("/topics", response_model=List[Tag])
async def get_aid_topics(
    db: Session = Depends(get_db),
    category: Optional[str] = None
):
    """
    获取所有援助主题（标签）
    
    参数:
    - category (可选): 按标签类别筛选，可选值包括：
      - 人群：针对特定人群的标签，如老年人、残障人士
      - 经济状况：与经济情况相关的标签，如低收入
      - 家庭类型：与家庭结构相关的标签，如单亲家庭
      - 服务类型：与服务性质相关的标签，如医疗补助、住房补贴、教育资助、就业援助
    
    返回:
    - 标签列表，每个标签包含id、name、description和category字段
    """
    aid_service = AidService(db)
    return aid_service.get_tags(category=category)

@router.get("/regions", response_model=List[Region])
async def get_regions(
    db: Session = Depends(get_db),
    country: Optional[str] = None
):
    """
    获取所有地区
    """
    aid_service = AidService(db)
    return aid_service.get_regions(country=country)

@router.get("/recommend", response_model=List[AidProgramSchema])
async def recommend_aid_programs(
    user_id: int = Query(..., title="用户ID"),
    limit: int = Query(5, title="推荐数量"),
    db: Session = Depends(get_db)
):
    """
    基于用户信息推荐援助项目
    """
    aid_service = AidService(db)
    return aid_service.recommend_aid_programs(user_id=user_id, limit=limit)

@router.post("/programs", response_model=AidProgramSchema)
async def create_aid_program(
    program: AidProgramCreate,
    db: Session = Depends(get_db)
):
    """
    创建新的援助项目（仅管理员）
    """
    aid_service = AidService(db)
    return aid_service.create_aid_program(program)

@router.get("/search", response_model=List[AidProgramSchema])
async def search_aid_programs(
    query: str = Query(..., title="搜索关键词"),
    db: Session = Depends(get_db)
):
    """
    搜索援助项目
    
    参数:
    - query: 搜索关键词，将在以下字段中进行模糊匹配:
        - 项目名称（如"老年人援助"、"教育资助"）
        - 项目代码（如"BWE-JKM"）
        - 项目简短描述
        - 项目详细描述
    
    示例:
    - /aid/search?query=老年人 - 搜索包含"老年人"的所有项目
    - /aid/search?query=教育 - 搜索与教育相关的项目
    - /aid/search?query=医疗 - 搜索与医疗相关的项目
    - /aid/search?query=低收入 - 搜索针对低收入群体的项目
    
    返回:
    - 符合搜索条件的援助项目列表，按优先级排序
    """
    aid_service = AidService(db)
    return aid_service.search_aid_programs(query=query)