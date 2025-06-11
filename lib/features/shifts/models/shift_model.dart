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
