# 🚀 Быстрый старт StoneGate Backend

## Запуск за 3 команды

### 1. Перейдите в директорию backend
```bash
cd /Users/vladislavkravchuk/Downloads/StoneGate/backend
```

### 2. Запустите Docker Compose
```bash
docker-compose up --build
```

### 3. API готов к использованию!
```bash
# Проверьте работу
curl http://localhost:8000/

# Ответ:
# {
#   "message": "StoneGate API",
#   "version": "2.0.0",
#   "framework": "Flask",
#   "database": "PostgreSQL"
# }
```

## 🧪 Тестирование API

Запустите автоматический тест:
```bash
./test_api.sh
```

Или используйте curl вручную:

### Регистрация
```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }'
```

### Авторизация
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

Скопируйте `access_token` из ответа и используйте его в следующих запросах.

### Получение профиля
```bash
curl http://localhost:8000/user/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Получение портфеля
```bash
curl http://localhost:8000/portfolio \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 📊 Доступ к базе данных

### Подключение к PostgreSQL
```bash
docker-compose exec postgres psql -U stonegate -d stonegate_db
```

### Полезные SQL команды
```sql
-- Список всех таблиц
\dt

-- Список пользователей
SELECT id, email, name, verified FROM users;

-- Список холдингов
SELECT * FROM holdings;

-- Список карт
SELECT * FROM cards;

-- Выход
\q
```

## 🛑 Остановка

```bash
# Остановить все сервисы
docker-compose down

# Остановить и удалить все данные
docker-compose down -v
```

## 📝 Логи

```bash
# Все логи
docker-compose logs

# Логи backend
docker-compose logs backend

# Логи PostgreSQL
docker-compose logs postgres

# Следить за логами в реальном времени
docker-compose logs -f backend
```

## 🔧 Отладка

### Зайти в контейнер
```bash
docker-compose exec backend bash
```

### Запустить миграции вручную
```bash
docker-compose exec backend flask db upgrade
```

### Проверить статус контейнеров
```bash
docker-compose ps
```

## 🌍 Переменные окружения

Создайте файл `.env` для кастомизации:

```bash
# Database
POSTGRES_USER=stonegate
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=stonegate_db

# Security
SECRET_KEY=your-super-secret-key-here

# Flask
FLASK_ENV=development
FLASK_DEBUG=1

# Ports
POSTGRES_PORT=5432
BACKEND_PORT=8000
```

## 📱 Подключение iOS приложения

В iOS приложении используйте:
- **URL:** `http://localhost:8000` (для симулятора)
- **URL:** `http://your-machine-ip:8000` (для реального устройства)

## ✅ Что дальше?

1. Прочитайте полную документацию в [README.md](README.md)
2. Изучите структуру API endpoints
3. Протестируйте все функции
4. Интегрируйте с iOS приложением

---

**Нужна помощь?** Проверьте [README.md](README.md) для подробной документации.
