from sqlalchemy.orm import Session
from app.db.database import engine, Base, get_db
from app.models.aid_program import AidProgram, Tag, Region
from app.models.form_template import FormTemplate, FormField, FormSession, FieldType
from app.models.user_profile import UserProfile, UserInteraction, UserPreference, ApplicationRecord
from app.models.user import User
import app.models
from datetime import datetime, date
from sqlalchemy import text

# 设置为True可以强制重新创建数据（调试用）
DEBUG_MODE = True

def init_db():
    Base.metadata.create_all(bind=engine)

    # 调用初始数据填充
    seed_initial_data()

# 将函数移出init_db函数，修复缩进问题
def seed_initial_data():
    """填充初始数据"""
    db = next(get_db())
    
    # 在DEBUG模式下，删除所有旧数据
    if DEBUG_MODE:
        print("调试模式: 删除所有现有数据...")
        
        # 使用 SQL 直接删除多对多关联表数据（先处理外键约束）
        db.execute(text("DELETE FROM aid_program_tag"))
        db.execute(text("DELETE FROM aid_program_region"))
        db.commit()
        print("已删除关联表数据")
        
        # db.execute(text("DELETE FROM form_sessions"))

        # 删除用户相关数据
        db.execute(text("DELETE FROM user_preferences"))
        db.execute(text("DELETE FROM user_interactions"))
        db.execute(text("DELETE FROM application_records"))
        db.execute(text("DELETE FROM user_profiles"))
        db.execute(text("DELETE FROM users"))
        db.commit()
        print("已删除用户相关数据")
        
        # 先删除有外键关联的表
        db.query(FormField).delete()
        db.query(FormTemplate).delete()
        
        # 删除主表数据
        db.query(AidProgram).delete()
        db.query(Tag).delete()
        db.query(Region).delete()
        db.commit()
        print("数据删除完成，准备重新创建...")
    # 非调试模式下，检查是否有数据，如果有则跳过初始化
    elif db.query(AidProgram).first() is not None:
        return
    
    # 1. 添加标签数据
    tags = [
        {"name": "老年人", "description": "针对60岁以上老年人的项目", "category": "人群"},
        {"name": "残障人士", "description": "针对残障人士的项目", "category": "人群"},
        {"name": "低收入", "description": "针对低收入家庭的项目", "category": "经济状况"},
        {"name": "单亲家庭", "description": "针对单亲家庭的项目", "category": "家庭类型"},
        {"name": "医疗补助", "description": "医疗相关的援助项目", "category": "服务类型"},
        {"name": "住房补贴", "description": "住房相关的援助项目", "category": "服务类型"},
        {"name": "教育资助", "description": "教育相关的援助项目", "category": "服务类型"},
        {"name": "就业援助", "description": "就业相关的援助项目", "category": "服务类型"}
    ]
    
    tag_objects = {}
    for tag_data in tags:
        tag = Tag(**tag_data)
        db.add(tag)
        tag_objects[tag_data["name"]] = tag
    
    # 2. 添加地区数据
    regions = [
        {"name": "吉隆坡", "country": "马来西亚", "code": "MY-KL"},
        {"name": "槟城", "country": "马来西亚", "code": "MY-PG"},
        {"name": "柔佛", "country": "马来西亚", "code": "MY-JH"},
        {"name": "沙巴", "country": "马来西亚", "code": "MY-SB"},
        {"name": "砂拉越", "country": "马来西亚", "code": "MY-SR"}
    ]
    
    region_objects = {}
    for region_data in regions:
        region = Region(**region_data)
        db.add(region)
        region_objects[region_data["name"]] = region
    
    # 提交标签和地区，以便后续引用
    db.commit()
    
    # 3. 添加援助项目数据
    current_time = datetime.utcnow()  # 使用同一时间戳
    
    aid_programs = [
        {
            "code": "BWE-JKM",
            "name": "Bantuan Warga Emas (BWE) - JKM",
            "program_type": "financial_aid",
            "short_description": "为60岁以上的马来西亚老年人提供每月RM500的经济援助",
            "full_description": "Bantuan Warga Emas (BWE)是由马来西亚社会福利局(JKM)管理的一项援助计划，旨在为60岁以上的低收入老年人提供经济支持。每月RM500的援助金直接发放给符合条件的申请人。",
            "benefit_amount": "每月RM500",
            "eligibility_criteria": [
                "马来西亚公民",
                "年龄60岁及以上",
                "无收入或收入有限",
                "不居住在政府资助的机构"
            ],
            "application_process": [
                {"step": 1, "description": "在线填写eBantuan JKM申请表或前往最近的社会福利办公室"},
                {"step": 2, "description": "提交身份证、收入证明和其他相关文件"},
                {"step": 3, "description": "等待申请审核和批准"}
            ],
            "application_url": "https://ebantuan.jkm.gov.my",
            "application_phone": "03-8000-8000",
            "priority": 10,
            "tags": ["老年人", "低收入"],
            "regions": ["吉隆坡", "槟城", "柔佛", "沙巴", "砂拉越"],
            "created_at": current_time,
            "updated_at": current_time
        },
        {
            "code": "SOCSO-IP",
            "name": "SOCSO 伤残退休金",
            "program_type": "financial_aid",
            "short_description": "为因疾病或残障无法工作的人提供月度退休金",
            "full_description": "社会保障组织(SOCSO)的伤残退休金计划为因疾病或残障导致无法工作的人提供经济支持。包括60岁以上被认定为不适合工作的老年工人。申请人必须有SOCSO供款记录。",
            "benefit_amount": "根据供款历史和残障程度计算",
            "eligibility_criteria": [
                "有SOCSO供款记录",
                "经医疗评估认定为不适合工作",
                "包括60岁以上的老年工人"
            ],
            "application_process": [
                {"step": 1, "description": "访问SOCSO官方网站了解申请流程"},
                {"step": 2, "description": "填写伤残退休金申请表"},
                {"step": 3, "description": "提交医疗报告和SOCSO供款记录"},
                {"step": 4, "description": "等待审核和批准"}
            ],
            "application_url": "https://www.perkeso.gov.my",
            "priority": 8,
            "tags": ["残障人士", "老年人"],
            "regions": ["吉隆坡", "槟城", "柔佛", "沙巴", "砂拉越"],
            "created_at": current_time,
            "updated_at": current_time
        },
        {
            "code": "PPR-KPKT",
            "name": "人民组屋计划",
            "program_type": "housing",
            "short_description": "为低收入家庭提供负担得起的住房选择",
            "full_description": "人民组屋计划(Program Perumahan Rakyat, PPR)由住房和地方政府部管理，旨在为低收入家庭提供负担得起的住房选择。该计划提供低租金或可负担购买价格的住房单位。",
            "benefit_amount": "低于市场价的租金或购买价格",
            "eligibility_criteria": [
                "马来西亚公民",
                "月收入低于特定标准",
                "没有其他房产",
                "家庭成员至少有两人"
            ],
            "application_process": [
                {"step": 1, "description": "向当地住房办公室提交申请"},
                {"step": 2, "description": "提供收入证明和家庭成员信息"},
                {"step": 3, "description": "等待分配住房单位"}
            ],
            "application_url": "https://www.kpkt.gov.my",
            "priority": 7,
            "tags": ["低收入", "住房补贴"],
            "regions": ["吉隆坡", "槟城", "柔佛"],
            "created_at": current_time,
            "updated_at": current_time
        }
    ]
    
    # 创建援助项目并关联标签和地区
    for program_data in aid_programs:
        # 提取并移除标签和地区数据
        tag_names = program_data.pop("tags", [])
        region_names = program_data.pop("regions", [])
        
        # 创建项目
        program = AidProgram(**program_data)
        
        # 关联标签
        for tag_name in tag_names:
            if tag_name in tag_objects:
                program.tags.append(tag_objects[tag_name])
        
        # 关联地区
        for region_name in region_names:
            if region_name in region_objects:
                program.regions.append(region_objects[region_name])
        
        db.add(program)
    
    # 4. 添加表单模板和字段
    # 示例：为"Bantuan Warga Emas (BWE) - JKM"项目创建申请表单
    db.commit()  # 提交以获取援助项目ID
    
    bwe_program = db.query(AidProgram).filter(AidProgram.code == "BWE-JKM").first()
    if bwe_program:
        # 创建表单模板
        bwe_template = FormTemplate(
            name="BWE申请表",
            description="Bantuan Warga Emas (BWE)计划的申请表格",
            aid_program_id=bwe_program.id,
            sections=[
                {"name": "personal_info", "title": "个人信息", "description": "申请人的基本信息", "order": 1},
                {"name": "contact_info", "title": "联系信息", "description": "申请人的联系方式", "order": 2},
                {"name": "income_info", "title": "收入信息", "description": "申请人的收入状况", "order": 3},
                {"name": "bank_info", "title": "银行信息", "description": "用于接收援助金的银行账户信息", "order": 4}
            ],
            help_text="请填写所有必要信息以申请Bantuan Warga Emas (BWE)计划。如需帮助，请拨打03-8000-8000。"
        )
        db.add(bwe_template)
        db.commit()
        
        # 创建表单字段
        bwe_fields = [
            # 个人信息部分
            {
                "name": "full_name",
                "label": "全名",
                "field_type": FieldType.TEXT,
                "section": "personal_info",
                "order": 1,
                "is_required": True,
                "help_text": "请输入您的完整姓名，与身份证上的姓名一致",
                "autofill_source": "full_name"
            },
            {
                "name": "id_number",
                "label": "身份证号码",
                "field_type": FieldType.ID_NUMBER,
                "section": "personal_info",
                "order": 2,
                "is_required": True,
                "help_text": "请输入您的身份证号码，格式为XXXXXX-XX-XXXX",
                "is_sensitive": True,
                "autofill_source": "id_number"
            },
            {
                "name": "birth_date",
                "label": "出生日期",
                "field_type": FieldType.DATE,
                "section": "personal_info",
                "order": 3,
                "is_required": True,
                "help_text": "请选择您的出生日期",
                "autofill_source": "birth_date"
            },
            {
                "name": "gender",
                "label": "性别",
                "field_type": FieldType.RADIO,
                "section": "personal_info",
                "order": 4,
                "is_required": True,
                "options": [
                    {"value": "male", "label": "男"},
                    {"value": "female", "label": "女"}
                ],
                "autofill_source": "gender"
            },
            
            # 联系信息部分
            {
                "name": "phone_number",
                "label": "电话号码",
                "field_type": FieldType.PHONE,
                "section": "contact_info",
                "order": 1,
                "is_required": True,
                "help_text": "请输入您的有效联系电话",
                "autofill_source": "phone_number"
            },
            {
                "name": "address",
                "label": "住址",
                "field_type": FieldType.TEXTAREA,
                "section": "contact_info",
                "order": 2,
                "is_required": True,
                "help_text": "请输入您的当前居住地址",
                "autofill_source": "address"
            },
            {
                "name": "city",
                "label": "城市",
                "field_type": FieldType.TEXT,
                "section": "contact_info",
                "order": 3,
                "is_required": True,
                "autofill_source": "city"
            },
            {
                "name": "state",
                "label": "州属",
                "field_type": FieldType.SELECT,
                "section": "contact_info",
                "order": 4,
                "is_required": True,
                "options": [
                    {"value": "kl", "label": "吉隆坡"},
                    {"value": "penang", "label": "槟城"},
                    {"value": "johor", "label": "柔佛"},
                    {"value": "sabah", "label": "沙巴"},
                    {"value": "sarawak", "label": "砂拉越"}
                ],
                "autofill_source": "state"
            },
            
            # 收入信息部分
            {
                "name": "income_status",
                "label": "收入状况",
                "field_type": FieldType.RADIO,
                "section": "income_info",
                "order": 1,
                "is_required": True,
                "options": [
                    {"value": "no_income", "label": "无收入"},
                    {"value": "limited_income", "label": "有限收入"}
                ]
            },
            {
                "name": "monthly_income",
                "label": "月收入(RM)",
                "field_type": FieldType.NUMBER,
                "section": "income_info",
                "order": 2,
                "is_required": False,
                "help_text": "如有收入，请输入您的月收入金额"
            },
            {
                "name": "income_proof",
                "label": "收入证明",
                "field_type": FieldType.FILE,
                "section": "income_info",
                "order": 3,
                "is_required": False,
                "help_text": "如适用，请上传收入证明文件"
            },
            
            # 银行信息部分
            {
                "name": "bank_name",
                "label": "银行名称",
                "field_type": FieldType.SELECT,
                "section": "bank_info",
                "order": 1,
                "is_required": True,
                "options": [
                    {"value": "maybank", "label": "马来亚银行"},
                    {"value": "cimb", "label": "联昌国际银行"},
                    {"value": "rhb", "label": "RHB银行"},
                    {"value": "publicbank", "label": "大众银行"},
                    {"value": "other", "label": "其他"}
                ]
            },
            {
                "name": "account_number",
                "label": "账户号码",
                "field_type": FieldType.TEXT,
                "section": "bank_info",
                "order": 2,
                "is_required": True,
                "help_text": "请输入您的银行账户号码",
                "is_sensitive": True
            }
        ]
        
        for field_data in bwe_fields:
            field = FormField(
                form_template_id=bwe_template.id,
                **field_data
            )
            db.add(field)
    
    # 5. 添加示例用户和用户档案
    # 创建一个示例用户（注意：这里使用的是已经哈希过的密码字符串，对应明文是"password"）
    sample_user = User(
        username="demo_user",
        email="demo@example.com",
        password="$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",  # 已哈希的密码：password
        is_active=True
    )
    db.add(sample_user)
    db.commit()
    
    # 创建用户档案
    sample_profile = UserProfile(
        user_id=sample_user.id,
        full_name="演示用户",
        birth_date=date(1960, 1, 15),
        gender="male",
        id_number="600115-10-1234",
        phone_number="012-3456789",
        address="123号，示例街",
        city="吉隆坡",
        state="吉隆坡",
        postal_code="50000",
        country="马来西亚",
        preferred_language="zh",
        income="low",
        employment_status="retired"
    )
    db.add(sample_profile)
    
    # 创建用户偏好
    sample_preference = UserPreference(
        user_id=sample_user.id,
        notification_preferences={"email": True, "sms": True, "push": False, "voice": True},
        ui_preferences={"theme": "default", "font_size": "large", "high_contrast": False},
        privacy_settings={"save_history": True, "use_for_recommendations": True}
    )
    db.add(sample_preference)
    
    # 提交所有更改
    db.commit()
    print("初始数据填充完成！")