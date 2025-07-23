import 'package:flutter/material.dart';
import 'screens/pin_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/main_screen.dart';

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
      initialRoute: '/pin',
      routes: {
        '/pin': (context) => const PinScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
