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
    ),
    model.OrderModel(
      id: '2',
      name: 'Стиральная машина Samsung',
      dimensions: '60x60x85 см',
      clientName: 'Карина',
      clientPhone: '+37477345678',
      address: 'г. Ереван, ул. Тиграняна, 5',
      status: model.OrderStatus.inProgress,
    ),
    model.OrderModel(
      id: '3',
      name: 'Холодильник Bosch',
      dimensions: '70x70x200 см',
      clientName: 'Вардан',
      clientPhone: '+37477223344',
      address: 'г. Ереван, пр. Маштоца, 22',
      status: model.OrderStatus.completed,
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
    );
    setState(() {
      orders.add(newOrder);
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
        body: TabBarView(
          children: [
            buildOrderList(model.OrderStatus.active),
            buildOrderList(model.OrderStatus.inProgress),
            buildOrderList(model.OrderStatus.completed),
          ],
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
    final filtered = orders.where((order) => order.status == status).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('Нет заказов'));
    }
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder:
          (context, index) => OrderCard(
            order: filtered[index],
            onStatusChanged: (newStatus) {
              setState(() {
                filtered[index].status = newStatus;
              });
            },
          ),
    );
  }
}
