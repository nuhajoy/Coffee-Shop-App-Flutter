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
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(_inventoryItemsProvider);
    final isLoading = ref.watch(_inventoryLoadingProvider);
    final error = ref.watch(_inventoryErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: Column(
            children: [
              // Search Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search inventory',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.95),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(items, isLoading, error),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryBrown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildContent(List<InventoryItem> items, bool isLoading, String? error) {
    if (isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
              ),
              SizedBox(height: 16),
              Text('Loading inventory...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $error', style: const TextStyle(color: AppTheme.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadItems,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No items found', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
              SizedBox(height: 8),
              Text('Add some items to get started', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    // Filter items based on search
    final filteredItems = items.where((item) {
      return item.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white.withOpacity(0.95),
          elevation: 3,
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.lightBrown.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2, color: AppTheme.primaryBrown),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.category} • \$${item.price.toStringAsFixed(2)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isLowStock
                    ? AppTheme.warning.withOpacity(0.2)
                    : AppTheme.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Qty: ${item.quantity}',
                style: TextStyle(
                  color: item.isLowStock ? AppTheme.warning : AppTheme.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () => _showDetailsDialog(item),
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(onAdd: _addItem),
    );
  }

  void _showDetailsDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => _ItemDetailsDialog(
        item: item,
        onDelete: () => _deleteItem(item.id),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(InventoryItem) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Coffee';
  final List<String> _categories = ['Coffee', 'Tea', 'Pastry', 'Equipment', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat))
                ).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => int.tryParse(value ?? '') == null ? 'Invalid' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final item = InventoryItem(
        id: '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onAdd(item);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }
}

class _ItemDetailsDialog extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onDelete;

  const _ItemDetailsDialog({
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.category, 'Category', item.category),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.attach_money, 'Price', '\$${item.price.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.inventory, 'Quantity', '${item.quantity}'),

            if (item.isLowStock) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: AppTheme.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Low stock! Consider restocking soon.',
                        style: TextStyle(color: AppTheme.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(item.description!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDelete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item deleted successfully'),
                backgroundColor: AppTheme.success,
              ),
            );
          },
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
