import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:coffee_management/core/constants/app_constants.dart';
import 'package:coffee_management/core/supabase_client.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';

class InventoryService {
  final SupabaseClient _supabase = supabase;
  final String _tableName = AppConstants.inventoryItemsTable;
  final _uuid = const Uuid();
  // Get all inventory items
  Future<List<InventoryItem>> getAllItems() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get inventory items: $e');
    }
  }

   // Get inventory item by ID
  Future<InventoryItem> getItemById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return InventoryItem.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get inventory item: $e');
    }
  }

   // Add new inventory item
  Future<InventoryItem> addItem(InventoryItem item) async {
    try {
      final now = DateTime.now();
      final newItem = item.copyWith(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from(_tableName).insert(newItem.toJson());
      return newItem;
    } catch (e) {
      throw Exception('Failed to add inventory item: $e');
    }
  }

  // Update inventory item
  Future<InventoryItem> updateItem(InventoryItem item) async {
    try {
      final updatedItem = item.copyWith(
        updatedAt: DateTime.now(),
      );

      await _supabase
          .from(_tableName)
          .update(updatedItem.toJson())
          .eq('id', item.id);

      return updatedItem;
    } catch (e) {
      throw Exception('Failed to update inventory item: $e');
    }
  }

  // Delete inventory item
  Future<void> deleteItem(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete inventory item: $e');
    }
  }

  // Get low stock items
  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .lte('quantity', AppConstants.lowStockThreshold)
          .order('quantity', ascending: true);

      return (response as List)
          .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock items: $e');
    }
  }

  // Get items by category
  Future<List<InventoryItem>> getItemsByCategory(String category) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('category', category)
          .order('name', ascending: true);

      return (response as List)
          .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get items by category: $e');
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String id, int newQuantity) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
        'quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update item quantity: $e');
    }
  }
}


