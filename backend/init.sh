#!/bin/bash

# Скрипт инициализации StoneGate Backend
# Запускает проект в первый раз

echo "🚀 Инициализация StoneGate Backend v2.0"
echo "========================================"
echo ""

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен!"
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен!"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker установлен"
echo "✅ Docker Compose установлен"
echo ""

# Остановка существующих контейнеров (если есть)
echo "🛑 Остановка существующих контейнеров..."
docker-compose down -v 2>/dev/null
echo ""

# Сборка и запуск
echo "🏗️  Сборка Docker контейнеров..."
docker-compose build

echo ""
echo "🚀 Запуск сервисов..."
docker-compose up -d

echo ""
echo "⏳ Ожидание готовности базы данных..."
sleep 5

# Проверка статуса
echo ""
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🔍 Проверка API..."
sleep 2

# Проверка API
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ API работает!"
    echo ""
    curl -s http://localhost:8000/ | python3 -m json.tool
else
    echo "⚠️  API еще не готов, подождите несколько секунд..."
    echo "Проверьте логи: docker-compose logs -f"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ StoneGate Backend успешно запущен!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 API доступен:      http://localhost:8000"
echo "🗄️  PostgreSQL:       localhost:5432"
echo "👤 DB User:           stonegate"
echo "🔑 DB Password:       stonegate_password"
echo "💾 DB Name:           stonegate_db"
echo ""
echo "📚 Полезные команды:"
echo "  make logs         - Просмотр логов"
echo "  make test         - Тестирование API"
echo "  make shell        - Войти в контейнер"
echo "  make db-shell     - PostgreSQL shell"
echo "  make down         - Остановить"
echo "  make help         - Все команды"
echo ""
echo "📖 Документация:"
echo "  README.md         - Полная документация"
echo "  QUICKSTART.md     - Быстрый старт"
echo "  MIGRATION_GUIDE.md - Руководство по миграции"
echo ""
echo "🧪 Запустите тесты:"
echo "  ./test_api.sh"
echo ""
echo "Приятной разработки! 🎉"
