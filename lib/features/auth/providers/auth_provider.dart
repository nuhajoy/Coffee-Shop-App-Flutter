import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/auth/services/auth_service.dart';
import 'package:coffee_management/features/auth/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Updated to use FutureProvider for async role loading
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isLoggedIn) return null;
  return await authService.getCurrentUser();
});

final isLoggedInProvider = StateProvider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn;
});
