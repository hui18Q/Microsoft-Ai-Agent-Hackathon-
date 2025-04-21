from langchain.schema import HumanMessage, SystemMessage, AIMessage
from app.schemas.chat import ChatRequest, ChatResponse
from langchain_openai import ChatOpenAI
from langchain.agents import create_openai_tools_agent,AgentExecutor,tool
from langchain_core.prompts import ChatPromptTemplate,MessagesPlaceholder
from langchain.memory import ChatMessageHistory
from langchain.memory import ConversationBufferMemory
from app.tools import *
from langchain.agents import AgentExecutor, create_react_agent
import os

os.environ["OPENAI_API_KEY"] = "sk-"
os.environ["OPENAI_API_BASE"] = "https://api.siliconflow.cn/v1"
os.environ["OPENAI_API_MODEL"] = "deepseek-ai/DeepSeek-V3"
class ChatService:
    def __init__(self):
        self.chatmodel = ChatOpenAI(
            openai_api_key=os.getenv("OPENAI_API_KEY"),
            openai_api_base=os.getenv("OPENAI_API_BASE"),
            model_name=os.getenv("OPENAI_API_MODEL"),
            temperature=0,
            streaming=True,
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

        self.prompt = ChatPromptTemplate.from_messages(
            [
                (
                   "system",
                   self.SYSTEM_PROMPT.format(personality_traits=self.MOODS[self.mood]["roleSet"]),
                ),
                MessagesPlaceholder(variable_name=self.MEMORY_KEY),
                (
                    "user",
                    "{input}"
                ),
                MessagesPlaceholder(variable_name="agent_scratchpad"),
            ],
        )
        
        tools = [tool_test]

        self.agent = create_openai_tools_agent(
            llm=self.chatmodel,
            tools=tools,
            prompt=self.prompt,
        )
        self.memory = self.get_memory()
        memory = ConversationBufferMemory(
            human_prefix="user",
            ai_prefix="CareBridge AI",
            memory_key=self.MEMORY_KEY,
            output_key="output",
            return_messages=True,
            chat_memory=self.memory,
        )
        self.agent_executor = AgentExecutor(
            agent=self.agent,
            tools=tools,
            memory=memory,
            verbose=True,
            handle_parsing_errors=True,
        )
        
    def get_memory(self):
        """Get memory object"""
        return ChatMessageHistory()
        
    async def generate_response(self, request: ChatRequest) -> ChatResponse:
        """Generate chat response"""
        try:
            user_message = HumanMessage(content=request.query)
            self.memory.add_message(user_message)
            
            result = self.agent_executor.invoke({"input": request.query})
            
            response_content = result["output"]
            ai_message = AIMessage(content=response_content)
            self.memory.add_message(ai_message)
            
            return ChatResponse(
                response=response_content,
                status="success"
            )
        except Exception as e:
            print(f"Error generating response: {str(e)}")
            import traceback
            traceback.print_exc()
            return ChatResponse(
                response=f"sorry,I can't answer your question",
                status="error"
            )