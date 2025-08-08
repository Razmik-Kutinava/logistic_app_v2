# Модели данных

## OrderModel

Основная модель заказа в приложении.

### Поля

```dart
class OrderModel {
  final String id;                    // Уникальный идентификатор заказа
  final String name;                  // Название товара
  final String dimensions;            // Габариты товара
  final double weight;                // Вес товара
  final String clientName;            // Имя клиента
  final String clientPhone;           // Телефон клиента
  final String address;               // Адрес доставки
  OrderStatus status;                 // Текущий статус заказа
  DeliveryType deliveryType;          // Тип доставки
  DateTime? deliveryDateTime;         // Дата и время доставки
  String? cancelReason;               // Причина отмены
  String? trackingNumber;             // Трек-номер для отслеживания
  DateTime? refundRequestDate;        // Дата запроса на возврат
  String? refundReason;               // Причина возврата
}
```

### Статусы заказа (OrderStatus)

- `active` - Активный заказ, ожидает взятия в работу
- `inProgress` - Заказ в работе, доставляется
- `completed` - Заказ завершен успешно
- `cancelled` - Заказ отменен клиентом
- `refundRequired` - Требуется возврат товара

### Типы доставки (DeliveryType)

- `urgent` - Срочно
- `in1hour` - Через 1 час
- `in2hours` - Через 2 часа  
- `in3hours` - Через 3 часа
- `tomorrowMorning` - Завтра утром
- `tomorrowDay` - Завтра днём
- `exactDateTime` - Точная дата/время

### Методы

- `copyWith()` - создает копию модели с измененными полями

### Система возвратов

Для работы с возвратами используются поля:

- `refundRequestDate` - дата, когда клиент запросил возврат
- `refundReason` - причина возврата, указанная клиентом
- `status = refundRequired` - статус заказа становится "требует возврата"

После завершения возврата (подтверждения PIN) статус меняется на `completed`.

## Другие модели

### User (водитель)

- Данные водителя: имя, телефон, номер авто, опыт работы
- Паспортные данные: серия и номер паспорта

### StatusHistory

- История изменений статусов заказа
- Временные метки всех изменений
