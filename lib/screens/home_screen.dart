import 'package:flutter/material.dart';
import '../models/order_model.dart' as model;
import '../widgets/order_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool refundCallDone = false;
  bool get blockAll {
    final hasRefunds = orders.any(
      (order) => order.status == model.OrderStatus.refundRequired,
    );
    return hasRefunds && !refundCallDone;
  }

  List<model.OrderModel> orders = [
    model.OrderModel(
      id: '1',
      name: 'Телевизор LG 55"',
      dimensions: '140x80x20 см',
      weight: 18.5,
      clientName: 'Артем',
      clientPhone: '+37477123456',
      address: 'г. Ереван, ул. Абовяна, 12',
      status: model.OrderStatus.active,
      deliveryType: model.DeliveryType.urgent,
      deliveryDateTime: DateTime.now().add(Duration(hours: 2)),
    ),
    model.OrderModel(
      id: '2',
      name: 'Стиральная машина Samsung',
      dimensions: '60x60x85 см',
      weight: 60.0,
      clientName: 'Карина',
      clientPhone: '+37477345678',
      address: 'г. Ереван, ул. Тиграняна, 5',
      status: model.OrderStatus.inProgress,
      deliveryType: model.DeliveryType.in1hour,
      deliveryDateTime: DateTime.now().add(Duration(hours: 1)),
    ),
    model.OrderModel(
      id: '3',
      name: 'Холодильник Bosch',
      dimensions: '70x70x200 см',
      weight: 85.0,
      clientName: 'Вардан',
      clientPhone: '+37477223344',
      address: 'г. Ереван, пр. Маштоца, 22',
      status: model.OrderStatus.completed,
      deliveryType: model.DeliveryType.tomorrowDay,
      deliveryDateTime: null,
    ),
    model.OrderModel(
      id: '4',
      name: 'Микроволновка LG',
      dimensions: '50x40x30 см',
      weight: 15.0,
      clientName: 'Анна',
      clientPhone: '+37477556677',
      address: 'г. Ереван, ул. Сарьяна, 8',
      status: model.OrderStatus.refundRequired,
      deliveryType: model.DeliveryType.urgent,
      deliveryDateTime: DateTime.now().subtract(Duration(days: 2)),
      refundRequestDate: DateTime.now().subtract(Duration(hours: 5)),
      refundReason: 'Товар не подошел по размерам',
    ),
  ];

  void handleQRScan(String qrData) {
    final newOrder = model.OrderModel(
      id: qrData,
      name: 'Ноутбук ASUS',
      dimensions: '30x20x5 см',
      weight: 2.2,
      clientName: 'Сергей',
      clientPhone: '+37477223311',
      address: 'г. Ереван, ул. Пушкина, 8',
      status: model.OrderStatus.active,
      deliveryType: model.DeliveryType.in3hours,
      deliveryDateTime: DateTime.now().add(Duration(hours: 3)),
    );
    setState(() {
      orders.add(newOrder);
    });
  }

  void handleDeliveryTimeChanged(String orderId, DateTime? newDeliveryTime) {
    setState(() {
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(
          deliveryDateTime: newDeliveryTime,
        );
      }
    });
  }

  void handleStatusChanged(String orderId, model.OrderStatus newStatus) {
    setState(() {
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final prevStatus = orders[orderIndex].status;
        // Если возврат успешно завершён (PIN введён), считаем как выполненный заказ
        if (prevStatus == model.OrderStatus.refundRequired &&
            newStatus == model.OrderStatus.completed) {
          orders[orderIndex] = orders[orderIndex].copyWith(
            status: model.OrderStatus.completed,
            deliveryDateTime: DateTime.now(),
          );
        } else {
          orders[orderIndex] = orders[orderIndex].copyWith(status: newStatus);
        }
      }
    });
  }

  void handleClientRefund(String orderId, String reason) {
    setState(() {
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        orders[orderIndex] = orders[orderIndex].copyWith(
          status: model.OrderStatus.refundRequired,
          refundRequestDate: DateTime.now(),
          refundReason: reason,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ваши заказы'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Активные'),
              Tab(text: 'В работе'),
              Tab(text: 'Завершённые'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            orders.sort(
              (a, b) => (a.deliveryDateTime ?? DateTime(2100)).compareTo(
                b.deliveryDateTime ?? DateTime(2100),
              ),
            );
            return TabBarView(
              children: [
                buildOrderList(model.OrderStatus.active),
                buildOrderList(model.OrderStatus.inProgress),
                buildCompletedList(),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Здесь должен быть вызов реального сканера QR-кода
            // Для теста: добавляем заказ с рандомным id
            final randomId = DateTime.now().millisecondsSinceEpoch.toString();
            handleQRScan(randomId);
            // Для реального приложения используйте пакет qr_code_scanner или mobile_scanner
          },
          tooltip: 'Сканировать QR',
          child: const Icon(Icons.qr_code_scanner, size: 32),
        ),
      ),
    );
  }

  Widget buildOrderList(model.OrderStatus status) {
    List<model.OrderModel> filteredOrders;

    if (status == model.OrderStatus.inProgress) {
      // Во вкладке "В работе" показываем как inProgress, так и refundRequired
      filteredOrders =
          orders
              .where(
                (order) =>
                    order.status == model.OrderStatus.inProgress ||
                    order.status == model.OrderStatus.refundRequired,
              )
              .toList();
    } else {
      // Для остальных вкладок показываем только соответствующий статус
      filteredOrders = orders.where((order) => order.status == status).toList();
    }

    if (status == model.OrderStatus.inProgress) {
      // Сортируем: сначала возвраты, потом обычные заказы в работе
      filteredOrders.sort((a, b) {
        // Возвраты всегда первые
        if (a.status == model.OrderStatus.refundRequired &&
            b.status != model.OrderStatus.refundRequired)
          return -1;
        if (b.status == model.OrderStatus.refundRequired &&
            a.status != model.OrderStatus.refundRequired)
          return 1;

        // Обычная сортировка по дате доставки
        if (a.deliveryDateTime == null && b.deliveryDateTime == null) return 0;
        if (a.deliveryDateTime == null) return 1;
        if (b.deliveryDateTime == null) return -1;
        return a.deliveryDateTime!.compareTo(b.deliveryDateTime!);
      });
    }
    if (filteredOrders.isEmpty) {
      return const Center(child: Text('Нет заказов'));
    }
    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final isRefund = order.status == model.OrderStatus.refundRequired;
        return OrderCard(
          order: order,
          blockAll: blockAll, // Все карточки получают общий флаг блокировки
          blockExceptCall:
              blockAll &&
              isRefund, // Только возврат получает исключение на звонок
          onCall: () => handleRefundCall(isRefund),
          onStatusChanged: (newStatus) {
            handleStatusChanged(order.id, newStatus);
          },
          onDeliveryTimeChanged: (orderId, newTime) {
            handleDeliveryTimeChanged(orderId, newTime);
          },
          onClientRefund: (reason) {
            handleClientRefund(order.id, reason);
          },
        );
      },
    );
  }

  void handleRefundCall(bool isRefund) {
    if (isRefund && blockAll) {
      setState(() {
        refundCallDone = true;
      });
    }
  }

  Widget buildCompletedList() {
    // Показываем только завершённые заказы (без возвратов)
    final completed =
        orders.where((o) => o.status == model.OrderStatus.completed).toList();
    if (completed.isEmpty) {
      return const Center(child: Text('Нет завершённых заказов'));
    }
    return ListView.builder(
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final order = completed[index];
        return OrderCard(
          order: order,
          blockAll: false, // В завершённых заказах нет блокировок
          blockExceptCall: false, // Нет исключений для звонков
          onCall: () {}, // Пустой обработчик
          onStatusChanged: (newStatus) {
            handleStatusChanged(order.id, newStatus);
          },
          onDeliveryTimeChanged: (orderId, newTime) {
            handleDeliveryTimeChanged(orderId, newTime);
          },
          onClientRefund: (reason) {
            handleClientRefund(order.id, reason);
          },
        );
      },
    );
  }
}
