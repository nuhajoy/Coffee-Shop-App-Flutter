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