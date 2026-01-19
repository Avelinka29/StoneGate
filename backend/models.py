from database import db
from datetime import datetime
from typing import Optional

# SQLAlchemy модели для Flask

class User(db.Model):
    """Модель пользователя"""
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True, index=True)
    email = db.Column(db.String(255), unique=True, index=True, nullable=False)
    name = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(50), nullable=True)
    avatar_url = db.Column(db.String(500), nullable=True)
    verified = db.Column(db.Boolean, default=False)
    hashed_password = db.Column(db.String(255), nullable=False)
    biometrics_enabled = db.Column(db.Boolean, default=False)
    notifications_enabled = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    holdings = db.relationship("Holding", back_populates="owner", cascade="all, delete-orphan")
    cards = db.relationship("Card", back_populates="owner", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User {self.email}>"

    def to_dict(self, include_sensitive=False):
        """Преобразовать модель в словарь"""
        data = {
            'id': self.id,
            'email': self.email,
            'name': self.name,
            'phone': self.phone,
            'avatar_url': self.avatar_url,
            'verified': self.verified,
            'biometrics_enabled': self.biometrics_enabled,
            'notifications_enabled': self.notifications_enabled,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
        if include_sensitive:
            data['hashed_password'] = self.hashed_password
        return data


class Holding(db.Model):
    """Модель холдинга (акции в портфеле)"""
    __tablename__ = "holdings"

    id = db.Column(db.Integer, primary_key=True, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = db.Column(db.String(255), nullable=False)  # Название акции
    symbol = db.Column(db.String(50), nullable=False)  # Символ акции
    shares = db.Column(db.Integer, nullable=False, default=0)  # Количество акций
    value = db.Column(db.Float, nullable=False, default=0.0)  # Текущая стоимость в BYN
    change = db.Column(db.Float, nullable=False, default=0.0)  # Изменение в процентах
    change_value = db.Column(db.Float, nullable=False, default=0.0)  # Изменение в BYN
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    owner = db.relationship("User", back_populates="holdings")

    def __repr__(self):
        return f"<Holding {self.symbol} - {self.name}>"

    def to_dict(self):
        """Преобразовать модель в словарь"""
        return {
            'id': self.id,
            'name': self.name,
            'symbol': self.symbol,
            'shares': self.shares,
            'value': self.value,
            'change': self.change,
            'change_value': self.change_value,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


class Card(db.Model):
    """Модель банковской карты"""
    __tablename__ = "cards"

    id = db.Column(db.Integer, primary_key=True, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    card_number = db.Column(db.String(255), nullable=False)  # Полный номер карты (будет шифроваться)
    expiry_date = db.Column(db.String(10), nullable=False)  # Дата истечения MM/ГГ
    cardholder_name = db.Column(db.String(100), nullable=False)  # Имя владельца
    cardholder_surname = db.Column(db.String(100), nullable=False)  # Фамилия владельца
    card_type = db.Column(db.String(50), nullable=False)  # Тип карты: "Домашняя" или "Рабочая"
    is_primary = db.Column(db.Boolean, default=False)  # Основная карта
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    owner = db.relationship("User", back_populates="cards")

    def __repr__(self):
        return f"<Card {self.card_type} - {self.get_masked_number()}>"

    def get_masked_number(self):
        """Получить замаскированный номер карты"""
        clean_number = self.card_number.replace(" ", "")
        if len(clean_number) < 4:
            return self.card_number
        last_four = clean_number[-4:]
        return f"**** **** **** {last_four}"

    def to_dict(self, mask_number=True):
        """Преобразовать модель в словарь"""
        return {
            'id': self.id,
            'card_number_masked' if mask_number else 'card_number': self.get_masked_number() if mask_number else self.card_number,
            'expiry_date': self.expiry_date,
            'cardholder_name': self.cardholder_name,
            'cardholder_surname': self.cardholder_surname,
            'card_type': self.card_type,
            'is_primary': self.is_primary,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }


# Pydantic-like схемы для валидации (можно использовать с marshmallow или pydantic)
class UserSchema:
    """Схема для валидации данных пользователя"""
    
    @staticmethod
    def validate_create(data: dict) -> tuple[bool, Optional[str]]:
        """Валидация данных при создании пользователя"""
        required_fields = ['email', 'name', 'password']
        for field in required_fields:
            if field not in data or not data[field]:
                return False, f"Field '{field}' is required"
        
        if len(data['password']) < 6:
            return False, "Password must be at least 6 characters long"
        
        if '@' not in data['email']:
            return False, "Invalid email format"
        
        return True, None
    
    @staticmethod
    def validate_update(data: dict) -> tuple[bool, Optional[str]]:
        """Валидация данных при обновлении пользователя"""
        if 'email' in data and '@' not in data['email']:
            return False, "Invalid email format"
        return True, None


class CardSchema:
    """Схема для валидации данных карты"""
    
    @staticmethod
    def validate_create(data: dict) -> tuple[bool, Optional[str]]:
        """Валидация данных при создании карты"""
        required_fields = ['card_number', 'expiry_date', 'cardholder_name', 'cardholder_surname', 'card_type']
        for field in required_fields:
            if field not in data or not data[field]:
                return False, f"Field '{field}' is required"
        
        # Проверка номера карты (только цифры и пробелы)
        card_number = data['card_number'].replace(' ', '')
        if not card_number.isdigit() or len(card_number) < 13 or len(card_number) > 19:
            return False, "Invalid card number format"
        
        # Проверка формата даты истечения (MM/ГГ)
        expiry = data['expiry_date']
        if '/' not in expiry:
            return False, "Expiry date must be in MM/YY format"
        
        parts = expiry.split('/')
        if len(parts) != 2 or not parts[0].isdigit() or not parts[1].isdigit():
            return False, "Expiry date must be in MM/YY format"
        
        month = int(parts[0])
        if month < 1 or month > 12:
            return False, "Invalid month in expiry date"
        
        return True, None
