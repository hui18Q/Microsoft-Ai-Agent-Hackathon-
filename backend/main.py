from fastapi import FastAPI
from app.db.init_db import init_db
from app.api.user import router as user_router
from app.api.chat import router as chat_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="hello")

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该限制为特定域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    init_db()

app.include_router(user_router)
app.include_router(chat_router)

@app.get("/")
async def root():
    return {"status": "ok"}