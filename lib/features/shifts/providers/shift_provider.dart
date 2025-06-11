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
// All users (for admin to assign shifts) - RENAMED to avoid conflict
final shiftAllUsersProvider = FutureProvider<List<auth_models.User>>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return service.getAllUsers();
});

// Check if current user is admin
final isShiftAdminProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return service.isAdmin;
});

class ShiftNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final ShiftService _service;

  ShiftNotifier(this.ref, this._service) : super(const AsyncValue.data(null));

  Future<void> addShift(Shift shift) async {
    state = const AsyncValue.loading();
    try {
      await _service.addShift(shift);
      // Invalidate all shift providers to refresh the data
      ref.invalidate(shiftsProvider);
      ref.invalidate(myShiftsProvider);
      ref.invalidate(upcomingShiftsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> updateShift(Shift shift) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateShift(shift);
      ref.invalidate(shiftsProvider);
      ref.invalidate(myShiftsProvider);
      ref.invalidate(upcomingShiftsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteShift(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteShift(id);
      ref.invalidate(shiftsProvider);
      ref.invalidate(myShiftsProvider);
      ref.invalidate(upcomingShiftsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
final shiftNotifierProvider =
StateNotifierProvider<ShiftNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(shiftServiceProvider);
  return ShiftNotifier(ref, service);
});
