#!/bin/bash

# Скрипт для тестирования StoneGate API

API_URL="http://localhost:8000"
EMAIL="test@stonegate.com"
PASSWORD="test123456"
NAME="Test User"

echo "🧪 Тестирование StoneGate API"
echo "================================"
echo ""

# 1. Проверка здоровья API
echo "1️⃣  Проверка health check..."
curl -s "$API_URL/health" | python3 -m json.tool
echo ""
echo ""

# 2. Регистрация пользователя
echo "2️⃣  Регистрация пользователя..."
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"name\":\"$NAME\"}")

echo "$REGISTER_RESPONSE" | python3 -m json.tool

# Извлекаем токен
TOKEN=$(echo "$REGISTER_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "⚠️  Пользователь уже существует, пробуем войти..."
  
  # Пробуем войти
  LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
  
  echo "$LOGIN_RESPONSE" | python3 -m json.tool
  TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")
fi

echo ""
echo "🔑 Токен: $TOKEN"
echo ""
echo ""

# 3. Получение профиля
echo "3️⃣  Получение профиля..."
curl -s "$API_URL/user/profile" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""
echo ""

# 4. Получение портфеля
echo "4️⃣  Получение портфеля..."
curl -s "$API_URL/portfolio" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""
echo ""

# 5. Получение карт
echo "5️⃣  Получение списка карт..."
curl -s "$API_URL/cards" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
echo ""
echo ""

# 6. Добавление карты
echo "6️⃣  Добавление новой карты..."
curl -s -X POST "$API_URL/cards" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "card_number": "4532015112830366",
    "expiry_date": "12/25",
    "cardholder_name": "Test",
    "cardholder_surname": "User",
    "card_type": "Домашняя",
    "is_primary": true
  }' | python3 -m json.tool
echo ""
echo ""

# 7. Обновление профиля
echo "7️⃣  Обновление профиля..."
curl -s -X PATCH "$API_URL/user/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Updated Test User",
    "phone": "+375291234567",
    "notifications_enabled": true
  }' | python3 -m json.tool
echo ""
echo ""

echo "✅ Тестирование завершено!"
