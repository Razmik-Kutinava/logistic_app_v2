# Структура проекта

```bash
lib/
├── models/                      # Модели данных (заказы, товары, пользователи)
│   ├── order.dart               # Модель заказа
│   ├── product.dart             # Модель товара
│   ├── user.dart                # Модель пользователя
│   └── status.dart              # Модель статуса заказа
│
├── services/                    # Сервисы для работы с внешними API и бэкендом
│   ├── api_service.dart         # Взаимодействие с API на PHP
│   ├── auth_service.dart        # Сервис авторизации водителя
│   └── push_notification_service.dart  # Для работы с пуш-уведомлениями
│
├── ui/                          # Визуальная часть приложения
│   ├── screens/                 # Экраны (активные, в работе, завершённые)
│   │   ├── active_orders_screen.dart
│   │   ├── in_progress_screen.dart
│   │   └── completed_orders_screen.dart
│   ├── widgets/                 # Виджеты (карточки товаров, кнопки)
│   │   ├── product_card.dart    # Карточка товара
│   │   ├── status_dropdown.dart # Дропдаун для выбора статуса
│   │   └── phone_number_input.dart  # Поле для ввода номера телефона
│   └── shared/                  # Общие компоненты
│       ├── app_bar.dart
│       └── bottom_navigation.dart
│
├── blocs/                       # Логика управления состоянием
│   ├── order_bloc.dart          # Заказы
│   ├── user_bloc.dart           # Пользователи (водители)
│   └── status_bloc.dart         # Статусы заказов
│
├── utils/                       # Утилиты и вспомогательные классы
│   ├── validators.dart          # Валидация данных
│   ├── constants.dart           # Константы приложения
│   └── time_formatter.dart      # Форматирование времени
│
└── main.dart                    # Точка входа
```
