class Order {
  final String id;
  final String title;
  final String size;
  final String clientPhone;
  final String clientName;
  final String address;
  final String status;
  final String qrCode;
  final DateTime deliveryTime;
  final String driverId;

  Order({
    required this.id,
    required this.title,
    required this.size,
    required this.clientPhone,
    required this.clientName,
    required this.address,
    required this.status,
    required this.qrCode,
    required this.deliveryTime,
    required this.driverId,
  });
}
