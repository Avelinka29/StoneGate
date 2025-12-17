# StoneGate - Инвестиционная платформа Беларуси

Полностековое приложение для управления инвестиционным портфелем с фокусом на белорусский рынок.

## Особенности

- **Темная тема** с зелеными акцентами (#00FF00)
- **Авторизация**: Email/пароль, социальные сети (Google, Yandex, VK)
- **Биометрия**: Face ID / Touch ID поддержка
- **Дашборд**: Баланс, график портфеля, список холдингов
- **Профиль**: Настройки пользователя, верификация
- **Mock данные**: Акции белорусских компаний (Сбербанк, Белоруснефть, Альфа-Банк, Европочта)

## Архитектура

### Backend (Python FastAPI)
- **FastAPI** - веб-фреймворк
- **SQLAlchemy** - ORM для базы данных
- **SQLite** - база данных
- **JWT** - авторизация
- **Pydantic** - валидация данных
- **Alembic** - миграции базы данных

### Frontend (SwiftUI)
- **SwiftUI** - UI фреймворк
- **LocalAuthentication** - биометрия
- **Keychain** - безопасное хранение токенов
- **URLSession** - HTTP запросы

## Запуск

### Backend

#### Быстрый старт с SQLite
```bash
cd backend
# Запускаем сервер
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

API будет доступно по адресу:
- Локально: http://127.0.0.1:8000
- Для iOS симулятора: http://[YOUR_IP]:8000 (например, http://192.168.1.101:8000)

### Frontend (iOS)

1. Откройте проект в Xcode:
```bash
open StoneGate.xcodeproj
```

2. Выберите симулятор или устройство

3. Запустите приложение (⌘+R)

## API Эндпоинты

### Авторизация
- `POST /auth/register` - Регистрация
- `POST /auth/login` - Вход
- `POST /auth/social-login` - Социальный вход

### Пользователь
- `GET /user/profile` - Профиль пользователя
- `PATCH /user/settings` - Обновление настроек
- `POST /user/verify` - Запрос верификации

### Портфель
- `GET /portfolio` - Получение портфеля

## Структура проекта

```
StoneGate/
├── backend/                    # Python FastAPI сервер
│   ├── app.py                 # Главное приложение
│   ├── database.py            # Настройки БД
│   ├── models.py              # SQLAlchemy модели
│   ├── config.py              # Конфигурация
│   ├── create_migrations.py   # Настройка Alembic
│   ├── stonegate.db           # SQLite база данных
│   ├── routers/               # API роутеры
│   │   ├── auth.py
│   │   ├── user.py
│   │   └── portfolio.py
│   └── requirements.txt
├── StoneGate/                 # iOS приложение
│   ├── StoneGateApp.swift     # Точка входа
│   ├── AuthManager.swift      # Управление авторизацией
│   ├── NetworkManager.swift   # HTTP клиент
│   ├── Models.swift           # Модели данных
│   ├── LoginView.swift        # Экран входа
│   ├── DashboardView.swift    # Дашборд
│   ├── ProfileView.swift      # Профиль
│   └── MainTabView.swift      # Навигация
└── README.md
```

## Тестирование

### Backend тестирование
```bash
# Регистрация пользователя
curl -X POST "http://127.0.0.1:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Получение портфеля
curl -X GET "http://127.0.0.1:8000/portfolio" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### iOS тестирование
- Запустите приложение в Xcode
- Зарегистрируйтесь или войдите
- Проверьте дашборд и профиль

## Безопасность

- **JWT токены** для авторизации
- **Keychain** для хранения токенов
- **LocalAuthentication** для биометрии
- **HTTPS** рекомендуется для продакшена

## Дальнейшее развитие

- [ ] Интеграция с реальными биржевыми API
- [ ] Push-уведомления
- [ ] Графики с Charts framework
- [ ] Тестирование (Unit/UITests)
- [ ] CI/CD пайплайн
