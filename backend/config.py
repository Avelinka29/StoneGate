import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
    DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./stonegate.db")
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    ALGORITHM = "HS256"

config = Config()
