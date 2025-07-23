class AuthService {
  // Пример: список пользователей (заглушка)
  static final List<Map<String, String>> _users = [
    {'pin': '1234', 'phone': '+79991234567'},
    {'pin': '5678', 'phone': '+79991112233'},
  ];

  // Авторизация по пину
  static bool authorizeByPin(String pin) {
    return _users.any((user) => user['pin'] == pin);
  }

  // Авторизация по телефону
  static bool authorizeByPhone(String phone) {
    return _users.any((user) => user['phone'] == phone);
  }
}
