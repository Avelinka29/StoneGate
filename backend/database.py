from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

# Инициализация SQLAlchemy
db = SQLAlchemy()
migrate = Migrate()


def init_db(app):
    """
    Инициализация базы данных с приложением Flask.

    Args:
        app: Flask приложение
    """
    db.init_app(app)
    migrate.init_app(app, db)

    with app.app_context():
        # Импортируем модели чтобы они были зарегистрированы
        from models import User, Holding, Card

        # Создаем все таблицы (для разработки)
        # В продакшене используйте миграции
        db.create_all()
        print("✅ Database tables created successfully!")


def get_db_session():
    """
    Получить сессию базы данных для использования в эндпоинтах.
    
    Returns:
        SQLAlchemy сессия
    """
    return db.session


class DatabaseManager:
    """Менеджер базы данных для различных операций"""
    
@staticmethod
def create_tables():
        """Создать все таблицы в базе данных"""
        db.create_all()

@staticmethod
def drop_tables():
        """Удалить все таблицы из базы данных"""
        db.drop_all()
    
@staticmethod
def reset_database():
    """Сбросить базу данных (удалить и создать заново)"""
    db.drop_all()
    db.create_all()

@staticmethod
def commit():
    """Зафиксировать изменения в базе данных"""
    try:
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        raise e

@staticmethod
def rollback():
    """Откатить изменения в базе данных"""
    db.session.rollback()

@staticmethod
def add(obj):
    """
    Добавить объект в сессию
    
    Args:
        obj: SQLAlchemy модель
    """
    db.session.add(obj)

@staticmethod
def delete(obj):
    """
    Удалить объект из базы данных
    
    Args:
        obj: SQLAlchemy модель
    """
    db.session.delete(obj)

@staticmethod
def query(model):
    """
    Создать запрос для модели
    
    Args:
        model: SQLAlchemy модель
        
    Returns:
        Query объект
    """
    return db.session.query(model)
