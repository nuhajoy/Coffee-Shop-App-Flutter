import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/shared/widgets/bottom_navigation.dart';
import 'package:coffee_management/features/auth/providers/auth_provider.dart';
import 'package:coffee_management/features/shifts/providers/shift_provider.dart';
import 'package:coffee_management/features/shifts/models/shift_model.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final upcomingShiftsAsync = ref.watch(upcomingShiftsProvider);
    final isAdminAsync = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Abyssinia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
      // FIXED: Removed external image that was causing network errors
      decoration: BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppTheme.lightBrown.withOpacity(0.3),
        AppTheme.lightBrown.withOpacity(0.1),
        Colors.white,
      ],
    ),
    ),
    child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // User Welcome Card
    currentUserAsync.when(
    data: (user) => Card(
    color: Colors.white.withOpacity(0.95),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
    children: [
    CircleAvatar(
    backgroundColor: AppTheme.primaryBrown,
    child: Text(
    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Welcome, ${user?.fullName ?? 'User'}!',
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    isAdminAsync.when(
    data: (isAdmin) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
    color: isAdmin ? Colors.red.shade100 : Colors.blue.shade100,
    borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
    isAdmin ? 'Admin' : 'Employee',
    style: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,

      color: isAdmin ? Colors.red.shade700 : Colors.blue.shade700,
    ),
    ),
    ),
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
      ),
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox(),
    ),