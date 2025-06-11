class Shift {
  final String id;
  final String? userId; // Made nullable to handle existing data
  final String employeeName;
  final String employeeEmail;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shift({
    required this.id,
    this.userId, // Made optional
    required this.employeeName,
    required this.employeeEmail,
    required this.startTime,
    required this.endTime,
    this.status = 'Scheduled',
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      userId: json['user_id'] as String?, // Handle null values
      employeeName: json['employee_name'] as String,
      employeeEmail: json['employee_email'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String? ?? 'Scheduled',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Shift copyWith({
    String? id,
    String? userId,
    String? employeeName,
    String? employeeEmail,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
