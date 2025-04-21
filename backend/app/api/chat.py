from fastapi import APIRouter, HTTPException, Query
from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService

router = APIRouter(prefix="/chat", tags=["chat"])

@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Process chat requests, users only need to provide the query parameter
    """
    chat_service = ChatService()
    response = await chat_service.generate_response(request)
    
    if response.status == "error":
        raise HTTPException(status_code=500, detail=response.response)
    
    return response

@router.get("/", response_model=ChatResponse)
async def chat_get(query: str = Query(..., description="User's input message")):
    """
    Process chat via GET request for easy browser access
    """
    request = ChatRequest(query=query)
    chat_service = ChatService()
    response = await chat_service.generate_response(request)
    
    if response.status == "error":
        raise HTTPException(status_code=500, detail=response.response)
    
    return response
