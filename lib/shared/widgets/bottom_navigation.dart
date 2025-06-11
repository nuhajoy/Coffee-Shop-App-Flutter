import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/features/auth/providers/auth_provider.dart';
import 'package:coffee_management/features/auth/models/user_model.dart';

class BottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(userRoleProvider);

    return userRoleAsync.when(
      data: (role) => _buildBottomNavBar(context, role),
      loading: () => _buildBottomNavBar(context, UserRole.employee),
      error: (error, stack) => _buildBottomNavBar(context, UserRole.employee),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, UserRole role) {
    // Base navigation items available to all users
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    ];

    // Add role-specific navigation items
    if (role == UserRole.admin) {
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Sales',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Shifts',
        ),
      ]);
    } else {
      // Employee only sees shifts (their own)
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'My Shifts',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: currentIndex >= items.length ? 0 : currentIndex,
      onTap: (index) => _onItemTapped(context, index, role),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryBrown,
      unselectedItemColor: AppTheme.textSecondary,
      backgroundColor: Colors.white,
      elevation: 8,
      items: items,
    );
  }

  void _onItemTapped(BuildContext context, int index, UserRole role) {
    if (role == UserRole.admin) {
      // Admin navigation - FIXED TO USE GOROUTER
      switch (index) {
        case 0:
          if (currentIndex != 0) {
            context.go('/dashboard');
          }
          break;
        case 1:
          if (currentIndex != 1) {
            context.go('/sales');
          }
          break;
        case 2:
          if (currentIndex != 2) {
            context.go('/inventory');
          }
          break;
        case 3:
          if (currentIndex != 3) {
            context.go('/shifts');
          }
          break;
      }
    } else {
      // Employee navigation - FIXED TO USE GOROUTER
      switch (index) {
        case 0:
          if (currentIndex != 0) {
            context.go('/dashboard');
          }
          break;
        case 1:
          if (currentIndex != 1) {
            context.go('/shifts'); // or '/my-shifts' if you have a separate route
          }
          break;
      }
    }
  }
}
