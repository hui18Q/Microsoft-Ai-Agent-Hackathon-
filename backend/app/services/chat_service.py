# backend/app/services/chat_service.py
from langchain.schema import HumanMessage, SystemMessage, AIMessage
from app.schemas.chat import ChatRequest, ChatResponse
from langchain_openai import ChatOpenAI
from langchain.agents import create_openai_tools_agent, AgentExecutor, tool
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_community.chat_message_histories import RedisChatMessageHistory
from langchain.memory import ConversationBufferMemory
from app.tools import *
from langchain.agents import AgentExecutor, create_react_agent
import os
import re
from typing import List, Dict, Any
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.models.aid_program import AidProgram, Tag  # 引入福利项目模型
from app.models.form_template import FormTemplate, FormField  # 引入表单模型
from app.models.user_profile import UserProfile  # 引入用户档案模型

os.environ["OPENAI_API_KEY"] = "sk-ykgigojwdmfgzvkroxskrzgowvftaabowfpolxbttbwzfqjz"
os.environ["OPENAI_API_BASE"] = "https://api.siliconflow.cn/v1"
os.environ["OPENAI_API_MODEL"] = "deepseek-ai/DeepSeek-V3"
# REDIS_URL = os.getenv("REDIS_URL")
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")  # 设置默认值

# 添加工具函数用于搜索援助项目
@tool
def search_aid_programs(query: str) -> str:
    """
    Search for matching welfare programs based on user query
    
    Args:
        query: User query text
        
    Returns:
        Text description of matching welfare programs
    """
    try:
        # Extract keywords from query
        keywords = extract_keywords(query)
        
        # Extract user info from query
        user_info = {}
        age_match = re.search(r'(\d{1,2})[^\d]*(years|year|old|age)', query)
        if age_match:
            user_info['age'] = int(age_match.group(1))
        
        income_match = re.search(r'income[^\d]*(\d+)', query)
        if income_match:
            user_info['income'] = int(income_match.group(1))
        
        # Mock query results
        programs = [
            {
                "name": "Bantuan Warga Emas (BWE)",
                "provider": "JKM",
                "description": "Monthly financial assistance of RM500 for seniors over 60",
                "eligibility": "Malaysian citizens over 60 with low or no income, not residing in government-funded institutions",
                "benefit_amount": "RM500 per month",
                "application_method": "Apply online through eBantuan JKM or visit the nearest social welfare department office"
            },
            {
                "name": "SOCSO Disability Pension",
                "provider": "SOCSO",
                "description": "Monthly pension for people unable to work due to illness/disability",
                "eligibility": "Must have SOCSO contribution records, including persons over 60 certified as unfit for work",
                "benefit_amount": "Calculated based on contribution history",
                "application_method": "Visit SOCSO website or SOCSO office to apply"
            }
        ]
        
        if not programs:
            return "No matching welfare programs found. Please provide more information, such as your age, income situation, or specific needs."
        
        # Format results
        result = "🌟 Found the following suitable welfare programs for you:\n\n"
        for i, program in enumerate(programs, 1):
            result += f"{i}. 🏷️ {program['name']} - {program['provider']}\n"
            result += f"• Description: {program['description']}\n"
            result += f"• Eligibility: {program['eligibility']}\n"
            result += f"• Benefit Amount: {program['benefit_amount']}\n"
            result += f"• How to Apply: {program['application_method']}\n\n"
        
        return result
    except Exception as e:
        print(f"Error searching welfare programs: {str(e)}")
        return "Sorry, an error occurred while searching for welfare programs. Please try again later."

# 添加工具函数用于获取表单模板
@tool
def get_form_template(program_id: str) -> str:
    """
    Get application form template for a specific welfare program
    
    Args:
        program_id: Welfare program ID
        
    Returns:
        Text description of the form template
    """
    try:
        # Mock form template data
        template = {
            "name": "Bantuan Warga Emas Application Form",
            "sections": [
                {
                    "name": "Personal Information",
                    "fields": [
                        {"label": "Full Name", "required": True, "help_text": "Enter your complete name as shown on your ID card"},
                        {"label": "ID Number", "required": True, "help_text": "Enter your ID number"},
                        {"label": "Date of Birth", "required": True, "help_text": "Enter your date of birth in format: DD/MM/YYYY"}
                    ]
                },
                {
                    "name": "Contact Information",
                    "fields": [
                        {"label": "Mobile Number", "required": True, "help_text": "Enter your mobile phone number"},
                        {"label": "Email Address", "required": False, "help_text": "Enter your email address (if available)"},
                        {"label": "Residential Address", "required": True, "help_text": "Enter your current residential address"}
                    ]
                },
                {
                    "name": "Financial Information",
                    "fields": [
                        {"label": "Monthly Income", "required": True, "help_text": "Enter your monthly income amount (RM)"},
                        {"label": "Income Source", "required": True, "help_text": "Select your main source of income"},
                        {"label": "Other Financial Support", "required": True, "help_text": "Indicate if you have other financial support (e.g., family support)"}
                    ]
                }
            ]
        }
        
        if not template:
            return f"Form template for program ID {program_id} not found."
        
        # Format form fields
        result = f"📝 {template['name']}\n\n"
        
        for section in template['sections']:
            result += f"## {section['name']}\n"
            
            for field in section['fields']:
                required = "(Required)" if field['required'] else "(Optional)"
                result += f"• {field['label']} {required}: {field['help_text']}\n"
        
        result += "\nWould you like to start filling out this form? Or do you need me to explain any section?"
        
        return result
    except Exception as e:
        print(f"Error getting form template: {str(e)}")
        return "Sorry, an error occurred while retrieving the form template. Please try again later."

# 辅助函数：从查询中提取关键词
def extract_keywords(query: str) -> List[str]:
    # Simple implementation, can be improved with NLP techniques
    keywords = []
    
    # Detect age-related
    if re.search(r'senior|elderly|old|age|60|65|70', query):
        keywords.append('elderly')
        
    # Detect disability-related
    if re.search(r'disability|disabled|handicap|mobility', query):
        keywords.append('disability')
        
    # Detect low-income related
    if re.search(r'low income|poor|financial difficulty|no income', query):
        keywords.append('low_income')
        
    # Detect healthcare-related
    if re.search(r'medical|healthcare|doctor|hospital|treatment|medicine', query):
        keywords.append('healthcare')
        
    # Detect housing-related
    if re.search(r'housing|rent|rental|home|house|accommodation', query):
        keywords.append('housing')
    
    return keywords if keywords else ['general']

# 辅助函数：根据关键词和用户信息查找项目
def find_programs(db: Session, keywords: List[str], user_info: dict = None) -> List[Dict]:
    # 这里应该是实际的数据库查询代码
    # 由于我们没有实际的数据库连接，这里先使用模拟数据
    # 在实际实现中，应当使用类似下面的代码：
    
    # query = db.query(AidProgram)
    # 
    # # 根据关键词过滤
    # for keyword in keywords:
    #     tag = db.query(Tag).filter(Tag.name == keyword).first()
    #     if tag:
    #         query = query.filter(AidProgram.tags.contains(tag))
    # 
    # # 根据用户信息过滤
    # if user_info:
    #     if 'age' in user_info and user_info['age'] is not None:
    #         age = user_info['age']
    #         # 假设AidProgram有min_age和max_age字段
    #         query = query.filter(
    #             (AidProgram.min_age.is_(None) | (AidProgram.min_age <= age)) &
    #             (AidProgram.max_age.is_(None) | (AidProgram.max_age >= age))
    #         )
    #     
    #     if 'income' in user_info and user_info['income'] is not None:
    #         income = user_info['income']
    #         # 假设AidProgram有max_income字段
    #         query = query.filter(
    #             (AidProgram.max_income.is_(None) | (AidProgram.max_income >= income))
    #         )
    # 
    # # 获取结果
    # programs = query.all()
    
    # 返回模拟数据
    return []

class ChatService:
    def __init__(self, session_id="session"):
        self.session_id = session_id
        self.chatmodel = ChatOpenAI(
            openai_api_key=os.getenv("OPENAI_API_KEY"),
            openai_api_base=os.getenv("OPENAI_API_BASE"),
            model_name=os.getenv("OPENAI_API_MODEL"),
            temperature=0,
            streaming=True,
        )
        self.mood = "default"
        self.MEMORY_KEY = "chat_history"
        
        # 添加对话类型定义
        self.CONVERSATION_TYPES = {
            "general": "General Conversation",
            "aid_inquiry": "Aid Program Inquiry",
            "form_filling": "Form Filling Assistant",
            "document_generation": "Document Generation"
        }
        
        # 当前对话类型
        self.current_conversation_type = "general"
        
        # 扩展系统提示，增加福利咨询相关指导
        self.SYSTEM_PROMPT = """You are CareBridge AI, an AI assistant specifically designed for underserved communities.
        Your primary functions include:
        1. Helping users understand government documents
        2. Assisting with applications for social benefits
        3. Finding nearby support services
        4. Supporting multilingual voice interactions
        5. Providing simple guided steps for those unfamiliar with technology
        
        For social benefits assistance:
        1. You will extract key information from the user (age, income, family situation)
        2. You will help match users with appropriate aid programs 
        3. You will guide users through application processes step-by-step
        4. You will use a friendly, supportive tone throughout
        
        {personality_traits}
        
        Common phrases you use:
        1. "I'm here to help you navigate the system."
        2. "Let me guide you through this process step by step."
        3. "I can help you find benefits you may qualify for."
        4. "Would you like me to explain more about this program?"
        
        Your approach to answering questions:
        1. When users need to understand government documents, you explain in simple, clear language.
        2. When users need help with applications, you break down the process into manageable steps.
        3. When users need to find local resources, you help them locate the nearest services.
        4. When users are seeking benefits, you ask clarifying questions about their situation.
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
        
        # 扩展工具集，增加福利查询和表单工具
        tools = [
            tool_test,
            search_aid_programs,  # 新增援助项目搜索工具
            get_form_template     # 新增表单模板获取工具
        ]

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
        chat_message_history = RedisChatMessageHistory(
            url=REDIS_URL, session_id=self.session_id
        )
        #chat_message_history.clear()#清空历史记录
        print("chat_message_history:",chat_message_history.messages)
        store_message = chat_message_history.messages
        if len(store_message) > 10:
            prompt = ChatPromptTemplate.from_messages(
                [
                    (
                        "system",
                        self.SYSTEM_PROMPT+"\nThis is a conversation memory between you and the user. Summarize it and extract key user information such as name, age, gender, date of birth, etc. Return in this format:\n Summary Content | User Key Information \nFor example: User Jerry greeted me, I responded politely, then he asked about related information, I provided the information, then he said goodbye. | Jerry, birthdate January 1, 1999"
                    ),
                    ("user","{input}"),
                ]
            )
            chain = prompt | self.chatmodel 
            summary = chain.invoke({"input":store_message,"personality_traits":self.MOODS[self.mood]["roleSet"]})
            print("summary:",summary)
            chat_message_history.clear()
            chat_message_history.add_message(summary)
            print("总结后：",chat_message_history.messages)
        return chat_message_history
    
    # 新增：对话意图识别函数
    def detect_conversation_intent(self, query: str) -> str:
        """Detect the intent type of user query"""
        
        # Aid consultation related keywords
        aid_keywords = ["benefit", "benefits", "assistance", "aid", "apply", "application",
                       "eligibility", "government program", "social security", "welfare",
                       "low income", "disability", "elderly", "senior", "pension", "medical assistance",
                       "support", "financial help", "grant", "allowance", "subsidy"]
        
        # Form filling related keywords
        form_keywords = ["form", "fill", "application form", "submit", "document", "information", 
                        "certificate", "how to fill", "help me fill", "complete", "application process"]
        
        # Document generation related keywords
        document_keywords = ["generate document", "generate letter", "write a letter", "template", 
                            "draft", "appeal letter", "certificate letter", "request letter"]
        
        # Match intent
        query_lower = query.lower()
        if any(keyword in query_lower for keyword in aid_keywords):
            return "aid_inquiry"
        elif any(keyword in query_lower for keyword in form_keywords):
            return "form_filling"
        elif any(keyword in query_lower for keyword in document_keywords):
            return "document_generation"
        else:
            return "general"
    
    # 新增：获取用户信息
    def extract_user_info(self, query: str, chat_history) -> Dict[str, Any]:
        """Extract user information from query and chat history"""
        user_info = {}
        
        # Extract age - improved regex to match more patterns
        age_match = re.search(r'(\d{1,2})[\s-]*(?:years?|yrs?|year-?old|y\.?o\.?|age)', query.lower())
        if age_match:
            user_info['age'] = int(age_match.group(1))
        
        # Extract income - improved regex to match more patterns
        income_match = re.search(r'(?:income|earn|making|salary)[^\d]*?(\d+)', query.lower())
        if income_match:
            user_info['income'] = int(income_match.group(1))
        
        # Add debug output
        print(f"Extracted user info: {user_info}")
        
        return user_info
        
    async def generate_response(self, request: ChatRequest) -> ChatResponse:
        """Generate chat response"""
        try:
            # 识别对话意图
            intent = self.detect_conversation_intent(request.query)
            self.current_conversation_type = intent
            
            # 添加用户消息到记忆
            user_message = HumanMessage(content=request.query)
            self.memory.add_message(user_message)
            
            # 提取用户信息并将其添加到查询中，而不是作为单独参数
            user_info = {}
            if intent == "aid_inquiry":
                user_info = self.extract_user_info(request.query, self.memory.messages)
            
            # 修改：仅传递一个参数
            result = self.agent_executor.invoke({
                "input": request.query  # 只使用一个输入参数
            })
            
            response_content = result["output"]
            ai_message = AIMessage(content=response_content)
            self.memory.add_message(ai_message)
            
            # 检查ChatResponse模型是否支持conversation_type字段
            try:
                return ChatResponse(
                    response=response_content,
                    status="success",
                    conversation_type=self.current_conversation_type
                )
            except:
                return ChatResponse(
                    response=response_content,
                    status="success"
                )
        except Exception as e:
            print(f"Error generating response: {str(e)}")
            import traceback
            traceback.print_exc()
            return ChatResponse(
                response=f"I'm sorry, I cannot answer your question right now. Please try again later.",
                status="error"
            )