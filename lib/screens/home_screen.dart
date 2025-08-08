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
        orders[orderIndex] = orders[orderIndex].copyWith(status: newStatus);
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
    final hasRefunds = orders.any(
      (order) => order.status == model.OrderStatus.refundRequired,
    );
    // Фильтрация завершённых заказов только за текущий месяц
    final now = DateTime.now();
    final completedThisMonth =
        orders.where((order) {
          if (order.status != model.OrderStatus.completed) return false;
          if (order.deliveryDateTime == null) return false;
          return order.deliveryDateTime!.year == now.year &&
              order.deliveryDateTime!.month == now.month;
        }).toList();
    final completedCount = completedThisMonth.length;
    int salary = 250000;
    int bonus = 0;
    if (completedCount > 1800) {
      bonus = (completedCount - 1800) * 150;
      salary += bonus;
    }
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
                final completedOrdersCount =
                    orders
                        .where(
                          (order) =>
                              order.status == model.OrderStatus.completed,
                        )
                        .length;
                final cancelledOrders =
                    orders
                        .where(
                          (order) =>
                              order.status == model.OrderStatus.cancelled,
                        )
                        .toList();
                final cancelledOrdersCount = cancelledOrders.length;
                final refundOrders =
                    orders
                        .where(
                          (order) =>
                              order.status == model.OrderStatus.refundRequired,
                        )
                        .toList();
                final refundOrdersCount = refundOrders.length;
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: {
                    'phone': '1234567890',
                    'name': 'Иван Петров',
                    'carNumber': 'A123BC 01',
                    'experience': 5,
                    'completedOrders': completedOrdersCount,
                    'cancelledOrdersCount': cancelledOrdersCount,
                    'cancelledOrders': cancelledOrders,
                    'refundOrdersCount': refundOrdersCount,
                    'refundOrders': refundOrders,
                  },
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_turned_in,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'За месяц: $completedCount',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${salary} драм',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: bonus > 0 ? Colors.green : Colors.black,
                            ),
                          ),
                          if (bonus > 0) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.emoji_events,
                              color: Colors.orange,
                              size: 18,
                            ),
                            Text(
                              '+${bonus} драм',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: [
                    const Tab(text: 'Активные'),
                    const Tab(text: 'В работе'),
                    Tab(
                      child: Text(
                        'Завершённые',
                        style: TextStyle(
                          color: hasRefunds ? Colors.red : null,
                          fontWeight:
                              hasRefunds ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ...компактный счетчик и TabBar уже реализованы выше...
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
                buildCompletedList(),
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
    final filteredOrders =
        orders.where((order) => order.status == status).toList();
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
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final isRefund = order.status == model.OrderStatus.refundRequired;
        return OrderCard(
          order: order,
          blockAll: blockAll && !isRefund,
          blockExceptCall: blockAll && isRefund,
          onCall: () {
            if (isRefund && blockAll) {
              setState(() {
                refundCallDone = true;
              });
            }
          },
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

  Widget buildCompletedList() {
    final completed =
        orders.where((o) => o.status == model.OrderStatus.completed).toList();
    final refunds =
        orders
            .where((o) => o.status == model.OrderStatus.refundRequired)
            .toList();
    final all = [...refunds, ...completed];
    if (all.isEmpty) {
      return const Center(child: Text('Нет заказов'));
    }
    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (context, index) {
        final order = all[index];
        final isRefund = order.status == model.OrderStatus.refundRequired;
        return OrderCard(
          order: order,
          blockAll: blockAll && !isRefund,
          blockExceptCall: blockAll && isRefund,
          onCall: () {
            if (isRefund && blockAll) {
              setState(() {
                refundCallDone = true;
              });
            }
          },
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
