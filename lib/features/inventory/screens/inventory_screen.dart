import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';
import 'package:coffee_management/features/inventory/services/inventory_service.dart';
import 'package:coffee_management/shared/widgets/bottom_navigation.dart';

// Simple providers directly in this file
final _inventoryServiceProvider = Provider<InventoryService>((ref) => InventoryService());
final _inventoryItemsProvider = StateProvider<List<InventoryItem>>((ref) => []);
final _inventoryLoadingProvider = StateProvider<bool>((ref) => false);
final _inventoryErrorProvider = StateProvider<String?>((ref) => null);
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      ref.read(_inventoryLoadingProvider.notifier).state = true;
      ref.read(_inventoryErrorProvider.notifier).state = null;

      final service = ref.read(_inventoryServiceProvider);
      final items = await service.getAllItems();

      ref.read(_inventoryItemsProvider.notifier).state = items;
      ref.read(_inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      ref.read(_inventoryLoadingProvider.notifier).state = false;
      ref.read(_inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> _addItem(InventoryItem item) async {
    try {
      ref.read(_inventoryLoadingProvider.notifier).state = true;
      ref.read(_inventoryErrorProvider.notifier).state = null;

      final service = ref.read(_inventoryServiceProvider);
      final newItem = await service.addItem(item);

      final currentItems = ref.read(_inventoryItemsProvider);
      ref.read(_inventoryItemsProvider.notifier).state = [...currentItems, newItem];

      ref.read(_inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      ref.read(_inventoryLoadingProvider.notifier).state = false;
      ref.read(_inventoryErrorProvider.notifier).state = e.toString();
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      ref.read(_inventoryLoadingProvider.notifier).state = true;
      ref.read(_inventoryErrorProvider.notifier).state = null;

      final service = ref.read(_inventoryServiceProvider);
      await service.deleteItem(id);

      final currentItems = ref.read(_inventoryItemsProvider);
      ref.read(_inventoryItemsProvider.notifier).state =
          currentItems.where((item) => item.id != id).toList();

      ref.read(_inventoryLoadingProvider.notifier).state = false;
    } catch (e) {
      ref.read(_inventoryLoadingProvider.notifier).state = false;
      ref.read(_inventoryErrorProvider.notifier).state = e.toString();
    }
  }
