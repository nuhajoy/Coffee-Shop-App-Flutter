import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:coffee_management/core/supabase_client.dart';
import 'package:coffee_management/features/auth/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = supabase;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // SIMPLIFIED - Get current user with role from database
  Future<User?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      print('Fetching user profile for: ${authUser.id}');

      // Simple query without complex policies
      final response = await _supabase
          .from('users')
          .select('id, email, full_name, avatar_url, role, created_at, updated_at')
          .eq('id', authUser.id)
          .maybeSingle(); // Use maybeSingle instead of single

      if (response == null) {
        print('User not found in users table, creating...');

        // Create user profile if it doesn't exist
        final newUser = {
          'id': authUser.id,
          'email': authUser.email ?? '',
          'full_name': authUser.userMetadata?['full_name'] ?? 'User',
          'role': 'employee', // Default role
        };

        await _supabase.from('users').insert(newUser);

        return User(
          id: authUser.id,
          email: authUser.email ?? '',
          fullName: authUser.userMetadata?['full_name'] ?? 'User',
          role: UserRole.employee,
        );
      }

      print('User data from DB: $response');
      final user = User.fromJson(response);
      print('Parsed user role: ${user.role.name}');

      return user;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }