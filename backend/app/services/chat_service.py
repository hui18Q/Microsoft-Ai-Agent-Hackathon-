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
    根据用户查询搜索匹配的福利项目
    
    Args:
        query: 用户查询文本
        
    Returns:
        匹配的福利项目列表的文本描述
    """
    try:
        # 从查询中提取关键词
        keywords = extract_keywords(query)
        
        # 从查询中提取用户信息
        user_info = {}
        age_match = re.search(r'(\d{1,2})[^\d]*(岁|年龄)', query)
        if age_match:
            user_info['age'] = int(age_match.group(1))
        
        income_match = re.search(r'收入[是为约]?(\d+)[^\d]*(元|块|rm|RM)', query)
        if income_match:
            user_info['income'] = int(income_match.group(1))
        
        # 使用依赖注入获取数据库会话
        # 注意：这里我们改为模拟查询，因为我们没有实际的数据库会话
        # 在实际环境中，请使用下面被注释的代码
        # db = next(get_db())
        # programs = find_programs(db, keywords, user_info)
        
        # 模拟查询结果
        programs = [
            {
                "name": "Bantuan Warga Emas (BWE)",
                "provider": "JKM",
                "description": "为60岁以上的老年人提供每月RM500的经济援助",
                "eligibility": "60岁以上的马来西亚公民，无或低收入，不居住在政府资助的机构",
                "benefit_amount": "每月RM500",
                "application_method": "通过eBantuan JKM在线申请或前往最近的社会福利部门办公室"
            },
            {
                "name": "SOCSO残疾人养老金",
                "provider": "SOCSO",
                "description": "为因疾病/残疾而无法工作的人提供月度养老金",
                "eligibility": "必须有SOCSO缴款记录，包括60岁以上被认证为不适合工作的人",
                "benefit_amount": "根据缴款历史计算",
                "application_method": "访问SOCSO网站或前往SOCSO办公室申请"
            }
        ]
        
        if not programs:
            return "没有找到符合条件的福利项目。请提供更多信息，如您的年龄、收入情况或具体需求。"
        
        # 格式化结果
        result = "🌟 为您找到以下适合的福利项目：\n\n"
        for i, program in enumerate(programs, 1):
            result += f"{i}. 🏷️ {program['name']} - {program['provider']}\n"
            result += f"• 说明: {program['description']}\n"
            result += f"• 资格条件: {program['eligibility']}\n"
            result += f"• 福利金额: {program['benefit_amount']}\n"
            result += f"• 申请方式: {program['application_method']}\n\n"
        
        return result
    except Exception as e:
        print(f"搜索福利项目时出错: {str(e)}")
        return "抱歉，搜索福利项目时发生错误。请稍后再试。"

# 添加工具函数用于获取表单模板
@tool
def get_form_template(program_id: str) -> str:
    """
    获取特定福利项目的申请表单模板
    
    Args:
        program_id: 福利项目ID
        
    Returns:
        表单模板的文本描述
    """
    try:
        # 模拟表单模板数据
        template = {
            "name": "Bantuan Warga Emas申请表",
            "sections": [
                {
                    "name": "个人信息",
                    "fields": [
                        {"label": "全名", "required": True, "help_text": "请输入您的完整姓名，与身份证一致"},
                        {"label": "身份证号码", "required": True, "help_text": "请输入您的身份证号码"},
                        {"label": "出生日期", "required": True, "help_text": "请输入您的出生日期，格式：DD/MM/YYYY"}
                    ]
                },
                {
                    "name": "联系信息",
                    "fields": [
                        {"label": "手机号码", "required": True, "help_text": "请输入您的手机号码"},
                        {"label": "邮箱地址", "required": False, "help_text": "请输入您的邮箱地址（如有）"},
                        {"label": "居住地址", "required": True, "help_text": "请输入您目前的居住地址"}
                    ]
                },
                {
                    "name": "财务信息",
                    "fields": [
                        {"label": "月收入", "required": True, "help_text": "请输入您的月收入金额（RM）"},
                        {"label": "收入来源", "required": True, "help_text": "请选择您的主要收入来源"},
                        {"label": "是否有其他经济支持", "required": True, "help_text": "请说明您是否有其他经济支持（如家人支持）"}
                    ]
                }
            ]
        }
        
        if not template:
            return f"未找到ID为{program_id}的福利项目申请表单。"
        
        # 格式化表单字段
        result = f"📝 {template['name']}申请表单\n\n"
        
        for section in template['sections']:
            result += f"## {section['name']}\n"
            
            for field in section['fields']:
                required = "（必填）" if field['required'] else "（选填）"
                result += f"• {field['label']}{required}: {field['help_text']}\n"
        
        result += "\n请问您想开始填写这个表单吗？或者需要我帮您解释某个部分？"
        
        return result
    except Exception as e:
        print(f"获取表单模板时出错: {str(e)}")
        return "抱歉，获取表单模板时发生错误。请稍后再试。"

# 辅助函数：从查询中提取关键词
def extract_keywords(query: str) -> List[str]:
    # 简单实现，实际可用NLP技术改进
    keywords = []
    
    # 检测年龄相关
    if re.search(r'老人|年长|老年|年迈|60岁|65岁|70岁', query):
        keywords.append('elderly')
        
    # 检测残疾相关
    if re.search(r'残疾|残障|伤残|行动不便|失能', query):
        keywords.append('disability')
        
    # 检测低收入相关
    if re.search(r'低收入|贫困|经济困难|无收入|收入低', query):
        keywords.append('low_income')
        
    # 检测医疗相关
    if re.search(r'医疗|医保|看病|住院|治疗|药品', query):
        keywords.append('healthcare')
        
    # 检测住房相关
    if re.search(r'住房|租房|租金|购房|房屋|居住', query):
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
            "general": "一般对话",
            "aid_inquiry": "援助项目咨询",
            "form_filling": "表单填写助手",
            "document_generation": "文档生成"
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
                        self.SYSTEM_PROMPT+"\n这是一段你和用户的对话记忆，对其进行总结摘要，摘要使用第一人称'我'，并且提取其中的用户关键信息，如姓名、年龄、性别、出生日期等。以如下格式返回:\n 总结摘要内容｜用户关键信息 \n 例如 用户Jery问候我，我礼貌回复，然后他询问相关信息，我回答了他相关信息，然后他告辞离开。｜Jery,生日1999年1月1日"
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
        """识别用户查询的意图类型"""
        
        # 福利咨询相关关键词
        aid_keywords = ["福利", "补助", "援助", "申请", "资格", "政府项目", "社会保障", 
                        "低收入", "残疾", "老人", "养老金", "医疗补助"]
        
        # 表单填写相关关键词
        form_keywords = ["表格", "填写", "申请表", "提交", "表单", "资料", "证明", 
                         "如何填", "怎么填", "帮我填"]
        
        # 文档生成相关关键词
        document_keywords = ["生成文件", "生成信", "写一封", "模板", "草稿", 
                            "申诉信", "证明信", "请求书"]
        
        # 匹配意图
        if any(keyword in query for keyword in aid_keywords):
            return "aid_inquiry"
        elif any(keyword in query for keyword in form_keywords):
            return "form_filling"
        elif any(keyword in query for keyword in document_keywords):
            return "document_generation"
        else:
            return "general"
    
    # 新增：获取用户信息
    def extract_user_info(self, query: str, chat_history) -> Dict[str, Any]:
        """从查询和聊天历史中提取用户信息"""
        user_info = {}
        
        # 提取年龄
        age_match = re.search(r'(\d{1,2})[^\d]*(岁|年龄)', query)
        if age_match:
            user_info['age'] = int(age_match.group(1))
        
        # 提取收入
        income_match = re.search(r'收入[是为约]?(\d+)[^\d]*(元|块|rm|RM)', query)
        if income_match:
            user_info['income'] = int(income_match.group(1))
        
        # TODO: 从聊天历史中提取更多信息
        
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
                response=f"对不起，我现在无法回答您的问题。请稍后再试。",
                status="error"
            )