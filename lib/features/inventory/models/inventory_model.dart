class InventoryItem {
  final String id;
  final String name;
  final String? description;
  final String category;
  final int quantity;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => quantity <= 10;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    try {
      return InventoryItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        category: json['category']?.toString() ?? 'Coffee',
        // Map 'stock' to 'quantity'
        quantity: _parseToInt(json['stock'] ?? json['quantity']),
        // Use 'price' directly
        price: _parseToDouble(json['price'] ?? json['unit_price']),
        imageUrl: json['image_url']?.toString(),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      print('❌ Error parsing InventoryItem: $json');
      print('❌ Error details: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      // Map back to database column names
      'stock': quantity,  // Use 'stock' for database
      'price': price,     // Use 'price' for database
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? quantity,
    double? price,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
