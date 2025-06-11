import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/auth/providers/auth_provider.dart';
import 'package:coffee_management/features/auth/models/user_model.dart';

class RoleBasedWidget extends ConsumerWidget {
  final Widget adminWidget;
  final Widget employeeWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const RoleBasedWidget({
    super.key,
    required this.adminWidget,
    required this.employeeWidget,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      data: (role) {
        switch (role) {
          case UserRole.admin:
            return adminWidget;
          case UserRole.employee:
            return employeeWidget;
        }
      },
      loading: () => loadingWidget ?? const CircularProgressIndicator(),
      error: (error, stack) => errorWidget ?? Text('Error: $error'),
    );
  }
}

class AdminOnlyWidget extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      data: (isAdmin) => isAdmin ? child : (fallback ?? const SizedBox.shrink()),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}