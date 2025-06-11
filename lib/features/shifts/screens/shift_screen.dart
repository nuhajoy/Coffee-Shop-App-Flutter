import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/shared/widgets/bottom_navigation.dart';
import 'package:coffee_management/features/shifts/providers/shift_provider.dart';
import 'package:coffee_management/features/shifts/models/shift_model.dart';
import 'package:coffee_management/features/auth/models/user_model.dart' as auth_models;
import 'package:coffee_management/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ShiftScreen extends ConsumerStatefulWidget {
  const ShiftScreen({super.key});

  @override
  ConsumerState<ShiftScreen> createState() => _ShiftScreenState();
}
class _ShiftScreenState extends ConsumerState<ShiftScreen> {
  bool _showAddForm = false;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  auth_models.User? _selectedUser;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(myShiftsProvider);
    final allShiftsAsync = ref.watch(shiftsProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final allUsersAsync = ref.watch(shiftAllUsersProvider); // FIXED: Using renamed provider
    final shiftNotifier = ref.watch(shiftNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shifts'),
        actions: [
          isAdminAsync.when(
            data: (isAdmin) => isAdmin
                ? IconButton(
              icon: Icon(_showAddForm ? Icons.close : Icons.add),
              onPressed: () {
                setState(() {
                  _showAddForm = !_showAddForm;
                });
              },
            )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Shift Form (Admin Only)
          if (_showAddForm)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightBrown.withOpacity(0.1),
                border: const Border( // FIXED: Proper Border syntax
                  left: BorderSide(
                    width: 4,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
              child: _buildAddShiftForm(allUsersAsync),
            ),

          // Shifts List
          Expanded(
            child: isAdminAsync.when(
              data: (isAdmin) => isAdmin
                  ? _buildAllShiftsList(allShiftsAsync)
                  : _buildMyShiftsList(shiftsAsync),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

