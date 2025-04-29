# backend/test_api.py
import requests
import json
import time 
# API endpoint address
BASE_URL = "http://localhost:8000"

def test_conversation():
    session_id = f"test_session_{int(time.time())}"  # Create unique session ID
    
    # First round: Ask about benefits
    response1 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "I am a 65-year-old senior, what benefits can I apply for?", "session_id": session_id}
    )
    print("Response 1:", response1.json())
    
    time.sleep(1)
    
    # Second round: Continue asking
    response2 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "How can I apply for these benefits?", "session_id": session_id}
    )
    print("Response 2:", response2.json())
    
    time.sleep(1)
    
    # Third round: Form filling
    response3 = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "Help me fill out the BWE-JKM application form", "session_id": session_id}
    )
    print("Response 3:", response3.json())
    
def test_chat_api():
    session_id = f"test_api_{int(time.time())}"  # Create unique session ID
    
    # Test general conversation
    print("\n=== Testing General Conversation ===")
    response = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "Hello, please introduce yourself", "session_id": session_id}
    )
    print_response(response)
    
    # Test welfare consultation
    print("\n=== Testing Welfare Consultation ===")
    response = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "I am a 65-year-old senior citizen with a monthly income of 900 dollars. What welfare benefits or assistance programs can I apply for?", "session_id": session_id}
    )
    print_response(response)
    
    # Test form filling
    print("\n=== Testing Form Filling ===")
    response = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "Please help me fill out the BWE-JKM application form", "session_id": session_id}
    )
    print_response(response)
    
    # Test document generation
    print("\n=== Testing Document Generation ===")
    response = requests.post(
        f"{BASE_URL}/chat/",
        json={"query": "Please help me write a letter applying for social security", "session_id": session_id}
    )
    print_response(response)

def print_response(response):
    try:
        data = response.json()
        print(f"Status code: {response.status_code}")
        print(f"Reply: {data.get('response')}")
        print(f"Type: {data.get('conversation_type', 'Not supported')}")
        print(f"Query: {data.get('query')}")
        print(f"Detected intent: {data.get('intent')}")
        print(f"User info: {data.get('user_info')}")
    except Exception as e:
        print(f"Error parsing response: {str(e)}")
        print(f"Raw response: {response.text}")

if __name__ == "__main__":
    test_conversation()
    # test_chat_api()