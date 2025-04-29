
## Installation

0. OPENAI_API_KEY should be set in chat_service to enable access to the DeepSeek V3 model.

1. clone project
```bash
git clone git@github.com:hui18Q/Microsoft-Ai-Agent-Hackathon-.git
cd backend
```

2. create virtual environment
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```

3. install dependencies
```bash
```

4. environment variables
create `.env` and add the following variables

5. run Docker
```bash
docker-compose up -d
```

6. run server
```bash
uvicorn main:app --reload
```

## API documentation

- Swagger UI: http://localhost:8000/docs

## Running the test script
1. Make sure the backend server is running
2. Run the test script:
```bash
python test_api.py
```
### Available test functions

- `test_conversation()`: Tests continuous multi-turn conversation with memory
- `test_chat_api()`: Tests different conversation types (general, aid inquiry, form filling, document generation)


## Development guide

1. commit format
- feat: new feature
- fix: fix bug
- style: code style
- refactor: code refactoring

## License

MIT License 