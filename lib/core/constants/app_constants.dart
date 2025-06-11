class AppConstants {
  // Your actual Supabase credentials (✅ Good!)
  static const String supabaseUrl = 'https://npzhwlaeqtjfwfaxfvql.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wemh3bGFlcXRqZndmYXhmdnFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0OTY1OTQsImV4cCI6MjA2NTA3MjU5NH0.xI9491gziQbd-TXqSChiPgKV7C54doA7Om-nLvkg-kc';

  // App Configuration
  static const String appName = 'Coffee Management';
  static const String appVersion = '1.0.0';

  // Table names
  static const String inventoryItemsTable = 'inventory_items';
  static const String shiftsTable = 'shifts';
  static const String salesTable = 'sales';
  static const String usersTable = 'users';
  static const String employeesTable = 'employees';
  static const String salesItemsTable = 'sales_items';
  static const String categoriesTable = 'categories';

  // Low stock threshold
  static const int lowStockThreshold = 10;

  // Categories
  static const List<String> inventoryCategories = [
    'Coffee',
    'Tea',
    'Pastry',
    'Equipment',
    'Other'
  ];

  // Positions
  static const List<String> employeePositions = [
    'Barista',
    'Cashier',
    'Manager',
    'Supervisor'
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Card',
    'Mobile'
  ];

  // Shift Status
  static const List<String> shiftStatuses = [
    'Scheduled',
    'In Progress',
    'Completed',
    'Cancelled'
  ];

  // Order Status
  static const List<String> orderStatuses = [
    'Pending',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled'
  ];
}
