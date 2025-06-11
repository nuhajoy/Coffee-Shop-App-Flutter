class Sale {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? customerName;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.customerName,
    required this.createdAt,
  });

  // Factory to parse from JSON
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      customerName: json['customer_name'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'customer_name': customerName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Sale copyWith({
    String? id,
    String? itemId,
    String? itemName,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? customerName,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}