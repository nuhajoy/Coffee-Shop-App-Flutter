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
// Add new role-based providers
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isLoggedIn) return false;
  return await authService.isCurrentUserAdmin();
});

final userRoleProvider = FutureProvider<UserRole>((ref) async {
  final authService = ref.watch(authServiceProvider);
  if (!authService.isLoggedIn) return UserRole.employee;
  return await authService.getCurrentUserRole();
});

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAllUsers();
});

// Enhanced AuthNotifier with role support
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.employee,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      // Invalidate providers to refresh user data
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(isAdminProvider);
      _ref.invalidate(userRoleProvider);
      _ref.invalidate(isLoggedInProvider);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signIn(email: email, password: password);
