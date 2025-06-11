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
    const SizedBox(height: 16),

    // Stats Cards
    Row(
    children: [
    Expanded(
    child: _buildStatCard(
    'Sales Items',
    '24',
    Icons.inventory,
    AppTheme.lightBrown,
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: _buildStatCard(
    "Today's Revenue",
    'ETB 1,245.50',
    Icons.attach_money,
    Colors.green.shade100,
    ),
    ),
    ],
    ),
    const SizedBox(height: 24),

    // Next Shift Info - Shows Real User Shifts
    Card(
    color: Colors.white.withOpacity(0.95),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Your Upcoming Shifts',
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 12),
    upcomingShiftsAsync.when(
    data: (shifts) => _buildShiftsSection(shifts),
    loading: () => const Center(
    child: Padding(
    padding: EdgeInsets.all(16),
    child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
    ),
    ),
    ),
    error: (error, _) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    children: [
    const Icon(Icons.error_outline, size: 48, color: Colors.red),
    const SizedBox(height: 8),
    Text(
    'Unable to load shifts',
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    'Please check your connection',
    style: const TextStyle(
    fontSize: 12,
    color: AppTheme.textSecondary,
    ),
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 16),
    // Quick Action Buttons

      isAdminAsync.when(
        data: (isAdmin) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              'Inventory',
              Icons.inventory_2,
                  () => context.go('/inventory'),
            ),
            _buildQuickActionButton(
              'Shifts',
              Icons.schedule,
                  () => context.go('/shifts'),
            ),
            if (isAdmin) // Only show Sales for admin
              _buildQuickActionButton(
                'Sales',
                Icons.point_of_sale,
                    () => context.go('/sales'),
              ),
          ],
        ),
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
    ],
    ),
    ),
    ),

      const SizedBox(height: 24),

      // Welcome Message
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Welcome To Coffee Abyssinia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
    ),
    ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildShiftsSection(List<Shift> shifts) {
    if (shifts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.schedule, size: 48, color: AppTheme.textSecondary),
              SizedBox(height: 8),
              Text(
                'No upcoming shifts',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'Check with your manager for schedule updates',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: shifts.take(3).map((shift) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightBrown.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              width: 4,
              color: _getStatusColor(shift.status),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: _getStatusColor(shift.status),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM dd').format(shift.startTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (shift.notes.isNotEmpty)
                    Text(
                      shift.notes,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(shift.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                shift.status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(shift.status),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
      case 'in progress':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryBrown),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.darkBrown),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}





