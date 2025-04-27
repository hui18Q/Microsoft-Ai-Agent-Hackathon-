# backend/test_api.py
import requests
import json
import time 
# API端点地址
BASE_URL = "http://localhost:8000"

def test_conversation():
    session_id = f"test_session_{int(time.time())}"  # 创建唯一会话ID
    
    # 第一轮对话：询问福利
    response1 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "我是65岁的老人，有什么福利可以申请？", "session_id": session_id}
    )
    print("响应1:", response1.json())
    
    time.sleep(1)
    
    # 第二轮对话：继续询问
    response2 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "这些福利怎么申请？", "session_id": session_id}
    )
    print("响应2:", response2.json())
    
    time.sleep(1)
    
    # 第三轮对话：填表相关
    response3 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "帮我填写BWE-JKM申请表格", "session_id": session_id}
    )
    print("响应3:", response3.json())
    
def test_chat_api():
    session_id = f"test_api_{int(time.time())}"  # 创建唯一会话ID
    
    # 测试一般对话
    print("\n=== 测试一般对话 ===")
    response = requests.post(
        f"{BASE_URL}/chat/",  # 修正路径
        json={"query": "你好，请介绍一下你自己", "session_id": session_id}
    )
    print_response(response)
    
    # 测试福利咨询
    print("\n=== 测试福利咨询 ===")
    response = requests.post(
        f"{BASE_URL}/chat/",  # 修正路径
        json={"query": "我是一位65岁的老人，月收入不到1000元，有什么福利可以申请？", "session_id": session_id}
    )
    print_response(response)
    
    # 测试表单填写
    print("\n=== 测试表单填写 ===")
    response = requests.post(
        f"{BASE_URL}/chat/",  # 修正路径
        json={"query": "请帮我填写BWE-JKM申请表格", "session_id": session_id}
    )
    print_response(response)
    
    # 测试文档生成
    print("\n=== 测试文档生成 ===")
    response = requests.post(
        f"{BASE_URL}/chat/",  # 修正路径
        json={"query": "请帮我写一封申请社会保障的信", "session_id": session_id}
    )
    print_response(response)

def print_response(response):
    try:
        data = response.json()
        print(f"状态码: {response.status_code}")
        print(f"回复: {data.get('response')}")
        print(f"类型: {data.get('conversation_type', '不支持')}")
    except Exception as e:
        print(f"解析响应出错: {str(e)}")
        print(f"原始响应: {response.text}")

if __name__ == "__main__":
    # test_conversation()
    test_chat_api()