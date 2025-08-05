import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/auth_phone_screen.dart';
import 'screens/driver_profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Логистика - Авторизация',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPhoneScreen(),
        '/main': (context) => HomeScreen(),
        '/profile': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return DriverProfileScreen(
            phone: args?['phone'] ?? '',
            name: args?['name'] ?? '',
            carNumber: args?['carNumber'] ?? '',
            experience: args?['experience'] ?? 0,
          );
        },
      },
    );
  }
}
