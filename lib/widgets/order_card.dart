import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final void Function(OrderStatus)? onStatusChanged;
  final void Function(String orderId, DateTime? newTime)? onDeliveryTimeChanged;
  final void Function(String reason)? onClientRefund;
  const OrderCard({
    required this.order,
    this.onStatusChanged,
    this.onDeliveryTimeChanged,
    this.onClientRefund,
    super.key,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final TextEditingController _refundPinController = TextEditingController();
  final String _refundTestPin = '1234';
  void _handleRefundPin() {
    final pin = _refundPinController.text.trim();
    if (pin == _refundTestPin) {
      setState(() {
        widget.order.status = OrderStatus.completed;
      });
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(OrderStatus.completed);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Возврат успешно завершён!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Неверный PIN!')));
    }
  }

  @override
  void dispose() {
    _refundPinController.dispose();
    super.dispose();
  }

  int callCount = 0;

  void _callPhone() async {
    final uri = Uri(scheme: 'tel', path: widget.order.clientPhone);
    setState(() {
      callCount++;
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showCancelReasonDialog() {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Причина отказа клиента'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(hintText: 'Введите причину'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.order.status = OrderStatus.cancelled;
                  widget.order.cancelReason = reasonController.text;
                });
                if (widget.onStatusChanged != null) {
                  widget.onStatusChanged!(OrderStatus.cancelled);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _showRefundDialog() {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Клиент отказался от заказа'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Укажите причину отказа клиента:'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Например: не подошел размер, передумал и т.д.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty && widget.onClientRefund != null) {
                  widget.onClientRefund!(reason);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Подтвердить отказ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

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
            const SizedBox(height: 12),
            // Поле для ввода трек-номера
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Трек-номер:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: widget.order.trackingNumber ?? '',
                    ),
                    onChanged: (value) {
                      // Обновляем трек-номер в заказе
                      if (value.isEmpty) {
                        widget.order.trackingNumber = null;
                      } else {
                        widget.order.trackingNumber = value;
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Введите трек-номер для отслеживания',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
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
            Row(
              children: [
                Icon(Icons.scale, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text('Вес: ', style: TextStyle(fontSize: 18)),
                Text(
                  '${widget.order.weight.toStringAsFixed(1)} кг',
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
            // Кнопка "Клиент отказался" для водителя
            if (widget.order.status == OrderStatus.inProgress) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_off, color: Colors.red),
                  label: const Text('Клиент отказался'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _showCancelReasonDialog,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Отображение причины отказа клиента
            if (widget.order.status == OrderStatus.cancelled &&
                (widget.order.cancelReason?.isNotEmpty ?? false)) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Причина отказа клиента: ${widget.order.cancelReason}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            // Телефон клиента + счетчик звонков
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
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.call_made, color: Colors.blue, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Звонков: $callCount',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
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
                              if (!mounted) return;
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
                                if (!mounted) return;
                                final time = await showTimePicker(
                                  // ignore: use_build_context_synchronously
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
                                  if (!mounted) return;
                                  setState(() {
                                    selectedDateTime = dt;
                                    widget.order.deliveryDateTime = dt;
                                  });
                                  if (widget.onDeliveryTimeChanged != null) {
                                    widget.onDeliveryTimeChanged!(
                                      widget.order.id,
                                      dt,
                                    );
                                  }
                                }
                              }
                            }
                            // После смены типа доставки инициируем обновление списка (через onStatusChanged)
                            if (!mounted) return;
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
            // Кнопка отказа клиента для завершенных заказов
            if (widget.order.status == OrderStatus.completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment_return),
                  label: const Text('Клиент отказался'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    _showRefundDialog();
                  },
                ),
              ),
            ],
            // Информация о возврате для заказов со статусом refundRequired
            if (widget.order.status == OrderStatus.refundRequired) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Требуется возврат',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.order.refundRequestDate != null) ...[
                      Text(
                        'Дата запроса: ${_formatDateTime(widget.order.refundRequestDate!)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (widget.order.refundReason != null) ...[
                      Text(
                        'Причина: ${widget.order.refundReason}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Введите PIN для подтверждения возврата:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _refundPinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: '',
                              hintText: 'PIN',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Завершить возврат'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _handleRefundPin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
