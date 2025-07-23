import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  const OrderCard({required this.order, super.key});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  String? deliveryTime;
  String? pin;
  bool pinConfirmed = false;

  @override
  void initState() {
    super.initState();
    deliveryTime = widget.order.deliveryTime;
  }

  void _selectDeliveryTime() async {
    final times = [
      'Как можно скорее',
      'Через час',
      'Через два часа',
      'Завтра утром',
    ];
    final selected = await showDialog<String>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Когда привезти груз?'),
            children:
                times
                    .map(
                      (t) => SimpleDialogOption(
                        child: Text(t, style: const TextStyle(fontSize: 20)),
                        onPressed: () => Navigator.pop(ctx, t),
                      ),
                    )
                    .toList(),
          ),
    );
    if (selected != null) {
      setState(() {
        deliveryTime = selected;
        widget.order.deliveryTime = selected;
      });
    }
  }

  void _showPinDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Введите PIN-код от клиента'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'PIN-код'),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, letterSpacing: 4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text(
                  'Подтвердить',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        pin = result;
        pinConfirmed = true;
      });
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
                    onPressed: _selectDeliveryTime,
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
