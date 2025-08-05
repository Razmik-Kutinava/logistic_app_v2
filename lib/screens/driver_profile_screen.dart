import 'package:flutter/material.dart';

class DriverProfileScreen extends StatelessWidget {
  final String phone;
  final String name;
  final String carNumber;
  final int experience;

  const DriverProfileScreen({
    super.key,
    required this.phone,
    required this.name,
    required this.carNumber,
    required this.experience,
  });

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Телефон: $phone', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Имя: $name', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text(
                  'Номер машины: $carNumber',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  'Стаж: $experience лет',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Редактировать'),
                    onPressed: () {
                      // TODO: Реализовать редактирование профиля
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
