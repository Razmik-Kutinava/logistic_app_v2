import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';

/// OrderCard (refactored)
///
/// Основные правки:
/// - Больше никаких TextEditingController внутри build (чтобы не течь памятью и не терять курсор).
/// - Локальное состояние для статуса/доставки, синхронизация с родителем через колбэки.
/// - Единая функция _updateStatus, чтобы не дублировать логику setState + callback.
/// - Отдельные контроллеры для PIN/Refund PIN/Tracking + корректный dispose.
/// - Чуть упростил логику blockAll/blockExceptCall.
/// - Небольшая косметика UI и null‑safety.
class OrderCard extends StatefulWidget {
  final OrderModel order;
  final void Function(OrderStatus)? onStatusChanged;
  final void Function(String orderId, DateTime? newTime)? onDeliveryTimeChanged;
  final void Function(String reason)? onClientRefund;
  final bool blockAll;
  final bool blockExceptCall;
  final VoidCallback? onCall;

  const OrderCard({
    required this.order,
    this.onStatusChanged,
    this.onDeliveryTimeChanged,
    this.onClientRefund,
    this.blockAll = false,
    this.blockExceptCall = false,
    this.onCall,
    super.key,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  // Controllers
  final TextEditingController _refundPinController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  late final TextEditingController _trackingController;

  // Local state mirrors
  late OrderStatus _status;
  late DeliveryType? _selectedDeliveryType;
  DateTime? _selectedDateTime;

  // Counters & constants
  int _callCount = 0;
  static const String _testPin = '1234';
  static const String _refundTestPin = '1234';

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _selectedDeliveryType = widget.order.deliveryType;
    _selectedDateTime = widget.order.deliveryDateTime;
    _trackingController = TextEditingController(
      text: widget.order.trackingNumber ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если пришёл новый заказ — синхронизируем локальное состояние
    if (oldWidget.order.id != widget.order.id) {
      _status = widget.order.status;
      _selectedDeliveryType = widget.order.deliveryType;
      _selectedDateTime = widget.order.deliveryDateTime;
      _trackingController.text = widget.order.trackingNumber ?? '';
      _pinController.clear();
      _refundPinController.clear();
    }
  }

  @override
  void dispose() {
    _refundPinController.dispose();
    _pinController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _callPhone() async {
    final uri = Uri(scheme: 'tel', path: widget.order.clientPhone);
    setState(() => _callCount++);
    widget.onCall?.call();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть звонилку')),
      );
    }
  }

  void _updateStatus(OrderStatus next) {
    setState(() {
      _status = next;
    });
    widget.onStatusChanged?.call(next);
  }

  void _showCancelReasonDialog() {
    final reasonController = TextEditingController();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                // Текущая реализация переводит заказ в cancelled.
                // Если по бизнес-логике нужно сразу refundRequired —
                // поменяйте статус здесь и логику карточки.
                _updateStatus(OrderStatus.cancelled);
                // Можно дополнительно уведомить родителя, если он хранит cancelReason.
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    ).then((_) => reasonController.dispose());
  }

  void _showRefundDialog() {
    final reasonController = TextEditingController();
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
                  hintText: 'Например: не подошёл размер, передумал и т.д.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  widget.onClientRefund?.call(reason);
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                'Подтвердить отказ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ).then((_) => reasonController.dispose());
  }

  String _formatDateTime(DateTime dateTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dateTime.day)}.${two(dateTime.month)}.${dateTime.year} ${two(dateTime.hour)}:${two(dateTime.minute)}';
  }

  Future<void> _pickExactDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _selectedDateTime = dt;
    });
    widget.onDeliveryTimeChanged?.call(widget.order.id, dt);
    // Триггерим перерисовку родителя, если нужно
    widget.onStatusChanged?.call(_status);
  }

  bool get _controlsBlocked => widget.blockAll;
  bool get _onlyCallAllowed => widget.blockExceptCall;

  @override
  Widget build(BuildContext context) {
    final isCompleted = _status == OrderStatus.completed;
    final isRefund = _status == OrderStatus.refundRequired;

    return Opacity(
      opacity: _controlsBlocked ? 0.5 : 1,
      child: AbsorbPointer(
        absorbing: _controlsBlocked,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side:
                isRefund
                    ? BorderSide(color: Colors.red.shade400, width: 2)
                    : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRefund)
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Возврат клиента',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                if (isRefund) const SizedBox(height: 8),

                // Адрес
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
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$query',
                        );
                        launchUrl(url);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Трек‑номер
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Трек-номер:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _trackingController,
                        onChanged: (value) {
                          // здесь можно дергать callback наверх, если требуется
                          // например: widget.onTrackingChanged?.call(widget.order.id, value);
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

                // "Взять в работу"
                if (_status == OrderStatus.active && !_onlyCallAllowed) ...[
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
                      onPressed: () => _updateStatus(OrderStatus.inProgress),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Название товара
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 32,
                      color: Colors.blueGrey[700],
                    ),
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
                    const Text('Габариты: ', style: TextStyle(fontSize: 18)),
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
                    const Text('Вес: ', style: TextStyle(fontSize: 18)),
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

                // Клиент
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text('Клиент: ', style: TextStyle(fontSize: 18)),
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

                // Кнопка «Клиент отказался» (для inProgress)
                if (_status == OrderStatus.inProgress && !_onlyCallAllowed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_off, color: Colors.white),
                      label: const Text('Клиент отказался'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: _showCancelReasonDialog,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Причина отказа (cancelled)
                if (_status == OrderStatus.cancelled &&
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
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 8),

                // Телефон + счётчик звонков
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap:
                          _onlyCallAllowed
                              ? _callPhone
                              : (_controlsBlocked ? null : _callPhone),
                      child: Text(
                        widget.order.clientPhone,
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              _onlyCallAllowed
                                  ? Colors.blue
                                  : (_controlsBlocked
                                      ? Colors.grey
                                      : Colors.blue),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Позвонить',
                      child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color:
                              _onlyCallAllowed
                                  ? Colors.green
                                  : (_controlsBlocked
                                      ? Colors.grey
                                      : Colors.green),
                          size: 28,
                        ),
                        onPressed:
                            _onlyCallAllowed
                                ? _callPhone
                                : (_controlsBlocked ? null : _callPhone),
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
                          const Icon(
                            Icons.call_made,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Звонков: $_callCount',
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
                    const Text(
                      'Когда привезти:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<DeliveryType>(
                      value: _selectedDeliveryType,
                      items: const [
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
                                setState(() => _selectedDeliveryType = val);
                                if (val == DeliveryType.exactDateTime) {
                                  await _pickExactDateTime();
                                }
                                // Обновляем родителя (если ему важно знать о текущем статусе при смене окна доставки)
                                widget.onStatusChanged?.call(_status);
                              },
                    ),
                    if (_selectedDeliveryType == DeliveryType.exactDateTime &&
                        _selectedDateTime != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          _formatDateTime(_selectedDateTime!),
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

                // PIN завершения
                Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text('PIN клиента:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    if (isCompleted && _pinController.text.isNotEmpty)
                      Text(
                        _pinController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (!isCompleted &&
                        _status == OrderStatus.inProgress &&
                        !_onlyCallAllowed) ...[
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: 'PIN',
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
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
                        onPressed: () {
                          if (_pinController.text.trim() == _testPin) {
                            _updateStatus(OrderStatus.completed);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Доставка завершена успешно'),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный PIN!')),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),

                // Кнопка отказа клиента для завершённых заказов (переход в refund)
                if (_status == OrderStatus.completed) ...[
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
                      onPressed: _showRefundDialog,
                    ),
                  ),
                ],

                // Панель возврата
                if (_status == OrderStatus.refundRequired) ...[
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (widget.order.refundReason != null)
                          Text(
                            'Причина: ${widget.order.refundReason}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        const SizedBox(height: 16),
                        const Text(
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
                              onPressed: () {
                                final pin = _refundPinController.text.trim();
                                if (pin == _refundTestPin) {
                                  _updateStatus(OrderStatus.completed);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Возврат успешно завершён!',
                                      ),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Неверный PIN!'),
                                    ),
                                  );
                                }
                              },
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
        ),
      ),
    );
  }
}
