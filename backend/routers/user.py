from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
import os
import uuid
import shutil
from pathlib import Path

from database import get_db
from models import UserResponse, UserUpdate
from app import get_current_user

router = APIRouter()

# Создаем папку для аватаров если её нет
UPLOAD_DIR = Path("uploads/avatars")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

@router.get("/profile", response_model=UserResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """Получить профиль пользователя"""
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        name=current_user.name,
        phone=current_user.phone,
        avatar_url=current_user.avatar_url,
        verified=current_user.verified,
        biometrics_enabled=current_user.biometrics_enabled,
        notifications_enabled=current_user.notifications_enabled
    )

@router.patch("/profile", response_model=UserResponse)
async def update_profile(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Обновить профиль пользователя"""
    update_data = user_update.dict(exclude_unset=True)

    # Проверяем, если меняется email, что он уникален
    if "email" in update_data and update_data["email"] != current_user.email:
        from models import User
        existing_user = db.query(User).filter(User.email == update_data["email"]).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

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
        avatar_url=current_user.avatar_url,
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
    """Обновить настройки пользователя (для обратной совместимости)"""
    return await update_profile(user_update, current_user, db)

@router.post("/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Загрузить аватар пользователя"""
    # Проверяем тип файла
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "image/webp"]
    if file.content_type not in allowed_types:
        raise HTTPException(status_code=400, detail="Invalid file type. Only JPEG, PNG and WEBP are allowed")

    # Проверяем размер файла (максимум 5MB)
    file.file.seek(0, 2)  # Переходим в конец файла
    file_size = file.file.tell()  # Получаем размер
    file.file.seek(0)  # Возвращаемся в начало
    
    if file_size > 5 * 1024 * 1024:  # 5MB
        raise HTTPException(status_code=400, detail="File size too large. Maximum 5MB allowed")

    # Удаляем старый аватар если он есть
    if current_user.avatar_url:
        old_file_path = Path(current_user.avatar_url.replace("/uploads/", "uploads/"))
        if old_file_path.exists():
            old_file_path.unlink()

    # Генерируем уникальное имя файла
    file_extension = file.filename.split(".")[-1]
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    file_path = UPLOAD_DIR / unique_filename

    # Сохраняем файл
    with file_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Обновляем URL аватара в базе данных
    avatar_url = f"/uploads/avatars/{unique_filename}"
    current_user.avatar_url = avatar_url
    db.commit()

    return {"avatar_url": avatar_url, "message": "Avatar uploaded successfully"}

@router.delete("/avatar")
async def delete_avatar(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Удалить аватар пользователя"""
    if not current_user.avatar_url:
        raise HTTPException(status_code=404, detail="No avatar to delete")

    # Удаляем файл
    file_path = Path(current_user.avatar_url.replace("/uploads/", "uploads/"))
    if file_path.exists():
        file_path.unlink()

    # Удаляем URL из базы данных
    current_user.avatar_url = None
    db.commit()

    return {"message": "Avatar deleted successfully"}

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
