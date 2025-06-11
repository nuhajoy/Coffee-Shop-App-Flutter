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
