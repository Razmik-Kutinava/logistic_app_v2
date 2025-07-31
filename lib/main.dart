import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth_pin_screen.dart';
import 'screens/auth_phone_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Авторизация',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/authPin',
      routes: {
        '/authPin': (context) => const AuthPinScreen(),
        '/authPhone': (context) => const AuthPhoneScreen(),
        '/main': (context) => HomeScreen(),
      },
    );
  }
}
