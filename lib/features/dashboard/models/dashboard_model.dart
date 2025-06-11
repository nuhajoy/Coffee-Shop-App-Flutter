class DashboardStats {
  final int totalSalesItems;
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;
  final int todayOrders;
  final int weeklyOrders;
  final int monthlyOrders;
  final List<TopSellingItem> topSellingItems;
  final NextShift? nextShift;

  DashboardStats({
    required this.totalSalesItems,
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
    required this.todayOrders,
    required this.weeklyOrders,
    required this.monthlyOrders,
    required this.topSellingItems,
    this.nextShift,
  });

  