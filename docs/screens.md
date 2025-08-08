# Экраны приложения

## Обзор экранов

Приложение состоит из следующих экранов:

- **SplashScreen** - экран загрузки при запуске
- **AuthPhoneScreen** - авторизация водителя по телефону и PIN
- **HomeScreen** - главный экран с заказами и TabBar
- **DriverProfileScreen** - профиль водителя со статистикой

## SplashScreen

Экран загрузки, отображается при запуске приложения.

### Функционал

- Показывает логотип/название приложения
- Автоматически перенаправляет на экран авторизации
- Может загружать начальные данные

## AuthPhoneScreen  

Экран авторизации водителя.

### Поля ввода

- **Номер телефона** - валидация международного формата
- **PIN-код компании** - 4-6 цифр, выдается логистом

### Тестовые данные

- Телефон: `1234567890`
- PIN: `123456`

### Логика

1. Водитель вводит телефон и PIN
2. Данные валидируются локально
3. При успешной валидации показывается попап "Вы прошли авторизацию!"
4. Переход на главный экран

## HomeScreen

Главный экран приложения с системой заказов.

### TabBar структура

- **Активные** - заказы со статусом `active`
- **В работе** - заказы со статусом `inProgress`
- **Завершенные** - заказы со статусом `completed`
- **Возвраты** - заказы со статусом `refundRequired`

### Верхняя панель

- **Счетчик зарплаты** - показывает накопленную сумму и бонусы
- **Кнопка профиля** - переход в профиль водителя

### Логика счетчика зарплаты

```dart
int salary = 250000; // Базовая зарплата
int bonus = 0;
if (completedCount > 1800) {
  bonus = (completedCount - 1800) * 150; // Бонус за каждый заказ сверх 1800
  salary += bonus;
}
```

### Управление заказами

- `handleStatusChanged()` - изменение статуса заказа
- `handleDeliveryTimeChanged()` - изменение времени доставки
- `handleClientRefund()` - обработка запроса на возврат
- `handleQRScan()` - добавление нового заказа по QR-коду

## DriverProfileScreen

Экран профиля водителя с детальной статистикой.

### Отображаемые данные

**Личная информация:**

- Имя водителя
- Номер телефона
- Номер автомобиля
- Опыт работы (лет)
- Серия и номер паспорта

**Статистика заказов:**

- Выполнено заказов
- Отменено заказов (+ список)
- Возвратов (+ список)

### Структура

```dart
DriverProfileScreen({
  required String phone,
  required String name, 
  required String carNumber,
  required int experience,
  required int completedOrders,
  required int cancelledOrdersCount,
  required List<OrderModel> cancelledOrders,
  required int refundOrdersCount,
  required List<OrderModel> refundOrders,
})
```

### Передача данных

Данные передаются из HomeScreen через Navigator arguments:

```dart
Navigator.pushNamed(context, '/profile', arguments: {
  'phone': '1234567890',
  'name': 'Иван Петров',
  // ... другие параметры
});
```

## Навигация между экранами

### Маршруты

```dart
routes: {
  '/splash': (context) => const SplashScreen(),
  '/auth': (context) => const AuthPhoneScreen(), 
  '/main': (context) => HomeScreen(),
  '/profile': (context) => DriverProfileScreen(...),
}
```

### Переходы

- При запуске: Splash → Auth → Main
- Из главного экрана в профиль: Main → Profile
- Возврат в главный экран: Profile → Main
