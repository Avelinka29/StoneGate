# API для управления банковскими картами

## Описание

Реализован полнофункциональный API для управления банковскими картами пользователей в приложении StoneGate.

## Возможности

- ✅ Добавление банковских карт
- ✅ Получение списка карт пользователя
- ✅ Удаление карт
- ✅ Автоматическая маскировка номеров карт (показываются только последние 4 цифры)
- ✅ Управление основной картой (первая добавленная карта автоматически становится основной)
- ✅ Поддержка типов карт: "Домашняя" и "Рабочая"

## Модель данных

### Card (База данных)
```python
{
    "id": int,
    "user_id": int,
    "card_number": str,           # Полный номер (хранится в БД)
    "expiry_date": str,           # Формат: MM/ГГ
    "cardholder_name": str,       # Имя владельца
    "cardholder_surname": str,    # Фамилия владельца
    "card_type": str,             # "Домашняя" или "Рабочая"
    "is_primary": bool            # Основная карта
}
```

### CardResponse (API ответ)
```json
{
    "id": 1,
    "card_number_masked": "**** **** **** 1234",
    "expiry_date": "12/26",
    "cardholder_name": "Иван",
    "cardholder_surname": "Иванов",
    "card_type": "Домашняя",
    "is_primary": true
}
```

## API Endpoints

### 1. Получить все карты пользователя

**GET** `/cards`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Ответ:**
```json
[
    {
        "id": 1,
        "card_number_masked": "**** **** **** 1111",
        "expiry_date": "12/26",
        "cardholder_name": "Иван",
        "cardholder_surname": "Иванов",
        "card_type": "Домашняя",
        "is_primary": true
    }
]
```

### 2. Добавить новую карту

**POST** `/cards`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
    "card_number": "4111111111111111",
    "expiry_date": "12/26",
    "cardholder_name": "Иван",
    "cardholder_surname": "Иванов",
    "card_type": "Домашняя",
    "is_primary": false
}
```

**Ответ:** 201 Created
```json
{
    "id": 1,
    "card_number_masked": "**** **** **** 1111",
    "expiry_date": "12/26",
    "cardholder_name": "Иван",
    "cardholder_surname": "Иванов",
    "card_type": "Домашняя",
    "is_primary": true
}
```

**Примечания:**
- Полный номер карты сохраняется в базе данных, но в ответе возвращается замаскированный
- Если это первая карта пользователя, она автоматически становится основной
- Если `is_primary: true`, то все остальные карты теряют статус основной

### 3. Удалить карту

**DELETE** `/cards/{card_id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Ответ:** 204 No Content

**Примечания:**
- Если удаляется основная карта, первая из оставшихся автоматически становится основной
- Возвращает 404, если карта не найдена или не принадлежит пользователю

### 4. Установить карту как основную (дополнительный endpoint)

**PATCH** `/cards/{card_id}/set-primary`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Ответ:** 200 OK
```json
{
    "id": 2,
    "card_number_masked": "**** **** **** 4444",
    "expiry_date": "06/27",
    "cardholder_name": "Петр",
    "cardholder_surname": "Петров",
    "card_type": "Рабочая",
    "is_primary": true
}
```

## Безопасность

- 🔒 Все endpoints требуют авторизации (JWT токен)
- 🔒 Полные номера карт хранятся в базе данных, но никогда не возвращаются в API ответах
- 🔒 Пользователи могут работать только со своими картами

## Использование в iOS приложении

### Загрузка карт
```swift
let cards: [CardData] = try await NetworkManager.shared.request(
    endpoint: "/cards", 
    method: "GET"
)
```

### Добавление карты
```swift
struct CardCreateRequest: Encodable {
    let card_number: String
    let expiry_date: String
    let cardholder_name: String
    let cardholder_surname: String
    let card_type: String
    let is_primary: Bool
}

let newCard: CardData = try await NetworkManager.shared.request(
    endpoint: "/cards", 
    method: "POST", 
    body: cardRequest
)
```

### Удаление карты
```swift
try await NetworkManager.shared.requestNoResponse(
    endpoint: "/cards/\(cardId)", 
    method: "DELETE"
)
```

## Примеры curl команд

### Получить список карт
```bash
curl -X GET http://localhost:8001/cards \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Добавить карту
```bash
curl -X POST http://localhost:8001/cards \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "card_number": "4111111111111111",
    "expiry_date": "12/26",
    "cardholder_name": "Иван",
    "cardholder_surname": "Иванов",
    "card_type": "Домашняя",
    "is_primary": false
  }'
```

### Удалить карту
```bash
curl -X DELETE http://localhost:8001/cards/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Изменения в базе данных

Создана новая таблица `cards`:
```sql
CREATE TABLE cards (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    card_number VARCHAR NOT NULL,
    expiry_date VARCHAR NOT NULL,
    cardholder_name VARCHAR NOT NULL,
    cardholder_surname VARCHAR NOT NULL,
    card_type VARCHAR NOT NULL,
    is_primary BOOLEAN NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Файлы проекта

### Backend:
- `backend/models.py` - Добавлены модели `Card`, `CardCreate`, `CardResponse`
- `backend/routers/cards.py` - Новый роутер с endpoints для карт
- `backend/app.py` - Подключен роутер cards
- `backend/alembic/env.py` - Обновлен импорт модели Card

### iOS:
- `StoneGate/CardsListView.swift` - Добавлена функция удаления карт с подтверждением
- `StoneGate/AddCardView.swift` - Отправка данных на сервер (уже было реализовано)
- `StoneGate/NetworkManager.swift` - Добавлен метод `requestNoResponse` для DELETE запросов
- `StoneGate/Models.swift` - Модель `CardData` для работы с картами (уже была)

## Тестирование

Все endpoints протестированы и работают корректно:
- ✅ GET /cards - возвращает список карт пользователя
- ✅ POST /cards - создает новую карту с маскировкой номера
- ✅ DELETE /cards/{id} - удаляет карту (204 No Content)
- ✅ Автоматическое управление основной картой
- ✅ Маскировка номеров карт (**** **** **** XXXX)

## Что дальше?

Возможные улучшения:
1. Шифрование полных номеров карт в базе данных
2. Валидация номеров карт (алгоритм Луна)
3. Ограничение количества карт на пользователя
4. История транзакций по картам
5. Интеграция с платежными системами
