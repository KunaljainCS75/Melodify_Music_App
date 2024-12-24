
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
load_dotenv()

DATABASE_URL = f"postgresql://postgres:{os.getenv('PASSWORD')}%400799@localhost:5432/flutter_music_app"
# Starting point for sql alchemy application that needs to connect to external database
engine = create_engine(DATABASE_URL) 
SessionLocal = sessionmaker(autocommit = False, autoflush = False, bind = engine)

# dependency injection
def get_db():
    db = SessionLocal()
    try:
     yield db
     #when finally when any function (auth.py) calls off...automatically close db
    finally:
       db.close()