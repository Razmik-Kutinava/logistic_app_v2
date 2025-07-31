import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final void Function(OrderStatus)? onStatusChanged;
  const OrderCard({required this.order, this.onStatusChanged, super.key});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String? deliveryTime;
  String? pin;
  bool pinConfirmed = false;
  final String testPin = '1234'; // Тестовый PIN-код

  // Метод для выбора времени доставки
  Future<void> _selectDeliveryTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        deliveryTime = pickedTime.format(context);
      });
    }
  }

  // Функция для обновления статуса заказа на завершенный
  void _completeDelivery(String enteredPin) {
    if (enteredPin == testPin) {
      setState(() {
        widget.order.status = OrderStatus.completed;
      });
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(OrderStatus.completed);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Доставка завершена успешно')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Неверный PIN!')));
    }
  }

  // Диалоговое окно для ввода PIN
  Future<void> _showPinDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Введите тестовый PIN для завершения'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'PIN-код'),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, letterSpacing: 4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx, controller.text.trim());
                },
                child: const Text(
                  'Подтвердить',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      _completeDelivery(result); // Проверка PIN и завершение доставки
    }
  }

  void _callPhone() async {
    final uri = Uri(scheme: 'tel', path: widget.order.clientPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.order.status == OrderStatus.completed;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Адрес доставки
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget
                        .order
                        .address, // Используем address из объекта OrderModel
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue, size: 28),
                  tooltip: 'Показать на карте',
                  onPressed: () {
                    // Открыть адрес в Google Maps
                    final query = Uri.encodeComponent(widget.order.address);
                    final url =
                        'https://www.google.com/maps/search/?api=1&query=$query';
                    launchUrl(Uri.parse(url));
                  },
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.2),
            // Кнопка "Взять в работу"
            if (widget.order.status == OrderStatus.active) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Взять в работу'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.order.status = OrderStatus.inProgress;
                    });
                    if (widget.onStatusChanged != null) {
                      widget.onStatusChanged!(OrderStatus.inProgress);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Кнопка "Завершить доставку" для заказов в работе
            if (widget.order.status == OrderStatus.inProgress) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Завершить доставку'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _showPinDialog, // Вызов диалога для ввода PIN
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.inventory_2, size: 32, color: Colors.blueGrey[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.order.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text('Габариты: ', style: TextStyle(fontSize: 18)),
                Text(
                  widget.order.dimensions,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text('Клиент: ', style: TextStyle(fontSize: 18)),
                Text(
                  widget.order.clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[700]),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _callPhone,
                  child: Text(
                    widget.order.clientPhone,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Позвонить',
                  child: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green, size: 28),
                    onPressed: _callPhone,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.2),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text('Когда привезти:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  deliveryTime ?? 'Не выбрано',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange,
                  ),
                ),
                if (!isCompleted) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectDeliveryTime, // метод выбора времени
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Выбрать'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.lock, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text('PIN клиента:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                if (isCompleted && pin != null)
                  Text(
                    pin!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!isCompleted) ...[
                  SizedBox(
                    width: 100,
                    child: Text(
                      pinConfirmed && pin != null ? pin! : '—',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _showPinDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Ввести PIN'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
