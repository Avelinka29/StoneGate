from flask import Blueprint, jsonify

from database import db
from models import Holding
from utils import token_required

portfolio_bp = Blueprint('portfolio', __name__)

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


@portfolio_bp.route('', methods=['GET'])
@portfolio_bp.route('/', methods=['GET'])
@token_required
def get_portfolio(current_user):
    """
    Получить портфель пользователя с холдингами.
    
    Returns:
        JSON с данными портфеля:
        - total_balance: общий баланс
        - daily_change: дневное изменение в процентах
        - daily_change_value: дневное изменение в валюте
        - holdings: список холдингов
    """
    try:
        # Для прототипа используем mock данные
        # В реальном приложении данные брались бы из БД или внешнего API
        holdings = []
        total_balance = 0.0
        total_change_value = 0.0
        
        for holding_data in MOCK_HOLDINGS:
            # Создаем или обновляем холдинг в БД для пользователя
            holding = Holding.query.filter_by(
                user_id=current_user.id,
                symbol=holding_data["symbol"]
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
                db.session.add(holding)
                db.session.commit()
            
            holdings.append(holding.to_dict())
            total_balance += holding.value
            total_change_value += holding.change_value
        
        # Рассчитываем дневное изменение в процентах
        if total_balance > total_change_value:
            daily_change = (total_change_value / (total_balance - total_change_value)) * 100
        else:
            daily_change = 0
        
        return jsonify({
            'total_balance': round(total_balance, 2),
            'daily_change': round(daily_change, 2),
            'daily_change_value': round(total_change_value, 2),
            'holdings': holdings
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to get portfolio: {str(e)}'}), 500


@portfolio_bp.route('/holdings', methods=['GET'])
@token_required
def get_holdings(current_user):
    """
    Получить список холдингов пользователя.
    
    Returns:
        JSON со списком холдингов
    """
    try:
        holdings = Holding.query.filter_by(user_id=current_user.id).all()
        
        return jsonify([holding.to_dict() for holding in holdings]), 200
        
    except Exception as e:
        return jsonify({'error': f'Failed to get holdings: {str(e)}'}), 500
