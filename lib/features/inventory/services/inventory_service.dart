import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:coffee_management/core/constants/app_constants.dart';
import 'package:coffee_management/core/supabase_client.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';

class InventoryService {
  final SupabaseClient _supabase = supabase;
  final String _tableName = AppConstants.inventoryItemsTable;
  final _uuid = const Uuid();
