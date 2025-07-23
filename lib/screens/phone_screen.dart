import 'package:flutter/material.dart';

const String testPhone = '+79991234567';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorText;
  bool _authorized = false;

  void _checkPhone() {
    if (_phoneController.text == testPhone) {
      setState(() {
        _authorized = true;
        _errorText = null;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      });
    } else {
      setState(() {
        _errorText = 'Неверный номер телефона';
        _authorized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(
                    (0.15 * 255).toInt(),
                    Colors.grey.r.round(),
                    Colors.grey.g.round(),
                    Colors.grey.b.round(),
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF1B5E20),
                  child: Icon(
                    Icons.phone_android,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Введите номер телефона',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 16,
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _errorText,
                    counterText: '',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  onSubmitted: (_) => _checkPhone(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _checkPhone,
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Тестовый номер: +79991234567',
                  style: TextStyle(color: Colors.grey),
                ),
                if (_authorized)
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text(
                      'Авторизация успешна!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
