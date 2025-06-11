import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coffee_management/features/auth/screens/login_screen.dart';
import 'package:coffee_management/features/auth/screens/register_screen.dart';
import 'package:coffee_management/features/dashboard/screens/dashboard_screen.dart';
import 'package:coffee_management/features/inventory/screens/inventory_screen.dart';
import 'package:coffee_management/features/shifts/screens/shift_screen.dart';
import 'package:coffee_management/features/sales/screens/sales_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: '/shifts',
      name: 'shifts',
      builder: (context, state) => const ShiftScreen(),
    ),
    GoRoute(
      path: '/sales',
      name: 'sales',
      builder: (context, state) => const SalesScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri.toString()}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    ),
  ),
);
