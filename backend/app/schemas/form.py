from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any, Union
from datetime import datetime
from enum import Enum

class FieldTypeEnum(str, Enum):
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

class ValidationRule(BaseModel):
    type: str  # min, max, regex, etc.
    value: Union[str, int, float]
    message: str

class FormFieldOption(BaseModel):
    value: str
    label: str
    description: Optional[str] = None

class FormFieldBase(BaseModel):
    name: str
    label: str
    field_type: FieldTypeEnum
    section: Optional[str] = None
    order: Optional[int] = 0
    is_required: bool = False
    validation_rules: Optional[List[ValidationRule]] = None
    default_value: Optional[str] = None
    placeholder: Optional[str] = None
    help_text: Optional[str] = None
    options: Optional[List[FormFieldOption]] = None
    is_sensitive: bool = False
    autofill_source: Optional[str] = None

class FormFieldCreate(FormFieldBase):
    form_template_id: int

class FormField(FormFieldBase):
    id: int
    form_template_id: int
    
    class Config:
        orm_mode = True

class FormSectionBase(BaseModel):
    name: str
    title: str
    description: Optional[str] = None
    order: int

class FormSection(FormSectionBase):
    id: int
    
    class Config:
        orm_mode = True

class FormTemplateBase(BaseModel):
    name: str
    description: Optional[str] = None
    aid_program_id: Optional[int] = None
    sections: Optional[List[Dict[str, Any]]] = None
    help_text: Optional[str] = None
    is_active: bool = True

class FormTemplateCreate(FormTemplateBase):
    pass

class FormTemplate(FormTemplateBase):
    id: int
    fields: List[FormField] = []
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True

class FormSessionBase(BaseModel):
    user_id: int
    form_template_id: int
    current_section: Optional[str] = None
    completed_fields: Optional[List[str]] = []
    form_data: Optional[Dict[str, Any]] = {}

class FormSessionCreate(FormSessionBase):
    pass

class FormSessionUpdate(BaseModel):
    current_section: Optional[str] = None
    completed_fields: Optional[List[str]] = None
    form_data: Optional[Dict[str, Any]] = None
    is_completed: Optional[bool] = None

class FormSession(FormSessionBase):
    id: int
    started_at: datetime
    last_activity: datetime
    is_completed: bool
    
    class Config:
        orm_mode = True

class FormSubmissionBase(BaseModel):
    form_session_id: int
    field_updates: Dict[str, Any]

class FormSubmissionResponse(BaseModel):
    success: bool
    next_section: Optional[str] = None
    next_fields: Optional[List[FormField]] = None
    completed: bool = False
    errors: Optional[Dict[str, str]] = None
    
    class Config:
        orm_mode = True

class AutoFillRequest(BaseModel):
    form_template_id: int
    user_id: int
    sections: Optional[List[str]] = None

class AutoFillResponse(BaseModel):
    filled_fields: Dict[str, Any]
    missing_fields: List[str]