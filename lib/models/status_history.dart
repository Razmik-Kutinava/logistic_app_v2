class StatusHistory {
  final String orderId;
  final DateTime time;
  final String status;
  final String? comment;

  StatusHistory({
    required this.orderId,
    required this.time,
    required this.status,
    this.comment,
  });
}
