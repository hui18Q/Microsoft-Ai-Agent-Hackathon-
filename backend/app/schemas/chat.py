from pydantic import BaseModel, Field

class ChatMessage(BaseModel):
    role: str = Field(..., description="Message role, can be 'user' or 'assistant'")
    content: str = Field(..., description="Message content")

class ChatRequest(BaseModel):
    query: str = Field(..., description="User's input message")

class ChatResponse(BaseModel):
    response: str = Field(..., description="AI assistant's reply")
    status: str = Field("success", description="Request status") 