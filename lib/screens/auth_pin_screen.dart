import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthPinScreen extends StatefulWidget {
  const AuthPinScreen({super.key});

  @override
  State<AuthPinScreen> createState() => _AuthPinScreenState();
}

class _AuthPinScreenState extends State<AuthPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  void _next() {
    final pin = _pinController.text.trim();
    if (AuthService.authorizeByPin(pin)) {
      Navigator.pushReplacementNamed(context, '/authPhone');
    } else {
      setState(() {
        _error = 'Неверный PIN';
      });
    }
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
                'Авторизация по PIN',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Далее'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
