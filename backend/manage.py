#!/usr/bin/env python
"""
Скрипт для управления приложением и миграциями базы данных.
"""
from flask_migrate import Migrate, init as migrate_init, migrate as migrate_db, upgrade, downgrade
from app import create_app
from database import db
from models import User, Holding, Card

# Создаем приложение
app = create_app()

# Инициализируем Flask-Migrate
migrate = Migrate(app, db)


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python manage.py [command]")
        print("\nCommands:")
        print("  init      - Initialize migrations directory")
        print("  migrate   - Generate a new migration")
        print("  upgrade   - Apply migrations")
        print("  downgrade - Revert migrations")
        print("  run       - Run the development server")
        sys.exit(1)
    
    command = sys.argv[1]
    
    with app.app_context():
        if command == 'init':
            print("Initializing migrations...")
            migrate_init()
        elif command == 'migrate':
            message = sys.argv[2] if len(sys.argv) > 2 else 'Auto migration'
            print(f"Creating migration: {message}")
            migrate_db(message=message)
        elif command == 'upgrade':
            print("Applying migrations...")
            upgrade()
        elif command == 'downgrade':
            print("Reverting migrations...")
            downgrade()
        elif command == 'run':
            print("Starting development server...")
            app.run(debug=True)
        else:
            print(f"Unknown command: {command}")
            sys.exit(1)
