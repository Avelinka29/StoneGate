from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import PortfolioResponse, HoldingResponse, Holding
from app import get_current_user

router = APIRouter()

# Mock данные для акций белорусских компаний
MOCK_HOLDINGS = [
    {
        "name": "Сбербанк",
        "symbol": "SBER",
        "shares": 58,
        "value": 1852.38,
        "change": 15.81,
        "change_value": 253.45
    },
    {
        "name": "Белоруснефть",
        "symbol": "BNFT",
        "shares": 125,
        "value": 2875.00,
        "change": -3.24,
        "change_value": -96.43
    },
    {
        "name": "Альфа-Банк",
        "symbol": "ALFA",
        "shares": 89,
        "value": 1456.78,
        "change": 8.92,
        "change_value": 119.67
    },
    {
        "name": "Европочта",
        "symbol": "EVRO",
        "shares": 234,
        "value": 3421.56,
        "change": 22.15,
        "change_value": 617.89
    }
]

@router.get("", response_model=PortfolioResponse)
async def get_portfolio(current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """Получить портфель пользователя с холдингами"""

    # Для прототипа используем mock данные
    # В реальном приложении данные брались бы из БД
    holdings = []
    total_balance = 0.0
    total_change_value = 0.0

    for holding_data in MOCK_HOLDINGS:
        # Создаем или обновляем холдинг в БД для пользователя
        holding = db.query(Holding).filter(
            Holding.user_id == current_user.id,
            Holding.symbol == holding_data["symbol"]
        ).first()

        if not holding:
            holding = Holding(
                user_id=current_user.id,
                name=holding_data["name"],
                symbol=holding_data["symbol"],
                shares=holding_data["shares"],
                value=holding_data["value"],
                change=holding_data["change"],
                change_value=holding_data["change_value"]
            )
            db.add(holding)
            db.commit()
            db.refresh(holding)

        holdings.append(HoldingResponse(
            id=holding.id,
            name=holding.name,
            symbol=holding.symbol,
            shares=holding.shares,
            value=holding.value,
            change=holding.change,
            change_value=holding.change_value
        ))

        total_balance += holding.value
        total_change_value += holding.change_value

    # Рассчитываем дневное изменение в процентах
    daily_change = (total_change_value / (total_balance - total_change_value)) * 100 if total_balance > total_change_value else 0

    return PortfolioResponse(
        total_balance=round(total_balance, 2),
        daily_change=round(daily_change, 2),
        daily_change_value=round(total_change_value, 2),
        holdings=holdings
    )

@router.get("/holdings", response_model=List[HoldingResponse])
async def get_holdings(current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """Получить список холдингов пользователя"""
    holdings = db.query(Holding).filter(Holding.user_id == current_user.id).all()
    return [HoldingResponse.from_orm(holding) for holding in holdings]
