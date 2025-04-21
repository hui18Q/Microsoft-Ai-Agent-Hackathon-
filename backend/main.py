from fastapi import FastAPI
from app.db.init_db import init_db
from app.api.user import router as user_router
from app.api.chat import router as chat_router

app = FastAPI(title="hello")

@app.on_event("startup")
async def startup_event():
    init_db()

app.include_router(user_router)
app.include_router(chat_router)

@app.get("/")
async def root():
    return {"status": "ok"}