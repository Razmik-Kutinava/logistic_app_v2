enum OrderStatus { active, inProgress, completed, returned }

enum DeliveryType {
  urgent, // Срочно
  in1hour, // Через 1 час
  in2hours, // Через 2 часа
  in3hours, // Через 3 часа
  tomorrowMorning, // Завтра утром
  tomorrowDay, // Завтра днём
  exactDateTime, // Точная дата/время
}

class OrderModel {
  final String id;
  final String name;
  final String dimensions;
  final String clientName;
  final String clientPhone;
  final String address;
  OrderStatus status;
  DeliveryType deliveryType;
  DateTime? deliveryDateTime;
  String? deliveryTime;

  OrderModel({
    required this.id,
    required this.name,
    required this.dimensions,
    required this.clientName,
    required this.clientPhone,
    required this.address,
    required this.status,
    this.deliveryType = DeliveryType.urgent,
    this.deliveryDateTime,
    this.deliveryTime,
  });
}
