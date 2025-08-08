import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  final String phone;
  final String name;
  final String carNumber;
  final int experience;
  final int completedOrders;
  final int cancelledOrdersCount;
  final List cancelledOrders;
  final int refundOrdersCount;
  final List refundOrders;

  const DriverProfileScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.carNumber,
    required this.experience,
    required this.completedOrders,
    required this.cancelledOrdersCount,
    required this.cancelledOrders,
    required this.refundOrdersCount,
    required this.refundOrders,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late TextEditingController phoneController;
  late TextEditingController nameController;
  late TextEditingController carController;
  late TextEditingController experienceController;
  // Паспортные данные
  late TextEditingController passportSeriesController;
  late TextEditingController passportNumberController;
  late TextEditingController passportDateController;
  late TextEditingController passportIssuedByController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.phone);
    nameController = TextEditingController(text: widget.name);
    carController = TextEditingController(text: widget.carNumber);
    experienceController = TextEditingController(
      text: widget.experience.toString(),
    );
    // Для примера, можно заменить на реальные данные из модели
    passportSeriesController = TextEditingController(text: 'AB');
    passportNumberController = TextEditingController(text: '123456');
    passportDateController = TextEditingController(text: '01.01.2020');
    passportIssuedByController = TextEditingController(text: 'ОВД г. Ереван');
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    carController.dispose();
    experienceController.dispose();
    passportSeriesController.dispose();
    passportNumberController.dispose();
    passportDateController.dispose();
    passportIssuedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing
                      ? TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Телефон'),
                        keyboardType: TextInputType.phone,
                      )
                      : Text(
                        'Телефон: ${phoneController.text}',
                        style: const TextStyle(fontSize: 18),
                      ),
                  const SizedBox(height: 12),
                  isEditing
                      ? TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Имя'),
                      )
                      : Text(
                        'Имя: ${nameController.text}',
                        style: const TextStyle(fontSize: 18),
                      ),
                  const SizedBox(height: 12),
                  isEditing
                      ? TextField(
                        controller: carController,
                        decoration: const InputDecoration(
                          labelText: 'Номер машины',
                        ),
                      )
                      : Text(
                        'Номер машины: ${carController.text}',
                        style: const TextStyle(fontSize: 18),
                      ),
                  const SizedBox(height: 12),
                  isEditing
                      ? TextField(
                        controller: experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Стаж (лет)',
                        ),
                        keyboardType: TextInputType.number,
                      )
                      : Text(
                        'Стаж: ${experienceController.text} лет',
                        style: const TextStyle(fontSize: 18),
                      ),
                  const SizedBox(height: 12),
                  // Паспортные данные
                  const Text(
                    'Паспортные данные',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  isEditing
                      ? Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: passportSeriesController,
                              decoration: const InputDecoration(
                                labelText: 'Серия',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: TextField(
                              controller: passportNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Номер',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        'Серия: ${passportSeriesController.text}  Номер: ${passportNumberController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                  const SizedBox(height: 8),
                  isEditing
                      ? TextField(
                        controller: passportDateController,
                        decoration: const InputDecoration(
                          labelText: 'Дата выдачи',
                        ),
                        keyboardType: TextInputType.datetime,
                      )
                      : Text(
                        'Дата выдачи: ${passportDateController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                  const SizedBox(height: 8),
                  isEditing
                      ? TextField(
                        controller: passportIssuedByController,
                        decoration: const InputDecoration(
                          labelText: 'Кем выдан',
                        ),
                      )
                      : Text(
                        'Кем выдан: ${passportIssuedByController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    'Выполненных заказов: ${widget.completedOrders}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Отменённых заказов: ${widget.cancelledOrdersCount}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Возвратов: ${widget.refundOrdersCount}',
                    style: const TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Заказы, которые водитель не выполнил или клиент отказался:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.cancelledOrders.isEmpty)
                    const Text(
                      'Нет отменённых заказов',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (widget.cancelledOrders.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: widget.cancelledOrders.length,
                        itemBuilder: (context, index) {
                          final order = widget.cancelledOrders[index];
                          return Card(
                            color: Colors.red[50],
                            child: ListTile(
                              title: Text(
                                order.name,
                                style: const TextStyle(color: Colors.red),
                              ),
                              subtitle: Text(
                                order.cancelReason != null &&
                                        order.cancelReason!.isNotEmpty
                                    ? 'Причина: ${order.cancelReason}'
                                    : 'Причина не указана',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    'Возвратные заказы:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.refundOrders.isEmpty)
                    const Text(
                      'Нет возвратных заказов',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  if (widget.refundOrders.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: widget.refundOrders.length,
                        itemBuilder: (context, index) {
                          final order = widget.refundOrders[index];
                          return Card(
                            color: Colors.orange[50],
                            child: ListTile(
                              title: Text(
                                order.name,
                                style: const TextStyle(color: Colors.orange),
                              ),
                              subtitle: Text(
                                order.refundReason != null &&
                                        order.refundReason!.isNotEmpty
                                    ? 'Причина: ${order.refundReason}'
                                    : 'Причина не указана',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(isEditing ? Icons.save : Icons.edit),
                      label: Text(isEditing ? 'Сохранить' : 'Редактировать'),
                      onPressed: () {
                        setState(() {
                          if (isEditing) {
                            // Можно добавить логику сохранения в БД
                          }
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ),
                ],
              ), // Column
            ), // SingleChildScrollView
          ), // Padding (card)
        ), // Card
      ), // Padding (body)
    ); // Scaffold
  }
}
