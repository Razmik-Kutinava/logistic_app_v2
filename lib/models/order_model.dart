enum OrderStatus { active, inProgress, completed, returned }

class OrderModel {
  final String id;
  final String name;
  final String dimensions;
  final String clientName;
  final String clientPhone;
  final String address;
  OrderStatus status;
  String? deliveryTime;

  OrderModel({
    required this.id,
    required this.name,
    required this.dimensions,
    required this.clientName,
    required this.clientPhone,
    required this.address,
    required this.status,
    this.deliveryTime,
  });
}
