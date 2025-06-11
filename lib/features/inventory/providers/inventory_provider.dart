import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';
import 'package:coffee_management/features/inventory/services/inventory_service.dart';

// Service provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

// Simple state provider for inventory items
final inventoryItemsProvider = StateProvider<List<InventoryItem>>((ref) {
  return [];
});

// Loading state provider
final inventoryLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
