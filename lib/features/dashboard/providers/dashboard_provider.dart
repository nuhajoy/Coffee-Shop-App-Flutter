import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/dashboard/services/dashboard_service.dart';
import 'package:coffee_management/features/dashboard/models/dashboard_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService());

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getDashboardStats();
});

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

final refreshedDashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  ref.watch(dashboardRefreshProvider); // This will trigger refresh when the state changes
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getDashboardStats();
});