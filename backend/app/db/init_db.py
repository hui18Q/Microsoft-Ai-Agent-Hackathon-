from sqlalchemy.orm import Session
from app.db.database import engine, Base
import app.models  

def init_db():
    Base.metadata.create_all(bind=engine)
