.PHONY: help build up down restart logs shell db-shell test clean migrate upgrade downgrade

help: ## Показать это сообщение помощи
	@echo "StoneGate Backend - Команды Makefile"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Собрать Docker контейнеры
	docker-compose build

up: ## Запустить все сервисы
	docker-compose up

up-d: ## Запустить все сервисы в фоновом режиме
	docker-compose up -d

down: ## Остановить все сервисы
	docker-compose down

down-v: ## Остановить все сервисы и удалить volumes
	docker-compose down -v

restart: ## Перезапустить все сервисы
	docker-compose restart

logs: ## Показать логи всех сервисов
	docker-compose logs -f

logs-backend: ## Показать логи backend
	docker-compose logs -f backend

logs-db: ## Показать логи PostgreSQL
	docker-compose logs -f postgres

shell: ## Зайти в контейнер backend
	docker-compose exec backend bash

db-shell: ## Зайти в PostgreSQL shell
	docker-compose exec postgres psql -U stonegate -d stonegate_db

test: ## Запустить тесты API
	./test_api.sh

migrate: ## Создать новую миграцию
	docker-compose exec backend flask db migrate -m "$(msg)"

upgrade: ## Применить миграции
	docker-compose exec backend flask db upgrade

downgrade: ## Откатить миграции
	docker-compose exec backend flask db downgrade

clean: ## Очистить все (контейнеры, volumes, образы)
	docker-compose down -v --rmi all

ps: ## Показать статус контейнеров
	docker-compose ps

prod-up: ## Запустить production сервер
	docker-compose -f docker-compose.prod.yml up -d

prod-down: ## Остановить production сервер
	docker-compose -f docker-compose.prod.yml down

prod-logs: ## Показать логи production сервера
	docker-compose -f docker-compose.prod.yml logs -f

install: ## Установить зависимости локально (для разработки без Docker)
	pip install -r requirements.txt

run-local: ## Запустить локально без Docker
	python app.py

init: ## Инициализировать проект (первый запуск)
	docker-compose up --build -d
	@echo "✅ StoneGate Backend запущен!"
	@echo "📊 API доступен: http://localhost:8000"
	@echo "🗄️  PostgreSQL доступен: localhost:5432"
	@echo ""
	@echo "Используйте 'make test' для проверки API"
	@echo "Используйте 'make logs' для просмотра логов"
	@echo "Используйте 'make help' для списка всех команд"
