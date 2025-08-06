enum OrderStatus { active, inProgress, completed, cancelled }

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
  final double weight;
  final String clientName;
  final String clientPhone;
  final String address;
  OrderStatus status;
  DeliveryType deliveryType;
  DateTime? deliveryDateTime;
  String? cancelReason;

  OrderModel({
    required this.id,
    required this.name,
    required this.dimensions,
    required this.weight,
    required this.clientName,
    required this.clientPhone,
    required this.address,
    required this.status,
    required this.deliveryType,
    this.deliveryDateTime,
    this.cancelReason,
  });

  OrderModel copyWith({
    String? id,
    String? name,
    String? dimensions,
    double? weight,
    String? clientName,
    String? clientPhone,
    String? address,
    OrderStatus? status,
    DeliveryType? deliveryType,
    DateTime? deliveryDateTime,
    String? cancelReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dimensions: dimensions ?? this.dimensions,
      weight: weight ?? this.weight,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      address: address ?? this.address,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryDateTime: deliveryDateTime ?? this.deliveryDateTime,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
