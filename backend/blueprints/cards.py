from flask import Blueprint, request, jsonify

from database import db
from models import Card, CardSchema
from utils import token_required, mask_card_number

cards_bp = Blueprint('cards', __name__)


@cards_bp.route('', methods=['GET'])
@cards_bp.route('/', methods=['GET'])
@token_required
def get_cards(current_user):
    """
    Получить все карты текущего пользователя.
    
    Returns:
        JSON со списком карт (с замаскированными номерами)
    """
    try:
        cards = Card.query.filter_by(user_id=current_user.id).all()
        
        return jsonify([card.to_dict(mask_number=True) for card in cards]), 200
        
    except Exception as e:
        return jsonify({'error': f'Failed to get cards: {str(e)}'}), 500


@cards_bp.route('', methods=['POST'])
@cards_bp.route('/', methods=['POST'])
@token_required
def create_card(current_user):
    """
    Добавить новую карту для текущего пользователя.
    
    Body:
        - card_number: str
        - expiry_date: str (MM/YY)
        - cardholder_name: str
        - cardholder_surname: str
        - card_type: str (Домашняя, Рабочая и т.д.)
        - is_primary: bool (optional)
    
    Returns:
        JSON с данными созданной карты
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Валидация данных
        is_valid, error_message = CardSchema.validate_create(data)
        if not is_valid:
            return jsonify({'error': error_message}), 400
        
        # Если это первая карта пользователя, делаем её основной
        existing_cards_count = Card.query.filter_by(user_id=current_user.id).count()
        is_primary = data.get('is_primary', False) or existing_cards_count == 0
        
        # Если новая карта должна быть основной, снимаем флаг с других карт
        if is_primary:
            Card.query.filter_by(user_id=current_user.id).update({"is_primary": False})
        
        # Создаем новую карту
        new_card = Card(
            user_id=current_user.id,
            card_number=data['card_number'],
            expiry_date=data['expiry_date'],
            cardholder_name=data['cardholder_name'],
            cardholder_surname=data['cardholder_surname'],
            card_type=data['card_type'],
            is_primary=is_primary
        )
        
        db.session.add(new_card)
        db.session.commit()
        
        return jsonify(new_card.to_dict(mask_number=True)), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to create card: {str(e)}'}), 500


@cards_bp.route('/<int:card_id>', methods=['DELETE'])
@token_required
def delete_card(current_user, card_id):
    """
    Удалить карту по ID.
    
    Args:
        card_id: ID карты
    
    Returns:
        204 No Content при успехе
    """
    try:
        # Находим карту
        card = Card.query.filter_by(
            id=card_id,
            user_id=current_user.id
        ).first()
        
        if not card:
            return jsonify({'error': 'Card not found'}), 404
        
        # Сохраняем флаг основной карты
        was_primary = card.is_primary
        
        # Удаляем карту
        db.session.delete(card)
        db.session.commit()
        
        # Если удаленная карта была основной, делаем основной первую из оставшихся
        if was_primary:
            first_card = Card.query.filter_by(user_id=current_user.id).first()
            if first_card:
                first_card.is_primary = True
                db.session.commit()
        
        return '', 204
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to delete card: {str(e)}'}), 500


@cards_bp.route('/<int:card_id>/set-primary', methods=['PATCH'])
@token_required
def set_primary_card(current_user, card_id):
    """
    Установить карту как основную.
    
    Args:
        card_id: ID карты
    
    Returns:
        JSON с данными обновленной карты
    """
    try:
        # Находим карту
        card = Card.query.filter_by(
            id=card_id,
            user_id=current_user.id
        ).first()
        
        if not card:
            return jsonify({'error': 'Card not found'}), 404
        
        # Снимаем флаг основной со всех карт пользователя
        Card.query.filter_by(user_id=current_user.id).update({"is_primary": False})
        
        # Устанавливаем выбранную карту как основную
        card.is_primary = True
        db.session.commit()
        
        return jsonify(card.to_dict(mask_number=True)), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to set primary card: {str(e)}'}), 500
