from langchain.schema import HumanMessage, SystemMessage, AIMessage
from app.schemas.chat import ChatRequest, ChatResponse
from langchain_ollama import ChatOllama
from langchain.memory import ChatMessageHistory
from app.tools import *

class ChatService:
    def __init__(self):
        self.chatmodel = ChatOllama(model="deepseek-r1:1.5b",
            temperature=0,
            base_url="http://127.0.0.1:11434",
        )
        self.mood = "default"
        self.MEMORY_KEY = "chat_history"
        self.SYSTEM_PROMPT = """You are CareBridge AI, an AI assistant specifically designed for underserved communities.
        Your primary functions include:
        1. Helping users understand government documents
        2. Assisting with applications for social benefits
        3. Finding nearby support services
        4. Supporting multilingual voice interactions
        5. Providing simple guided steps for those unfamiliar with technology
        {personality_traits}
        
        Common phrases you use:
        1. "I'm here to help you navigate the system."
        2. "Let me guide you through this process step by step."
        
        Your approach to answering questions:
        1. When users need to understand government documents, you explain in simple, clear language.
        2. When users need help with applications, you break down the process into manageable steps.
        3. When users need to find local resources, you help them locate the nearest services.
        """
        self.MOODS = {
            "default": {
                "roleSet":"",
                "voiceStyle":"chat"
            },
            "upbeat":{
                "roleSet":"""
                - You are currently very enthusiastic and energetic in your responses.
                """,
                "voiceStyle":"upbeat",
            },
            "compassionate":{
                "roleSet":"""
                - You respond with extra patience and understanding.
                """,
                "voiceStyle":"empathetic",
            },
            "encouraging":{
                "roleSet":"""
                - You include words of encouragement in your responses, like "you can do this" and "keep going".
                """,
                "voiceStyle":"supportive",
            },
            "friendly":{
                "roleSet":"""
                - You respond in a very approachable and warm tone.
                """,
                "voiceStyle":"friendly",
            },
            "informative":{
                "roleSet":"""
                - You focus on providing clear, factual information in a straightforward way.
                """,
                "voiceStyle":"professional",
            },
        }
        self.memory = self.get_memory()
        
    def get_memory(self):
        """Get memory object"""
        return ChatMessageHistory()
        
    async def generate_response(self, request: ChatRequest) -> ChatResponse:
        """Generate chat response"""
        try:
            # Build system prompt
            system_message = SystemMessage(content=self.SYSTEM_PROMPT.format(
                personality_traits=self.MOODS[self.mood]["roleSet"]
            ))
            
            # Add history messages
            messages = [system_message]
            for msg in self.memory.messages:
                messages.append(msg)
                
            # Add current user message
            user_message = HumanMessage(content=request.query)
            messages.append(user_message)
            self.memory.add_message(user_message)
            
            # Get response
            response = self.chatmodel.invoke(messages)
            
            # Save AI response to history
            self.memory.add_message(response)
            
            return ChatResponse(
                response=response.content,
                status="success"
            )
        except Exception as e:
            return ChatResponse(
                response=f"Error generating response: {str(e)}",
                status="error"
            )