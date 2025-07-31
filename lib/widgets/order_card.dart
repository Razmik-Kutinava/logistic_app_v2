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
  DeliveryType? selectedDeliveryType;
  DateTime? selectedDateTime;
  String? pin;
  final String testPin = '1234'; // Тестовый PIN-код

  @override
  void initState() {
    super.initState();
    selectedDeliveryType = widget.order.deliveryType;
    selectedDateTime = widget.order.deliveryDateTime;
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
                    widget.order.address,
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
            // Название товара
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
            // Габариты
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
            // Имя клиента
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
            // Телефон клиента
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
            // Когда привезти
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text('Когда привезти:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                DropdownButton<DeliveryType>(
                  value: selectedDeliveryType,
                  items: [
                    DropdownMenuItem(
                      value: DeliveryType.urgent,
                      child: Text('Срочно'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.in1hour,
                      child: Text('Через 1 час'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.in2hours,
                      child: Text('Через 2 часа'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.in3hours,
                      child: Text('Через 3 часа'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.tomorrowMorning,
                      child: Text('Завтра утром'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.tomorrowDay,
                      child: Text('Завтра днём'),
                    ),
                    DropdownMenuItem(
                      value: DeliveryType.exactDateTime,
                      child: Text('Точная дата/время'),
                    ),
                  ],
                  onChanged:
                      isCompleted
                          ? null
                          : (val) async {
                            setState(() {
                              selectedDeliveryType = val;
                              widget.order.deliveryType = val!;
                            });
                            if (val == DeliveryType.exactDateTime) {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  Duration(days: 365),
                                ),
                              );
                              if (!mounted) return;
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (!mounted) return;
                                if (time != null) {
                                  final dt = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  setState(() {
                                    selectedDateTime = dt;
                                    widget.order.deliveryDateTime = dt;
                                  });
                                }
                              }
                            }
                            // После смены типа доставки инициируем обновление списка (через onStatusChanged)
                            if (widget.onStatusChanged != null) {
                              widget.onStatusChanged!(widget.order.status);
                            }
                          },
                ),
                if (selectedDeliveryType == DeliveryType.exactDateTime &&
                    selectedDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${selectedDateTime!.day.toString().padLeft(2, '0')}.${selectedDateTime!.month.toString().padLeft(2, '0')}.${selectedDateTime!.year} '
                      '${selectedDateTime!.hour.toString().padLeft(2, '0')}:${selectedDateTime!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // PIN для завершения заказа (только одно поле в самом низу)
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
                if (!isCompleted &&
                    widget.order.status == OrderStatus.inProgress) ...[
                  SizedBox(
                    width: 120,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          pin = value;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isCompleted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Завершить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed:
                        isCompleted
                            ? null
                            : () {
                              if (pin == testPin) {
                                setState(() {
                                  widget.order.status = OrderStatus.completed;
                                });
                                if (widget.onStatusChanged != null) {
                                  widget.onStatusChanged!(
                                    OrderStatus.completed,
                                  );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Доставка завершена успешно'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Неверный PIN!'),
                                  ),
                                );
                              }
                            },
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
