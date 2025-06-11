import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffee_management/features/shifts/models/shift_model.dart';
import 'package:coffee_management/features/auth/models/user_model.dart' as auth_models;
import 'package:coffee_management/core/constants/app_constants.dart';

class ShiftService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user's full name from the users table
  Future<String> get currentUserName async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Guest';

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('full_name')
          .eq('id', user.id)
          .single();

      return response['full_name'] ?? 'User';
    } catch (e) {
      print('Error getting user name: $e');
      return 'User';
    }
  }
  // Get current user's role
  Future<String> get currentUserRole async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'employee';

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'] ?? 'employee';
    } catch (e) {
      print('Error getting user role: $e');
      return 'employee';
    }
  }

  // Check if current user is admin
  Future<bool> get isAdmin async {
    final role = await currentUserRole;
    return role == 'admin';
  }

  // Get all users (for admin to assign shifts)
  Future<List<auth_models.User>> getAllUsers() async {
    try {
      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('*')
          .order('full_name', ascending: true);

      return (response as List)
          .map((json) => auth_models.User.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      throw Exception('Failed to load users: $e');
    }
  }
// Get all shifts (admin only)
  Future<List<Shift>> getAllShifts() async {
    try {
      final response = await _supabase
          .from(AppConstants.shiftsTable)
          .select('*')
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => Shift.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all shifts: $e');
      throw Exception('Failed to load shifts: $e');
    }
  }

  // Get current user's shifts only
  Future<List<Shift>> getMyShifts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Try with user_id first, fallback to employee_email if user_id doesn't exist
      try {
        final response = await _supabase
            .from(AppConstants.shiftsTable)
            .select('*')
            .eq('user_id', user.id)
            .order('start_time', ascending: true);

        return (response as List)
            .map((json) => Shift.fromJson(json))
            .toList();
      } catch (e) {
        // Fallback: query by email if user_id column doesn't exist
        final userEmail = user.email;
        if (userEmail != null) {
          final response = await _supabase
              .from(AppConstants.shiftsTable)
              .select('*')
              .eq('employee_email', userEmail)
              .order('start_time', ascending: true);

          return (response as List)
              .map((json) => Shift.fromJson(json))
              .toList();
        }
        return [];
      }
    } catch (e) {
      print('Error getting my shifts: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Get upcoming shifts for current user (for dashboard)
  Future<List<Shift>> getUpcomingShifts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];


      final now = DateTime.now();

      // Try with user_id first, fallback to employee_email
      try {
        final response = await _supabase
            .from(AppConstants.shiftsTable)
            .select('*')
            .eq('user_id', user.id)
            .gte('start_time', now.toIso8601String())
            .order('start_time', ascending: true)
            .limit(3);

        return (response as List)
            .map((json) => Shift.fromJson(json))
            .toList();
      } catch (e) {
        // Fallback: query by email
        final userEmail = user.email;
        if (userEmail != null) {
          final response = await _supabase
              .from(AppConstants.shiftsTable)
              .select('*')
              .eq('employee_email', userEmail)
              .gte('start_time', now.toIso8601String())
              .order('start_time', ascending: true)
              .limit(3);

          return (response as List)
              .map((json) => Shift.fromJson(json))
              .toList();
        }
        return [];
      }
    } catch (e) {
      print('Error getting upcoming shifts: $e');
      return [];
    }
  }
  // Add shift (admin assigns to any user, employee can only add for themselves)
  Future<void> addShift(Shift shift) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _supabase
          .from(AppConstants.shiftsTable)
          .insert({
        'user_id': shift.userId,
        'employee_name': shift.employeeName,
        'employee_email': shift.employeeEmail,
        'start_time': shift.startTime.toIso8601String(),
        'end_time': shift.endTime.toIso8601String(),
        'status': shift.status,
        'notes': shift.notes,
      });
    } catch (e) {
      print('Error adding shift: $e');
      throw Exception('Failed to add shift: $e');
    }
  }

  // Update shift
  Future<void> updateShift(Shift updatedShift) async {
    try {
      await _supabase
          .from(AppConstants.shiftsTable)
          .update({
        'user_id': updatedShift.userId,
        'employee_name': updatedShift.employeeName,
        'employee_email': updatedShift.employeeEmail,
        'start_time': updatedShift.startTime.toIso8601String(),
        'end_time': updatedShift.endTime.toIso8601String(),
        'status': updatedShift.status,
        'notes': updatedShift.notes,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', updatedShift.id);
    } catch (e) {
      print('Error updating shift: $e');
      throw Exception('Failed to update shift: $e');
    }
  }

  // Delete shift
  Future<void> deleteShift(String id) async {
    try {
      await _supabase
          .from(AppConstants.shiftsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting shift: $e');
      throw Exception('Failed to delete shift: $e');
    }
  }
}


