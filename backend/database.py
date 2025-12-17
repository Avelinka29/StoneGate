from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import os

# Настройки базы данных SQLite
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./stonegate.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={
        "check_same_thread": False,
    },
    poolclass=StaticPool,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Функция для получения сессии БД
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Функция для создания всех таблиц
def create_tables():
    Base.metadata.create_all(bind=engine)

# Функция для удаления всех таблиц
def drop_tables():
    Base.metadata.drop_all(bind=engine)
