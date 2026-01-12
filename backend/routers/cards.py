from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import Card, CardCreate, CardResponse, User
import sys
sys.path.append('..')
from app import get_current_user

router = APIRouter()

def mask_card_number(card_number: str) -> str:
    """
    Маскирует номер карты, оставляя только последние 4 цифры.
    Например: 1234567890123456 -> **** **** **** 3456
    """
    # Удаляем все пробелы из номера
    clean_number = card_number.replace(" ", "")
    
    # Если номер меньше 4 символов, возвращаем как есть
    if len(clean_number) < 4:
        return card_number
    
    # Берем последние 4 цифры
    last_four = clean_number[-4:]
    
    # Форматируем как **** **** **** XXXX
    return f"**** **** **** {last_four}"

@router.get("", response_model=List[CardResponse])
async def get_cards(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Получить все карты текущего пользователя.
    """
    cards = db.query(Card).filter(Card.user_id == current_user.id).all()
    
    # Преобразуем карты в ответ с замаскированными номерами
    response_cards = []
    for card in cards:
        card_dict = {
            "id": card.id,
            "card_number_masked": mask_card_number(card.card_number),
            "expiry_date": card.expiry_date,
            "cardholder_name": card.cardholder_name,
            "cardholder_surname": card.cardholder_surname,
            "card_type": card.card_type,
            "is_primary": card.is_primary
        }
        response_cards.append(CardResponse(**card_dict))
    
    return response_cards

@router.post("", response_model=CardResponse, status_code=status.HTTP_201_CREATED)
async def create_card(
    card_data: CardCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Добавить новую карту для текущего пользователя.
    """
    # Если это первая карта пользователя, делаем её основной
    existing_cards = db.query(Card).filter(Card.user_id == current_user.id).count()
    is_primary = card_data.is_primary or existing_cards == 0
    
    # Если новая карта должна быть основной, снимаем флаг с других карт
    if is_primary:
        db.query(Card).filter(Card.user_id == current_user.id).update({"is_primary": False})
    
    # Создаем новую карту
    new_card = Card(
        user_id=current_user.id,
        card_number=card_data.card_number,
        expiry_date=card_data.expiry_date,
        cardholder_name=card_data.cardholder_name,
        cardholder_surname=card_data.cardholder_surname,
        card_type=card_data.card_type,
        is_primary=is_primary
    )
    
    db.add(new_card)
    db.commit()
    db.refresh(new_card)
    
    # Возвращаем карту с замаскированным номером
    card_response = CardResponse(
        id=new_card.id,
        card_number_masked=mask_card_number(new_card.card_number),
        expiry_date=new_card.expiry_date,
        cardholder_name=new_card.cardholder_name,
        cardholder_surname=new_card.cardholder_surname,
        card_type=new_card.card_type,
        is_primary=new_card.is_primary
    )
    
    return card_response

@router.delete("/{card_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_card(
    card_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Удалить карту по ID.
    """
    # Находим карту
    card = db.query(Card).filter(
        Card.id == card_id,
        Card.user_id == current_user.id
    ).first()
    
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Карта не найдена"
        )
    
    # Сохраняем флаг основной карты
    was_primary = card.is_primary
    
    # Удаляем карту
    db.delete(card)
    db.commit()
    
    # Если удаленная карта была основной, делаем основной первую из оставшихся
    if was_primary:
        first_card = db.query(Card).filter(Card.user_id == current_user.id).first()
        if first_card:
            first_card.is_primary = True
            db.commit()
    
    return None

@router.patch("/{card_id}/set-primary", response_model=CardResponse)
async def set_primary_card(
    card_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Установить карту как основную.
    """
    # Находим карту
    card = db.query(Card).filter(
        Card.id == card_id,
        Card.user_id == current_user.id
    ).first()
    
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Карта не найдена"
        )
    
    # Снимаем флаг основной со всех карт пользователя
    db.query(Card).filter(Card.user_id == current_user.id).update({"is_primary": False})
    
    # Устанавливаем выбранную карту как основную
    card.is_primary = True
    db.commit()
    db.refresh(card)
    
    # Возвращаем карту с замаскированным номером
    card_response = CardResponse(
        id=card.id,
        card_number_masked=mask_card_number(card.card_number),
        expiry_date=card.expiry_date,
        cardholder_name=card.cardholder_name,
        cardholder_surname=card.cardholder_surname,
        card_type=card.card_type,
        is_primary=card.is_primary
    )
    
    return card_response
