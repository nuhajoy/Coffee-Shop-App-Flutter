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

