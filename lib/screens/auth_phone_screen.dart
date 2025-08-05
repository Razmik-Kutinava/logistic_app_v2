import 'package:flutter/material.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _isPhoneEntered = false;
  bool _showPassword = false;

  void _continueToPassword() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() {
        _error = 'Введите корректный номер телефона';
      });
      return;
    }
    setState(() {
      _isPhoneEntered = true;
      _error = null;
    });
  }

  void _login() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (password.isEmpty || password.length < 6 || password.length > 8) {
      setState(() {
        _error = 'Пароль должен содержать от 6 до 8 символов';
      });
      return;
    }

    // Проверка авторизации
    if (_checkCredentials(phone, password)) {
      _showSuccessDialog();
    } else {
      setState(() {
        _error = 'Неверный пароль компании';
      });
    }
  }

  bool _checkCredentials(String phone, String password) {
    // Тестовые данные для водителя
    return phone == '1234567890' && password == '123456';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Авторизация успешна'),
            content: const Text(
              'Вы прошли авторизацию!\nДобро пожаловать в систему логистики.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('Продолжить'),
              ),
            ],
          ),
    );
  }

  void _backToPhone() {
    setState(() {
      _isPhoneEntered = false;
      _error = null;
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Авторизация водителя',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Поле телефона (всегда видимо)
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Номер телефона',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isPhoneEntered,
              ),

              if (!_isPhoneEntered) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToPassword,
                    child: const Text('Продолжить'),
                  ),
                ),
              ],

              // Поле пароля (показывается после ввода телефона)
              if (_isPhoneEntered) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль компании (6-8 символов)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_showPassword,
                  maxLength: 8,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _backToPhone,
                        child: const Text('Назад'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Войти'),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
