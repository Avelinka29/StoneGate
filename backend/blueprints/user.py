from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from pathlib import Path
import uuid
import os

from database import db
from models import User, UserSchema
from utils import token_required, allowed_file
from config import config

user_bp = Blueprint('user', __name__)

# Создаем папку для аватаров если её нет
UPLOAD_DIR = Path(config.UPLOAD_FOLDER)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@user_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """
    Получить профиль текущего пользователя.
    
    Returns:
        JSON с данными пользователя
    """
    try:
        return jsonify(current_user.to_dict()), 200
    except Exception as e:
        return jsonify({'error': f'Failed to get profile: {str(e)}'}), 500


@user_bp.route('/profile', methods=['PATCH'])
@token_required
def update_profile(current_user):
    """
    Обновить профиль текущего пользователя.
    
    Body:
        - name: str (optional)
        - email: str (optional)
        - phone: str (optional)
        - biometrics_enabled: bool (optional)
        - notifications_enabled: bool (optional)
    
    Returns:
        JSON с обновленными данными пользователя
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Валидация данных
        is_valid, error_message = UserSchema.validate_update(data)
        if not is_valid:
            return jsonify({'error': error_message}), 400
        
        # Проверяем, если меняется email, что он уникален
        if 'email' in data and data['email'] != current_user.email:
            existing_user = User.query.filter_by(email=data['email']).first()
            if existing_user:
                return jsonify({'error': 'Email already registered'}), 400
        
        # Обновляем поля
        allowed_fields = ['name', 'email', 'phone', 'biometrics_enabled', 'notifications_enabled']
        for field in allowed_fields:
            if field in data:
                setattr(current_user, field, data[field])
        
        db.session.commit()
        
        return jsonify(current_user.to_dict()), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to update profile: {str(e)}'}), 500


@user_bp.route('/settings', methods=['PATCH'])
@token_required
def update_settings(current_user):
    """
    Обновить настройки пользователя (для обратной совместимости).
    Альтернативный эндпоинт для update_profile.
    """
    return update_profile(current_user)


@user_bp.route('/avatar', methods=['POST'])
@token_required
def upload_avatar(current_user):
    """
    Загрузить аватар пользователя.
    
    Form Data:
        - file: файл изображения
    
    Returns:
        JSON с URL загруженного аватара
    """
    try:
        # Проверяем наличие файла
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Проверяем тип файла
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Only JPEG, PNG and WEBP are allowed'}), 400
        
        # Проверяем размер файла
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        if file_size > config.MAX_CONTENT_LENGTH:
            return jsonify({'error': 'File size too large. Maximum 5MB allowed'}), 400
        
        # Удаляем старый аватар если он есть
        if current_user.avatar_url:
            old_file_path = Path(current_user.avatar_url.replace("/uploads/", "uploads/"))
            if old_file_path.exists():
                try:
                    old_file_path.unlink()
                except Exception:
                    pass  # Игнорируем ошибки удаления старого файла
        
        # Генерируем уникальное имя файла
        file_extension = secure_filename(file.filename).rsplit('.', 1)[1].lower()
        unique_filename = f"{uuid.uuid4()}.{file_extension}"
        file_path = UPLOAD_DIR / unique_filename
        
        # Сохраняем файл
        file.save(str(file_path))
        
        # Обновляем URL аватара в базе данных
        avatar_url = f"/uploads/avatars/{unique_filename}"
        current_user.avatar_url = avatar_url
        db.session.commit()
        
        return jsonify({
            'avatar_url': avatar_url,
            'message': 'Avatar uploaded successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to upload avatar: {str(e)}'}), 500


@user_bp.route('/avatar', methods=['DELETE'])
@token_required
def delete_avatar(current_user):
    """
    Удалить аватар пользователя.
    
    Returns:
        JSON с сообщением об успехе
    """
    try:
        if not current_user.avatar_url:
            return jsonify({'error': 'No avatar to delete'}), 404
        
        # Удаляем файл
        file_path = Path(current_user.avatar_url.replace("/uploads/", "uploads/"))
        if file_path.exists():
            try:
                file_path.unlink()
            except Exception:
                pass  # Игнорируем ошибки удаления файла
        
        # Удаляем URL из базы данных
        current_user.avatar_url = None
        db.session.commit()
        
        return jsonify({'message': 'Avatar deleted successfully'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to delete avatar: {str(e)}'}), 500


@user_bp.route('/verify', methods=['POST'])
@token_required
def request_verification(current_user):
    """
    Запросить верификацию аккаунта.
    
    Returns:
        JSON с сообщением об успехе
    """
    try:
        if current_user.verified:
            return jsonify({'error': 'User already verified'}), 400
        
        # В реальном приложении здесь была бы отправка email/SMS
        # Для прототипа просто устанавливаем verified=True
        current_user.verified = True
        db.session.commit()
        
        return jsonify({
            'message': 'Verification request sent',
            'verified': True
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to verify user: {str(e)}'}), 500
