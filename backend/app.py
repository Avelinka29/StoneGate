from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
from pathlib import Path
import os

from config import config
from database import init_db, db


def create_app(config_obj=None):
    """
    Фабрика приложений Flask.
    
    Args:
        config_obj: Объект конфигурации (по умолчанию берется из config.py)
    
    Returns:
        Flask приложение
    """
    app = Flask(__name__)
    
    # Загружаем конфигурацию
    if config_obj is None:
        config_obj = config
    
    app.config.from_object(config_obj)
    
    # Инициализируем CORS
    CORS(app, 
         resources={r"/*": {"origins": config_obj.CORS_ORIGINS}},
         supports_credentials=True,
         allow_headers=["Content-Type", "Authorization"],
         methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"])
    
    # Инициализируем базу данных
    init_db(app)

    # Создаем таблицы в базе данных
    with app.app_context():
        # Импортируем модели чтобы они были зарегистрированы
        from models import User, Holding, Card
        db.create_all()
        print("✅ Database tables created!")

    # Создаем папки для загрузок если их нет
    upload_dir = Path(app.config['UPLOAD_FOLDER'])
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Регистрируем blueprints
    register_blueprints(app)
    
    # Регистрируем обработчики ошибок
    register_error_handlers(app)
    
    # Главный маршрут
    @app.route('/')
    def index():
        return jsonify({
            'message': 'StoneGate API',
            'version': '2.0.0',
            'framework': 'Flask',
            'database': 'PostgreSQL'
        })
    
    # Маршрут для раздачи загруженных файлов
    @app.route('/uploads/<path:filename>')
    def uploaded_file(filename):
        return send_from_directory('uploads', filename)
    
    # Health check endpoint
    @app.route('/health')
    def health():
        try:
            # Проверяем подключение к базе данных
            db.session.execute(db.text('SELECT 1'))
            db_status = 'healthy'
        except Exception as e:
            db_status = f'unhealthy: {str(e)}'
        
        return jsonify({
            'status': 'ok',
            'database': db_status
        })
    
    return app


def register_blueprints(app):
    """Регистрация всех blueprints"""
    from blueprints.auth import auth_bp
    from blueprints.user import user_bp
    from blueprints.portfolio import portfolio_bp
    from blueprints.cards import cards_bp
    
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(user_bp, url_prefix='/user')
    app.register_blueprint(portfolio_bp, url_prefix='/portfolio')
    app.register_blueprint(cards_bp, url_prefix='/cards')


def register_error_handlers(app):
    """Регистрация обработчиков ошибок"""
    
    @app.errorhandler(400)
    def bad_request(error):
        return jsonify({'error': 'Bad Request', 'message': str(error)}), 400
    
    @app.errorhandler(401)
    def unauthorized(error):
        return jsonify({'error': 'Unauthorized', 'message': 'Authentication required'}), 401
    
    @app.errorhandler(403)
    def forbidden(error):
        return jsonify({'error': 'Forbidden', 'message': 'You do not have permission to access this resource'}), 403
    
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Not Found', 'message': 'Resource not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return jsonify({'error': 'Internal Server Error', 'message': 'An unexpected error occurred'}), 500
    
    @app.errorhandler(Exception)
    def handle_exception(error):
        app.logger.error(f"Unhandled exception: {str(error)}")
        db.session.rollback()
        return jsonify({'error': 'Internal Server Error', 'message': str(error)}), 500


if __name__ == '__main__':
    # Создаем приложение
    app = create_app()
    
    # Запускаем сервер
    port = int(os.getenv('PORT', 8000))
    host = os.getenv('HOST', '0.0.0.0')
    
    print(f"🚀 StoneGate API starting on {host}:{port}")
    print(f"📊 Database: {config.DATABASE_URL}")
    print(f"🔧 Debug mode: {config.DEBUG}")
    
    app.run(host=host, port=port, debug=config.DEBUG)
