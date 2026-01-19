from functools import wraps
from flask import request, jsonify
import jwt

from config import config
from models import User


def get_token_from_header():
    """
    Извлечь JWT токен из заголовка Authorization.
    
    Returns:
        Токен или None
    """
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return None
    
    # Ожидаем формат: "Bearer <token>"
    parts = auth_header.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer':
        return None
    
    return parts[1]


def verify_token(token):
    """
    Проверить JWT токен и вернуть email пользователя.
    
    Args:
        token: JWT токен
    
    Returns:
        Email пользователя или None
    """
    try:
        payload = jwt.decode(token, config.SECRET_KEY, algorithms=[config.ALGORITHM])
        email = payload.get("sub")
        return email
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


def token_required(f):
    """
    Декоратор для защиты эндпоинтов, требующих аутентификации.
    Проверяет JWT токен и добавляет объект пользователя в аргументы функции.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = get_token_from_header()
        
        if not token:
            return jsonify({'error': 'Authentication token is missing'}), 401
        
        email = verify_token(token)
        if not email:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        # Получаем пользователя из базы данных
        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Добавляем пользователя в kwargs
        return f(current_user=user, *args, **kwargs)
    
    return decorated_function


def allowed_file(filename, allowed_extensions=None):
    """
    Проверить, разрешен ли тип файла.
    
    Args:
        filename: Имя файла
        allowed_extensions: Набор разрешенных расширений
    
    Returns:
        True если файл разрешен, иначе False
    """
    if allowed_extensions is None:
        allowed_extensions = config.ALLOWED_EXTENSIONS
    
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions


def mask_card_number(card_number: str) -> str:
    """
    Маскировать номер карты, оставляя только последние 4 цифры.
    
    Args:
        card_number: Полный номер карты
    
    Returns:
        Замаскированный номер карты
    """
    clean_number = card_number.replace(" ", "")
    
    if len(clean_number) < 4:
        return card_number
    
    last_four = clean_number[-4:]
    return f"**** **** **** {last_four}"


def format_response(data=None, message=None, status_code=200):
    """
    Форматировать ответ API в единообразном формате.
    
    Args:
        data: Данные для возврата
        message: Сообщение
        status_code: HTTP статус код
    
    Returns:
        JSON ответ и статус код
    """
    response = {}
    
    if message:
        response['message'] = message
    
    if data is not None:
        response['data'] = data
    
    return jsonify(response), status_code


def error_response(message, status_code=400):
    """
    Форматировать ответ об ошибке.
    
    Args:
        message: Сообщение об ошибке
        status_code: HTTP статус код
    
    Returns:
        JSON ответ и статус код
    """
    return jsonify({'error': message}), status_code
