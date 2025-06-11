import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/features/sales/models/sales_model.dart';
import 'package:coffee_management/features/inventory/models/inventory_model.dart';
import 'package:coffee_management/features/sales/providers/sales_provider.dart';
import 'package:coffee_management/shared/widgets/bottom_navigation.dart';
import 'package:intl/intl.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  String? _currentUserName;
  final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
  }

  Future<void> _loadCurrentUserName() async {
    try {
      final service = ref.read(salesServiceProvider);
      final name = await service.currentUserName;
      if (mounted) {
        setState(() {
          _currentUserName = name;
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      if (mounted) {
        setState(() {
          _currentUserName = 'An';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);
    final summaryAsync = ref.watch(salesSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(salesProvider);
              ref.invalidate(salesSummaryProvider);
              _loadCurrentUserName();
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2340&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Text(
                      'Sales Management - ${_currentUserName ?? 'Loading...'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBrown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sales Summary Card
                  summaryAsync.when(
                    data: (summary) => _buildSalesSummaryCard(summary),
                    loading: () => Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                        ),
                      ),
                    ),
                    error: (error, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Error loading summary: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButton(
                    'View Sales History',
                    Icons.history,
                        () => _showSalesHistory(context, salesAsync),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    'Add New Sale',
                    Icons.add_shopping_cart,
                        () => _showAddSaleDialog(context),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    'Delete Sale',
                    Icons.delete,
                        () => _showDeleteSaleDialog(context, salesAsync),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildSalesSummaryCard(Map<String, dynamic> summary) {
    return Card(
      elevation: 4,
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Revenue:'),
                Text(
                  currencyFormat.format(summary['totalRevenue']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items Sold:'),
                Text(
                  '${summary['totalItemsSold']} items',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBrown,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSalesHistory(BuildContext context, AsyncValue<List<Sale>> salesAsync) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text('Sales History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: salesAsync.when(
            data: (sales) => _buildSalesList(sales),
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrown),
                  ),
                  SizedBox(height: 16),
                  Text('Loading sales...'),
                ],
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                    ),
                    onPressed: () => ref.invalidate(salesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(List<Sale> sales) {
    if (sales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('No sales found'),
            SizedBox(height: 8),
            Text('Add a new sale to get started'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (_, i) {
        final sale = sales[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white.withOpacity(0.95),
          child: ListTile(
            leading: const Icon(Icons.receipt, color: AppTheme.primaryBrown),
            title: Text(sale.itemName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${sale.quantity}'),
                Text('Unit Price: ${currencyFormat.format(sale.unitPrice)}'),
                Text('Total: ${currencyFormat.format(sale.totalAmount)}'),
                if (sale.customerName != null) Text('Customer: ${sale.customerName}'),
                Text('Date: ${DateFormat('MMM dd, yyyy hh:mm a').format(sale.createdAt)}'),
              ],
            ),
            trailing: Text(
              currencyFormat.format(sale.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryBrown,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddSaleDialog(BuildContext context) {
    final inventoryItemsAsync = ref.watch(inventoryItemsProvider);

    inventoryItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No inventory items available')),
          );
          return;
        }

        InventoryItem? selectedItem = items.first;
        int saleQuantity = 1;
        final customerNameController = TextEditingController();

        showDialog(
          context: context,
          builder: (_) => StatefulBuilder(
            builder: (ctx, setState) {
              double totalAmount = selectedItem!.price * saleQuantity;

              return AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.95),
                title: const Text('Add New Sale'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Item selection dropdown
                      DropdownButtonFormField<InventoryItem>(
                        value: selectedItem,
                        decoration: const InputDecoration(labelText: 'Select Item'),
                        items: items.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text('${item.name} - ${currencyFormat.format(item.price)} (${item.quantity} in stock)'),
                        )).toList(),
                        onChanged: (item) {
                          if (item != null) {
                            setState(() {
                              selectedItem = item;
                              // Reset quantity if it's more than available stock
                              if (saleQuantity > item.quantity) {
                                saleQuantity = item.quantity > 0 ? 1 : 0;
                              }
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Quantity selector
                      Row(
                        children: [
                          const Text('Quantity:'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: saleQuantity > 1
                                ? () => setState(() => saleQuantity--)
                                : null,
                          ),
                          Text(
                            '$saleQuantity',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: saleQuantity < selectedItem!.quantity
                                ? () => setState(() => saleQuantity++)
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price and total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Unit Price:'),
                          Text(
                            currencyFormat.format(selectedItem!.price),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Text(
                            currencyFormat.format(totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Customer name
                      TextField(
                        controller: customerNameController,
                        decoration: const InputDecoration(labelText: 'Customer Name (Optional)'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                    ),
                    onPressed: selectedItem!.quantity < 1 || saleQuantity < 1 ? null : () async {
                      final newSale = Sale(
                        id: '', // Will be generated by database
                        itemId: selectedItem!.id,
                        itemName: selectedItem!.name,
                        quantity: saleQuantity,
                        unitPrice: selectedItem!.price,
                        totalAmount: totalAmount,
                        customerName: customerNameController.text.isEmpty
                            ? null
                            : customerNameController.text,
                        createdAt: DateTime.now(),
                      );

                      try {
                        await ref.read(salesNotifierProvider.notifier).addSale(newSale);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sale added successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add sale: $e')),
                        );
                      }
                    },
                    child: const Text('Add Sale'),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading inventory items: $error')),
      ),
    );
  }

  void _showDeleteSaleDialog(BuildContext context, AsyncValue<List<Sale>> salesAsync) {
    salesAsync.whenData((sales) {
      if (sales.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No sales available to delete')),
        );
        return;
      }

      Sale? selectedSale = sales.first;

      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              title: const Text('Delete Sale'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<Sale>(
                    value: selectedSale,
                    isExpanded: true,
                    items: sales
                        .map((sale) => DropdownMenuItem(
                      value: sale,
                      child: Text(
                        '${sale.itemName} - ${currencyFormat.format(sale.totalAmount)} (${DateFormat('MMM dd').format(sale.createdAt)})',
                      ),
                    ))
                        .toList(),
                    onChanged: (sale) {
                      if (sale != null) {
                        selectedSale = sale;
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to delete this sale?\nThis will return ${selectedSale?.quantity} items to inventory.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (selectedSale == null) return;

                    try {
                      await ref.read(salesNotifierProvider.notifier)
                          .deleteSale(selectedSale!.id, selectedSale!.itemId, selectedSale!.quantity);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sale deleted successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete sale: $e')),
                      );
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}