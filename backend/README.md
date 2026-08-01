# StoneGate Backend API v2.0

Современный бекенд на **Flask** с **PostgreSQL** в **Docker** для инвестиционной платформы StoneGate.

## 🚀 Технологии

- **Flask 3.0** - современный Python веб-фреймворк
- **PostgreSQL 15** - надежная реляционная база данных
- **SQLAlchemy 2.0** - ORM для работы с БД
- **Flask-Migrate** - миграции базы данных
- **JWT** - безопасная аутентификация
- **Docker & Docker Compose** - контейнеризация
- **Passlib** - хеширование паролей

## 📋 Возможности

### Аутентификация
- ✅ Регистрация пользователей
- ✅ Авторизация с JWT токенами
- ✅ Социальная авторизация (Google, Yandex, VK)

### Профиль пользователя
- ✅ Просмотр и редактирование профиля
- ✅ Загрузка и удаление аватара
- ✅ Настройки уведомлений и биометрии
- ✅ Верификация аккаунта

### Портфель
- ✅ Просмотр портфеля с холдингами
- ✅ Отображение баланса и изменений
- ✅ Список всех холдингов

### Карты
- ✅ Добавление банковских карт
- ✅ Удаление карт
- ✅ Установка основной карты
- ✅ Маскировка номеров карт

## 🐳 Быстрый старт с Docker

### 1. Клонируйте репозиторий
```bash
cd /Users/vladislavkravchuk/Downloads/StoneGate/backend
```

### 2. Запустите Docker Compose
```bash
docker-compose up --build
```

Это автоматически:
- Создаст и запустит PostgreSQL контейнер
- Создаст и запустит Flask приложение
- Применит миграции базы данных
- Запустит сервер на порту 8000

### 3. Проверьте работу API
```bash
curl http://localhost:8000/
```

Ответ:
```json
{
  "message": "StoneGate API",
  "version": "2.0.0",
  "framework": "Flask",
  "database": "PostgreSQL"
}
```

### 4. Health Check
```bash
curl http://localhost:8000/health
```

## 🛠 Локальная разработка (без Docker)

### 1. Установите PostgreSQL
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get install postgresql-15
sudo systemctl start postgresql
```

### 2. Создайте базу данных
```bash
psql postgres
CREATE DATABASE stonegate_db;
CREATE USER stonegate WITH PASSWORD 'stonegate_password';
GRANT ALL PRIVILEGES ON DATABASE stonegate_db TO stonegate;
\q
```

### 3. Создайте виртуальное окружение
```bash
python3 -m venv venv
source venv/bin/activate  # На Windows: venv\Scripts\activate
```

### 4. Установите зависимости
```bash
pip install -r requirements.txt
```

### 5. Настройте переменные окружения
Создайте файл `.env`:
```bash
DATABASE_URL=postgresql://stonegate:stonegate_password@localhost:5432/stonegate_db
SECRET_KEY=your-super-secret-key-change-in-production
FLASK_ENV=development
FLASK_DEBUG=1
```

### 6. Примените миграции
```bash
export FLASK_APP=app.py
flask db upgrade
```

### 7. Запустите сервер
```bash
python app.py
```

Сервер запустится на `http://localhost:8000`

## 📚 API Endpoints

### Аутентификация

#### POST /auth/register
Регистрация нового пользователя
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "password": "secure_password",
  "phone": "+375291234567"
}
```

#### POST /auth/login
Авторизация
```json
{
  "email": "user@example.com",
  "password": "secure_password"
}
```

#### POST /auth/social-login
Социальная авторизация
```json
{
  "provider": "google",
  "token": "social_auth_token"
}
```

### Профиль пользователя

#### GET /user/profile
Получить профиль (требуется JWT токен)
```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8000/user/profile
```

#### PATCH /user/profile
Обновить профиль
```json
{
  "name": "New Name",
  "phone": "+375291234567",
  "biometrics_enabled": true
}
```

#### POST /user/avatar
Загрузить аватар (multipart/form-data)
```bash
curl -X POST -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@avatar.jpg" \
  http://localhost:8000/user/avatar
```

#### DELETE /user/avatar
Удалить аватар

#### POST /user/verify
Запросить верификацию

### Портфель

#### GET /portfolio
Получить портфель с холдингами

#### GET /portfolio/holdings
Получить список холдингов

### Карты

#### GET /cards
Получить все карты

#### POST /cards
Добавить карту
```json
{
  "card_number": "1234567890123456",
  "expiry_date": "12/25",
  "cardholder_name": "John",
  "cardholder_surname": "Doe",
  "card_type": "Домашняя",
  "is_primary": false
}
```

#### DELETE /cards/{card_id}
Удалить карту

#### PATCH /cards/{card_id}/set-primary
Установить карту как основную

## 🗄 Структура базы данных

### Таблица `users`
- `id` - уникальный идентификатор
- `email` - email (уникальный)
- `name` - имя
- `phone` - телефон
- `avatar_url` - URL аватара
- `verified` - статус верификации
- `hashed_password` - хешированный пароль
- `biometrics_enabled` - включена ли биометрия
- `notifications_enabled` - включены ли уведомления
- `created_at` - дата создания
- `updated_at` - дата обновления

### Таблица `holdings`
- `id` - уникальный идентификатор
- `user_id` - ID пользователя (FK)
- `name` - название акции
- `symbol` - символ акции
- `shares` - количество акций
- `value` - текущая стоимость
- `change` - изменение в процентах
- `change_value` - изменение в валюте
- `created_at` - дата создания
- `updated_at` - дата обновления

### Таблица `cards`
- `id` - уникальный идентификатор
- `user_id` - ID пользователя (FK)
- `card_number` - номер карты
- `expiry_date` - дата истечения
- `cardholder_name` - имя владельца
- `cardholder_surname` - фамилия владельца
- `card_type` - тип карты
- `is_primary` - основная карта
- `created_at` - дата создания
- `updated_at` - дата обновления

## 🔧 Управление миграциями

### Создать новую миграцию
```bash
# В Docker
docker-compose exec backend flask db migrate -m "description"

# Локально
flask db migrate -m "description"
```

### Применить миграции
```bash
# В Docker
docker-compose exec backend flask db upgrade

# Локально
flask db upgrade
```

### Откатить миграции
```bash
# В Docker
docker-compose exec backend flask db downgrade

# Локально
flask db downgrade
```

## 📝 Переменные окружения

| Переменная | Описание | По умолчанию |
|-----------|----------|--------------|
| `DATABASE_URL` | URL базы данных PostgreSQL | `postgresql://stonegate:stonegate_password@localhost:5432/stonegate_db` |
| `SECRET_KEY` | Секретный ключ для JWT | `your-super-secret-key-change-in-production` |
| `ALGORITHM` | Алгоритм JWT | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Время жизни токена | `30` |
| `FLASK_ENV` | Окружение Flask | `development` |
| `FLASK_DEBUG` | Режим отладки | `1` |
| `MAX_CONTENT_LENGTH` | Макс. размер файла | `5242880` (5MB) |

## 🔒 Безопасность

- ✅ Пароли хешируются с использованием **PBKDF2-SHA256**
- ✅ JWT токены для аутентификации
- ✅ CORS настроен для безопасной работы с frontend
- ✅ Валидация всех входящих данных
- ✅ SQL injection защита через SQLAlchemy ORM
- ✅ Номера карт маскируются при отправке

## 🧪 Тестирование

```bash
# В Docker
docker-compose exec backend python -m pytest

# Локально
pytest
```

## 📦 Docker команды

```bash
# Запустить все сервисы
docker-compose up

# Запустить в фоновом режиме
docker-compose up -d

# Пересобрать контейнеры
docker-compose up --build

# Остановить все сервисы
docker-compose down

# Остановить и удалить volumes
docker-compose down -v

# Посмотреть логи
docker-compose logs -f backend

# Зайти в контейнер
docker-compose exec backend bash

# Посмотреть статус
docker-compose ps
```

## 🔄 Миграция с FastAPI на Flask

Основные изменения:
- ✅ Заменён FastAPI на Flask
- ✅ Заменён SQLite на PostgreSQL
- ✅ Добавлен Docker и Docker Compose
- ✅ Переписаны все роутеры на Flask Blueprints
- ✅ Настроены миграции с Flask-Migrate
- ✅ Улучшена структура кода и обработка ошибок
- ✅ Добавлены timestamp поля для всех моделей

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose logs -f`
2. Убедитесь что PostgreSQL запущен
3. Проверьте переменные окружения
4. Примените миграции: `flask db upgrade`

## 🎯 TODO

- [ ] Добавить unit тесты
- [ ] Добавить integration тесты
- [ ] Настроить CI/CD
- [ ] Добавить rate limiting
- [ ] Добавить Redis для кеширования
- [ ] Настроить logging
- [ ] Добавить Swagger/OpenAPI документацию

---

**Версия:** 2.0.0  
**Framework:** Flask 3.0  
**Database:** PostgreSQL 15  
**Python:** 3.11+

для запуска ввести эту команду в терминал
docker-compose up --build