import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/shifts/models/shift_model.dart';
import 'package:coffee_management/features/shifts/services/shift_service.dart';
import 'package:coffee_management/features/auth/models/user_model.dart' as auth_models;

final shiftServiceProvider = Provider<ShiftService>((ref) => ShiftService());

// All shifts (admin only)
final shiftsProvider = FutureProvider<List<Shift>>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return service.getAllShifts();
});

// Current user's shifts only
final myShiftsProvider = FutureProvider<List<Shift>>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return service.getMyShifts();
});

// Upcoming shifts for dashboard
final upcomingShiftsProvider = FutureProvider<List<Shift>>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return service.getUpcomingShifts();
});
