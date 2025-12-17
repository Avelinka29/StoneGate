from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import UserResponse, UserUpdate
from app import get_current_user

router = APIRouter()

@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Получить профиль пользователя"""
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        name=current_user.name,
        phone=current_user.phone,
        verified=current_user.verified,
        biometrics_enabled=current_user.biometrics_enabled,
        notifications_enabled=current_user.notifications_enabled
    )

@router.patch("/settings", response_model=UserResponse)
async def update_settings(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Обновить настройки пользователя"""
    update_data = user_update.dict(exclude_unset=True)

    for field, value in update_data.items():
        if hasattr(current_user, field):
            setattr(current_user, field, value)

    db.commit()
    db.refresh(current_user)

    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        name=current_user.name,
        phone=current_user.phone,
        verified=current_user.verified,
        biometrics_enabled=current_user.biometrics_enabled,
        notifications_enabled=current_user.notifications_enabled
    )

@router.post("/verify")
async def request_verification(current_user: dict = Depends(get_current_user), db: Session = Depends(get_db)):
    """Запросить верификацию аккаунта"""
    # В реальном приложении здесь была бы отправка email/SMS
    # Для прототипа просто устанавливаем verified=True

    if current_user.verified:
        raise HTTPException(status_code=400, detail="User already verified")

    current_user.verified = True
    db.commit()

    return {"message": "Verification request sent", "verified": True}
