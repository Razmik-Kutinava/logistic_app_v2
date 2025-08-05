import 'package:flutter/material.dart';
import '../models/order_model.dart' as model;
import '../widgets/order_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<model.OrderModel> orders = [
    model.OrderModel(
      id: '1',
      name: 'Телевизор LG 55"',
      dimensions: '140x80x20 см',
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
      clientName: 'Вардан',
      clientPhone: '+37477223344',
      address: 'г. Ереван, пр. Маштоца, 22',
      status: model.OrderStatus.completed,
      deliveryType: model.DeliveryType.tomorrowDay,
      deliveryDateTime: null,
    ),
  ];

  void handleQRScan(String qrData) {
    final newOrder = model.OrderModel(
      id: qrData,
      name: 'Ноутбук ASUS',
      dimensions: '30x20x5 см',
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
        orders[orderIndex] = orders[orderIndex].copyWith(status: newStatus);
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
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle, size: 32),
              tooltip: 'Личный кабинет',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {
                    'phone': '1234567890',
                    'name': 'Иван Петров',
                    'carNumber': 'A123BC 01',
                    'experience': 5,
                  },
                );
              },
            ),
          ],
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
            // Сортировка заказов по deliveryDateTime
            orders.sort(
              (a, b) => (a.deliveryDateTime ?? DateTime(2100)).compareTo(
                b.deliveryDateTime ?? DateTime(2100),
              ),
            );
            return TabBarView(
              children: [
                buildOrderList(model.OrderStatus.active),
                buildOrderList(model.OrderStatus.inProgress),
                buildOrderList(model.OrderStatus.completed),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            handleQRScan('order_${DateTime.now().millisecondsSinceEpoch}');
          },
          child: const Icon(Icons.qr_code_scanner),
        ),
      ),
    );
  }

  Widget buildOrderList(model.OrderStatus status) {
    // Filter orders by status
    final filteredOrders =
        orders.where((order) => order.status == status).toList();

    // Sort in-progress orders by deliveryDateTime (earliest first)
    if (status == model.OrderStatus.inProgress) {
      filteredOrders.sort((a, b) {
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
      itemBuilder:
          (context, index) => OrderCard(
            order: filteredOrders[index],
            onStatusChanged: (newStatus) {
              handleStatusChanged(filteredOrders[index].id, newStatus);
            },
            onDeliveryTimeChanged: (orderId, newTime) {
              handleDeliveryTimeChanged(orderId, newTime);
            },
          ),
    );
  }
}
