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
// Error state provider
final inventoryErrorProvider = StateProvider<String?>((ref) {
  return null;
});

// Inventory controller
class InventoryController extends StateNotifier<List<InventoryItem>> {
  final InventoryService _service;
  final Ref _ref;

  InventoryController(this._service, this._ref) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      _ref.read(inventoryLoadingProvider.notifier).state = true;
      _ref.read(inventoryErrorProvider.notifier).state = null;

      final items = await _service.getAllItems();
      state = items;

      _ref.read(inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(inventoryLoadingProvider.notifier).state = false;
      _ref.read(inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      _ref.read(inventoryLoadingProvider.notifier).state = true;
      _ref.read(inventoryErrorProvider.notifier).state = null;

      final newItem = await _service.addItem(item);
      state = [...state, newItem];

      _ref.read(inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(inventoryLoadingProvider.notifier).state = false;
      _ref.read(inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      _ref.read(inventoryLoadingProvider.notifier).state = true;
      _ref.read(inventoryErrorProvider.notifier).state = null;

      final updatedItem = await _service.updateItem(item);
      state = state.map((i) => i.id == item.id ? updatedItem : i).toList();

      _ref.read(inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(inventoryLoadingProvider.notifier).state = false;
      _ref.read(inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _ref.read(inventoryLoadingProvider.notifier).state = true;
      _ref.read(inventoryErrorProvider.notifier).state = null;

      await _service.deleteItem(id);
      state = state.where((item) => item.id != id).toList();

      _ref.read(inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(inventoryLoadingProvider.notifier).state = false;
      _ref.read(inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> updateItemQuantity(String id, int newQuantity) async {
    try {
      _ref.read(inventoryLoadingProvider.notifier).state = true;
      _ref.read(inventoryErrorProvider.notifier).state = null;

      await _service.updateItemQuantity(id, newQuantity);
      state = state.map((item) {
        if (item.id == id) {
          return item.copyWith(
            quantity: newQuantity,
            updatedAt: DateTime.now(),
          );
        }
        return item;
      }).toList();

      _ref.read(inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      _ref.read(inventoryLoadingProvider.notifier).state = false;
      _ref.read(inventoryErrorProvider.notifier).state = e.toString();
    }
  }
}
// Controller provider
final inventoryControllerProvider = StateNotifierProvider<InventoryController, List<InventoryItem>>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return InventoryController(service, ref);
});

