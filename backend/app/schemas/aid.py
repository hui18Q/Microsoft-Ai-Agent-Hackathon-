# app/schemas/aid.py
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class TagBase(BaseModel):
    name: str
    description: Optional[str] = None
    category: Optional[str] = None

class Tag(TagBase):
    id: int
    
    class Config:
        orm_mode = True

class RegionBase(BaseModel):
    name: str
    country: str
    code: str

class Region(RegionBase):
    id: int
    
    class Config:
        orm_mode = True

class AidProgramBase(BaseModel):
    code: str
    name: str
    program_type: str
    short_description: Optional[str] = None
    full_description: Optional[str] = None
    benefit_amount: Optional[str] = None
    eligibility_criteria: Optional[List[str]] = None
    application_process: Optional[List[Dict[str, Any]]] = None
    application_url: Optional[str] = None
    application_phone: Optional[str] = None
    application_email: Optional[str] = None
    priority: Optional[int] = 0

class AidProgramCreate(AidProgramBase):
    pass

class AidProgram(AidProgramBase):
    id: int
    tags: List[str] = []
    regions: List[str] = []
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True
