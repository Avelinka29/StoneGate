from flask import Blueprint, request, jsonify
from passlib.context import CryptContext
from datetime import datetime, timedelta
import jwt

from database import db
from models import User, UserSchema
from config import config

auth_bp = Blueprint('auth', __name__)

# Настройки для хеширования паролей
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Проверка пароля"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Хеширование пароля"""
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """
    Создание JWT токена.
    
    Args:
        data: Данные для токена
        expires_delta: Время жизни токена
    
    Returns:
        JWT токен
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, config.SECRET_KEY, algorithm=config.ALGORITHM)
    return encoded_jwt


def authenticate_user(email: str, password: str):
    """
    Аутентификация пользователя.
    
    Args:
        email: Email пользователя
        password: Пароль
    
    Returns:
        User объект или False
    """
    user = User.query.filter_by(email=email).first()
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Регистрация нового пользователя.
    
    Body:
        - email: str
        - name: str
        - password: str
        - phone: str (optional)
    
    Returns:
        JSON с токеном доступа
    """
    try:
        data = request.get_json()
        
        # Валидация данных
        is_valid, error_message = UserSchema.validate_create(data)
        if not is_valid:
            return jsonify({'error': error_message}), 400
        
        # Проверяем, существует ли пользователь
        existing_user = User.query.filter_by(email=data['email']).first()
        if existing_user:
            return jsonify({'error': 'Email already registered'}), 400
        
        # Создаем нового пользователя
        hashed_password = get_password_hash(data['password'])
        new_user = User(
            email=data['email'],
            name=data['name'],
            phone=data.get('phone'),
            hashed_password=hashed_password,
            verified=False
        )
        
        db.session.add(new_user)
        db.session.commit()
        
        # Создаем токен доступа
        access_token_expires = timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": new_user.email},
            expires_delta=access_token_expires
        )
        
        return jsonify({
            'access_token': access_token,
            'token_type': 'bearer'
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500


@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Авторизация пользователя.
    
    Body:
        - email: str
        - password: str
    
    Returns:
        JSON с токеном доступа
    """
    try:
        data = request.get_json()
        
        if not data or 'email' not in data or 'password' not in data:
            return jsonify({'error': 'Email and password are required'}), 400
        
        # Аутентификация пользователя
        user = authenticate_user(data['email'], data['password'])
        if not user:
            return jsonify({'error': 'Incorrect email or password'}), 401
        
        # Создаем токен доступа
        access_token_expires = timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email},
            expires_delta=access_token_expires
        )
        
        return jsonify({
            'access_token': access_token,
            'token_type': 'bearer'
        }), 200
        
    except Exception as e:
        return jsonify({'error': f'Login failed: {str(e)}'}), 500


@auth_bp.route('/social-login', methods=['POST'])
def social_login():
    """
    Социальная авторизация (Google, Yandex, VK).
    
    Body:
        - provider: str (google, yandex, vk)
        - token: str
    
    Returns:
        JSON с токеном доступа
    """
    try:
        data = request.get_json()
        
        if not data or 'provider' not in data or 'token' not in data:
            return jsonify({'error': 'Provider and token are required'}), 400
        
        provider = data['provider']
        
        # Mock данные для социального входа
        # В реальном приложении здесь была бы валидация токена провайдера
        social_users = {
            "google": {"email": "user@gmail.com", "name": "Google User"},
            "yandex": {"email": "user@yandex.by", "name": "Yandex User"},
            "vk": {"email": "user@vk.com", "name": "VK User"}
        }
        
        if provider not in social_users:
            return jsonify({'error': 'Unsupported provider'}), 400
        
        user_data = social_users[provider]
        user = User.query.filter_by(email=user_data["email"]).first()
        
        if not user:
            # Создаем пользователя если не существует
            user = User(
                email=user_data["email"],
                name=user_data["name"],
                verified=True,
                hashed_password=get_password_hash("social_auth")  # Не используется для социальных входов
            )
            db.session.add(user)
            db.session.commit()
        
        # Создаем токен доступа
        access_token_expires = timedelta(minutes=config.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.email},
            expires_delta=access_token_expires
        )
        
        return jsonify({
            'access_token': access_token,
            'token_type': 'bearer'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Social login failed: {str(e)}'}), 500
