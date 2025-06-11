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
  // Get current user synchronously (for immediate access)
  User? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    return User(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      role: UserRole
          .employee, // Default role, should be updated with getCurrentUser()
    );
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  // Get user role
  Future<UserRole> getCurrentUserRole() async {
    final user = await getCurrentUser();
    return user?.role ?? UserRole.employee;
  }

  // Sign up with role
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.employee,
  }) async {
    try {
      print('Starting signup process for: $email with role: ${role.name}');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      print('Auth signup response: ${response.user?.id}');

      if (response.user != null) {
        print('Creating user profile in database...');

        // Create user profile in users table with the selected role
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role.name,
        });

        print('User profile created successfully with role: ${role.name}');
      } else {
        throw Exception('Failed to create auth user');
      }
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in user: $email');

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Auth sign in successful, fetching user profile...');

      // Return user with role information from database
      final user = await getCurrentUser();
      print('Sign in complete. User role: ${user?.role.name}');

      return user;
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _supabase
          .from('users')
          .update({'role': newRole.name}).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Get all users (simplified)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((userData) => User.fromJson(userData))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}
