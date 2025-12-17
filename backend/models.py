from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from pydantic import BaseModel
from database import Base

# SQLAlchemy модели
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    name = Column(String)
    phone = Column(String, nullable=True)
    verified = Column(Boolean, default=False)
    hashed_password = Column(String)
    biometrics_enabled = Column(Boolean, default=False)
    notifications_enabled = Column(Boolean, default=True)

    holdings = relationship("Holding", back_populates="owner")

class Holding(Base):
    __tablename__ = "holdings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String)  # Название акции
    symbol = Column(String)  # Символ акции
    shares = Column(Integer)  # Количество акций
    value = Column(Float)  # Текущая стоимость в BYN
    change = Column(Float)  # Изменение в процентах
    change_value = Column(Float)  # Изменение в BYN

    owner = relationship("User", back_populates="holdings")

# Pydantic схемы
class UserBase(BaseModel):
    email: str
    name: str
    phone: str | None = None

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: str
    password: str

class UserUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    biometrics_enabled: bool | None = None
    notifications_enabled: bool | None = None

class UserResponse(UserBase):
    id: int
    verified: bool
    biometrics_enabled: bool
    notifications_enabled: bool

    class Config:
        from_attributes = True

class HoldingResponse(BaseModel):
    id: int
    name: str
    symbol: str
    shares: int
    value: float
    change: float
    change_value: float

    class Config:
        from_attributes = True

class PortfolioResponse(BaseModel):
    total_balance: float
    daily_change: float
    daily_change_value: float
    holdings: list[HoldingResponse]

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: str | None = None
