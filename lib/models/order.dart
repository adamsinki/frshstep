enum OrderStatus { pending, ongoing, complete, canceled }

class OrderModel {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String size;
  final String color;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final String location;
  final String note;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.size,
    required this.color,
    required this.quantity,
    required this.totalPrice,
    this.status = OrderStatus.pending,
    this.location = '',
    this.note = '',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'city': city,
      'size': size,
      'color': color,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status.name,
      'location': location,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? '',
      size: map['size'] ?? '',
      color: map['color'] ?? '',
      quantity: map['quantity'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: _statusFromString(map['status']),
      location: map['location'] ?? '',
      note: map['note'] ?? '',
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static OrderStatus _statusFromString(String? status) {
    switch (status) {
      case 'ongoing':
        return OrderStatus.ongoing;
      case 'complete':
        return OrderStatus.complete;
      case 'canceled':
        return OrderStatus.canceled;
      default:
        return OrderStatus.pending;
    }
  }
}
