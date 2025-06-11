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

 factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSalesItems: json['total_sales_items'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      weeklyRevenue: (json['weekly_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      todayOrders: json['today_orders'] ?? 0,
      weeklyOrders: json['weekly_orders'] ?? 0,
      monthlyOrders: json['monthly_orders'] ?? 0,
      topSellingItems: (json['top_selling_items'] as List?)
          ?.map((item) => TopSellingItem.fromJson(item))
          .toList() ?? [],
      nextShift: json['next_shift'] != null
          ? NextShift.fromJson(json['next_shift'])
          : null,
    );
  }
}
class TopSellingItem {
  final String id;
  final String name;
  final int quantitySold;
  final double revenue;

  TopSellingItem({
    required this.id,
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantitySold: json['quantity_sold'] as int,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class NextShift {
  final String id;
  final String employeeName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  NextShift({
    required this.id,
    required this.employeeName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory NextShift.fromJson(Map<String, dynamic> json) {
    return NextShift(
      id: json['id'] as String,
      employeeName: json['employee_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
    );
  }
}