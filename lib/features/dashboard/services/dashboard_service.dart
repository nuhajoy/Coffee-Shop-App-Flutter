import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffee_management/core/supabase_client.dart';
import 'package:coffee_management/features/dashboard/models/dashboard_model.dart';

class DashboardService {
  final SupabaseClient _supabase = supabase;

  Future<DashboardStats> getDashboardStats() async {
    try {
      // Get today's date range
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Get week start (Monday)
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

      // Get month start
      final monthStart = DateTime(now.year, now.month, 1);

      // Get today's revenue and orders
      final todayStats = await _getTodayStats(todayStart, todayEnd);

      // Get weekly revenue and orders
      final weeklyStats = await _getWeeklyStats(weekStart, todayEnd);

      // Get monthly revenue and orders
      final monthlyStats = await _getMonthlyStats(monthStart, todayEnd);

      // Get total sales items count
      final totalSalesItems = await _getTotalSalesItems();

      // Get top selling items
      final topSellingItems = await _getTopSellingItems();

      // Get next shift
      final nextShift = await _getNextShift();

      return DashboardStats(
        totalSalesItems: totalSalesItems,
        todayRevenue: todayStats['revenue'] ?? 0.0,
        weeklyRevenue: weeklyStats['revenue'] ?? 0.0,
        monthlyRevenue: monthlyStats['revenue'] ?? 0.0,
        todayOrders: todayStats['orders'] ?? 0,
        weeklyOrders: weeklyStats['orders'] ?? 0,
        monthlyOrders: monthlyStats['orders'] ?? 0,
        topSellingItems: topSellingItems,
        nextShift: nextShift,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  Future<Map<String, dynamic>> _getTodayStats(DateTime start, DateTime end) async {
    final response = await _supabase
        .from('sales')
        .select('total_amount')
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String());

    double revenue = 0.0;
    int orders = response.length;

    for (final sale in response) {
      revenue += (sale['total_amount'] as num).toDouble();
    }

    return {'revenue': revenue, 'orders': orders};
  }