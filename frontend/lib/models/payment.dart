// lib/models/payment.dart
class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String provider;
  final String status;
  final String paymentId;
  final String? transId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.provider,
    required this.status,
    required this.paymentId,
    this.transId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      orderId: json['order'] ?? '',
      amount: json['amount'] != null ? json['amount'].toDouble() : 0.0,
      provider: json['provider'] ?? '',
      status: json['status'] ?? '',
      paymentId: json['paymentId'] ?? '',
      transId: json['transId'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }
}
