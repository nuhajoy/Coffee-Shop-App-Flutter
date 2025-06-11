import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/features/sales/models/sales_model.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';
import 'package:coffee_management/features/sales/services/sales_service.dart';

final salesServiceProvider = Provider<SalesService>((ref) => SalesService());

// Provider for all sales
final salesProvider = FutureProvider<List<Sale>>((ref) {
  final service = ref.watch(salesServiceProvider);
  return service.getAllSales();
});

// Provider for inventory items
final inventoryItemsProvider = FutureProvider<List<InventoryItem>>((ref) {
  final service = ref.watch(salesServiceProvider);
  return service.getAllInventoryItems();
});

// Provider for sales summary
final salesSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(salesServiceProvider);
  return service.getSalesSummary();
});

// Notifier for sales operations
class SalesNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final SalesService _service;

  SalesNotifier(this.ref, this._service) : super(const AsyncValue.data(null));

  Future<void> addSale(Sale sale) async {
    state = const AsyncValue.loading();
    try {
      await _service.addSale(sale);
      // Invalidate providers to refresh data
      ref.invalidate(salesProvider);
      ref.invalidate(salesSummaryProvider);
      ref.invalidate(inventoryItemsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteSale(String id, String itemId, int quantity) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteSale(id, itemId, quantity);
      // Invalidate providers to refresh data
      ref.invalidate(salesProvider);
      ref.invalidate(salesSummaryProvider);
      ref.invalidate(inventoryItemsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final salesNotifierProvider = StateNotifierProvider<SalesNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(salesServiceProvider);
  return SalesNotifier(ref, service);
});