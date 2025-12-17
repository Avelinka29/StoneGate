from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from datetime import timedelta
from typing import Union

from database import get_db
from models import User, UserCreate, UserLogin, Token
from app import create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter()

# Настройки паролей
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_user(db: Session, user: UserCreate):
    # Проверяем, существует ли пользователь
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Создаем нового пользователя
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        name=user.name,
        phone=user.phone,
        hashed_password=hashed_password,
        verified=False
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.post("/register", response_model=Token)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """Регистрация нового пользователя"""
    db_user = create_user(db, user)

    # Создаем токен доступа
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": db_user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/login", response_model=Token)
async def login(user: UserLogin, db: Session = Depends(get_db)):
    """Авторизация пользователя"""
    db_user = authenticate_user(db, user.email, user.password)
    if not db_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Создаем токен доступа
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": db_user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/social-login", response_model=Token)
async def social_login(provider: str, token: str, db: Session = Depends(get_db)):
    """Социальная авторизация (Google, Yandex, VK)"""
    # В реальном приложении здесь была бы валидация токена провайдера
    # Для прототипа просто создаем/находим пользователя

    # Mock данные для социального входа
    social_users = {
        "google": {"email": "user@gmail.com", "name": "Google User"},
        "yandex": {"email": "user@yandex.by", "name": "Yandex User"},
        "vk": {"email": "user@vk.com", "name": "VK User"}
    }

    if provider not in social_users:
        raise HTTPException(status_code=400, detail="Unsupported provider")

    user_data = social_users[provider]
    user = db.query(User).filter(User.email == user_data["email"]).first()

    if not user:
        # Создаем пользователя если не существует
        user = User(
            email=user_data["email"],
            name=user_data["name"],
            verified=True,
            hashed_password=get_password_hash("social_auth")  # Не используется для социальных входов
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}
