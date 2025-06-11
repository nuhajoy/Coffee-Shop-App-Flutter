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
