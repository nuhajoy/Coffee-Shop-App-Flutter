import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffee_management/features/sales/models/sales_model.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';
import 'package:coffee_management/core/constants/app_constants.dart';

class SalesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user's full name from the users table
  Future<String> get currentUserName async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'Guest';

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('full_name')
          .eq('id', user.id)
          .single();

      return response['full_name'] ?? 'An';
    } catch (e) {
      print('Error getting user name: $e');
      return 'An'; // Fallback to 'An' if there's an error
    }
  }

  // Get all inventory items
  Future<List<InventoryItem>> getAllInventoryItems() async {
    try {
      final response = await _supabase
          .from(AppConstants.inventoryItemsTable)
          .select('*')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => InventoryItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting inventory items: $e');
      throw Exception('Failed to load inventory items: $e');
    }
  }

  // Get all sales
  Future<List<Sale>> getAllSales() async {
    try {
      final response = await _supabase
          .from(AppConstants.salesTable)
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Sale.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting sales: $e');
      throw Exception('Failed to load sales: $e');
    }
  }

  // Get sales summary (total revenue, total items sold)
  Future<Map<String, dynamic>> getSalesSummary() async {
    try {
      final sales = await getAllSales();

      double totalRevenue = 0;
      int totalItemsSold = 0;

      for (var sale in sales) {
        totalRevenue += sale.totalAmount;
        totalItemsSold += sale.quantity;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalItemsSold': totalItemsSold,
      };
    } catch (e) {
      print('Error getting sales summary: $e');
      throw Exception('Failed to calculate sales summary: $e');
    }
  }

  // Add a new sale
  Future<void> addSale(Sale sale) async {
    try {
      // First, update the inventory stock
      await _updateInventoryStock(sale.itemId, -sale.quantity);

      // Then add the sale record
      await _supabase
          .from(AppConstants.salesTable)
          .insert({
        'item_id': sale.itemId,
        'item_name': sale.itemName,
        'quantity': sale.quantity,
        'unit_price': sale.unitPrice,
        'total_amount': sale.totalAmount,
        'customer_name': sale.customerName,
      });
    } catch (e) {
      print('Error adding sale: $e');
      throw Exception('Failed to add sale: $e');
    }
  }

  // Update inventory stock
  Future<void> _updateInventoryStock(String itemId, int quantityChange) async {
    try {
      // First get the current stock
      final response = await _supabase
          .from(AppConstants.inventoryItemsTable)
          .select('stock')
          .eq('id', itemId)
          .single();

      int currentStock = response['stock'] as int;
      int newStock = currentStock + quantityChange;

      if (newStock < 0) {
        throw Exception('Not enough stock available');
      }

      // Update the stock
      await _supabase
          .from(AppConstants.inventoryItemsTable)
          .update({'stock': newStock})
          .eq('id', itemId);
    } catch (e) {
      print('Error updating inventory stock: $e');
      throw Exception('Failed to update inventory stock: $e');
    }
  }

  // Delete a sale
  Future<void> deleteSale(String id, String itemId, int quantity) async {
    try {
      // First, update the inventory stock (add the quantity back)
      await _updateInventoryStock(itemId, quantity);

      // Then delete the sale record
      await _supabase
          .from(AppConstants.salesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting sale: $e');
      throw Exception('Failed to delete sale: $e');
    }
  }
}