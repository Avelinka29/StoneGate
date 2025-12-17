#!/usr/bin/env python3
"""
Скрипт для создания Alembic миграций
"""

import subprocess
import sys
import os

def run_command(command, cwd=None):
    """Выполняет команду и возвращает результат"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=True
        )
        return True, result.stdout
    except subprocess.CalledProcessError as e:
        return False, e.stderr

def create_alembic_config():
    """Создает alembic.ini если его нет"""

    alembic_config = """# A generic, single database configuration.

[alembic]
# path to migration scripts
script_location = alembic

# template used to generate migration files
# file_template = %%(rev)s_%%(slug)s

# timezone to use when rendering the date
# within the migration file as well as the filename.
# string value is passed to dateutil.tz.gettz()
# leave blank for localtime
timezone = UTC

# max length of characters to apply to the
# "slug" field
# truncate_slug_length = 40

# set to 'true' to run the environment file as a
# script, rather than importing it.
# script_run_as_module = false

# revision environment configuration
# [post_write_hooks]
# hooks = black
# black.type = exec
# black.entrypoint = black
# black.options = -l 79

[post_write_hooks]
# post-write hook: black
hooks = black
black.type = exec
black.entrypoint = black
black.options = -l 79

# Logging configuration
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
"""

    config_path = "alembic.ini"
    if not os.path.exists(config_path):
        with open(config_path, 'w') as f:
            f.write(alembic_config)
        print("✓ Создан alembic.ini")
    else:
        print("✓ alembic.ini уже существует")

def create_env_py():
    """Создает env.py для alembic"""

    env_py_content = '''import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool

from alembic import context

# Добавляем корневую папку в путь для импорта
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

# Импортируем модели и настройки
from database import Base
from models import User, Holding

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
target_metadata = Base.metadata

def run_migrations_offline():
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online():
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = os.getenv("DATABASE_URL", "sqlite:///./stonegate.db")

    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
'''

    env_path = "alembic/env.py"
    os.makedirs("alembic", exist_ok=True)

    if not os.path.exists(env_path):
        with open(env_path, 'w') as f:
            f.write(env_py_content)
        print("✓ Создан alembic/env.py")
    else:
        print("✓ alembic/env.py уже существует")

def init_alembic():
    """Инициализирует Alembic"""

    print("🚀 Инициализация Alembic...\n")

    # Создаем конфигурацию
    create_alembic_config()
    create_env_py()

    # Инициализируем Alembic
    success, output = run_command("alembic init alembic")
    if success:
        print("✓ Alembic инициализирован")
    else:
        print(f"⚠️  Alembic уже инициализирован или ошибка: {output}")

def create_migration():
    """Создает новую миграцию"""

    print("\n📝 Создание миграции...")

    success, output = run_command('alembic revision --autogenerate -m "Initial migration"')
    if success:
        print("✓ Миграция создана")
        print(output)
    else:
        print(f"❌ Ошибка создания миграции: {output}")

def upgrade_database():
    """Применяет миграции к базе данных"""

    print("\n⬆️  Применение миграций...")

    success, output = run_command("alembic upgrade head")
    if success:
        print("✓ Миграции применены")
        print(output)
    else:
        print(f"❌ Ошибка применения миграций: {output}")

if __name__ == "__main__":
    print("🗄️  Настройка Alembic для StoneGate...\n")

    # Инициализируем Alembic
    init_alembic()

    # Создаем начальную миграцию
    create_migration()

    print("\n✅ Настройка Alembic завершена!")
    print("\n💡 Для применения миграций используйте:")
    print("   alembic upgrade head")
    print("\n💡 Для создания новой миграции:")
    print("   alembic revision --autogenerate -m 'Описание изменений'")
