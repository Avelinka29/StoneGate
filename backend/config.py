import os
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

class Config:
    """Базовая конфигурация приложения"""
    
    # Secret key для JWT и Flask
    SECRET_KEY = os.getenv('SECRET_KEY', 'your-super-secret-key-change-in-production')
    
    # Алгоритм шифрования JWT
    ALGORITHM = os.getenv('ALGORITHM', 'HS256')
    
    # Время жизни токена (в минутах)
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv('ACCESS_TOKEN_EXPIRE_MINUTES', '30'))
    
    # Database URL
    DATABASE_URL = os.getenv(
        'DATABASE_URL',
        'postgresql://stonegate:stonegate_password@localhost:5432/stonegate_db'
    )
    
    # Для работы SQLAlchemy с PostgreSQL
    SQLALCHEMY_DATABASE_URI = DATABASE_URL
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
    }
    
    # Flask настройки
    DEBUG = os.getenv('FLASK_DEBUG', '0') == '1'
    TESTING = False
    
    # Upload настройки
    MAX_CONTENT_LENGTH = int(os.getenv('MAX_CONTENT_LENGTH', 5 * 1024 * 1024))  # 5MB
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads/avatars')
    ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
    
    # CORS настройки
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')


class DevelopmentConfig(Config):
    """Конфигурация для разработки"""
    DEBUG = True


class ProductionConfig(Config):
    """Конфигурация для продакшена"""
    DEBUG = False


class TestingConfig(Config):
    """Конфигурация для тестирования"""
    TESTING = True
    DATABASE_URL = os.getenv('TEST_DATABASE_URL', 'sqlite:///test.db')
    SQLALCHEMY_DATABASE_URI = DATABASE_URL


# Словарь конфигураций
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}

# Получаем текущую конфигурацию
def get_config():
    env = os.getenv('FLASK_ENV', 'development')
    return config_by_name.get(env, DevelopmentConfig)

# Экспортируем объект конфигурации
config = get_config()
