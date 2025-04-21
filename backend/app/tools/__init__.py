from langchain.tools import tool

@tool
def tool_test():
    """Test tool"""
    return "test"
