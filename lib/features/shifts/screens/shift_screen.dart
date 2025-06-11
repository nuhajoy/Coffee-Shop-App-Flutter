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
  Widget _buildAddShiftForm(AsyncValue<List<auth_models.User>> allUsersAsync) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Shift',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // User Selection
          allUsersAsync.when(
            data: (users) => DropdownButtonFormField<auth_models.User>(
              value: _selectedUser,
              decoration: const InputDecoration(
                labelText: 'Select Employee',
                border: OutlineInputBorder(),
              ),
              items: users.map((user) => DropdownMenuItem(
                value: user,
                child: Text('${user.fullName} (${user.email})'),
              )).toList(),
              onChanged: (user) {
                setState(() {
                  _selectedUser = user;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an employee';
                }
                return null;
              },
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Error loading users: $error'),
          ),

          const SizedBox(height: 16),

          // Start Date and Time
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedStartDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedStartDate = date;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(_selectedStartTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedStartTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedStartTime = time;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          // End Date and Time
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedEndDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(

                  title: const Text('End Time'),
                  subtitle: Text(_selectedEndTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedEndTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedEndTime = time;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitShift,
              child: const Text('Add Shift'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllShiftsList(AsyncValue<List<Shift>> shiftsAsync) {
    return shiftsAsync.when(
      data: (shifts) => shifts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No shifts scheduled',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return _buildShiftCard(shift, isAdmin: true);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading shifts: $error'),
      ),
    );
  }

  Widget _buildMyShiftsList(AsyncValue<List<Shift>> shiftsAsync) {
    return shiftsAsync.when(
      data: (shifts) => shifts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No shifts assigned',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Check with your manager for schedule updates',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (context, index) {
          final shift = shifts[index];
          return _buildShiftCard(shift, isAdmin: false);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error loading your shifts: $error'),
      ),
    );
  }


  Widget _buildShiftCard(Shift shift, {required bool isAdmin}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: const Border( // FIXED: Proper Border syntax
            left: BorderSide(
              width: 4,
              color: Colors.blue, // Using a default color since _getStatusColor needs to be const
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shift.employeeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          shift.employeeEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(shift.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      shift.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(shift.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(shift.startTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('h:mm a').format(shift.startTime)} - ${DateFormat('h:mm a').format(shift.endTime)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (shift.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shift.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,

                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _deleteShift(shift.id),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
      case 'in progress':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _submitShift() async {
    if (_formKey.currentState!.validate() && _selectedUser != null) {
      final startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );

      final endDateTime = DateTime(
        _selectedEndDate.year,
        _selectedEndDate.month,
        _selectedEndDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final shift = Shift(
        id: const Uuid().v4(),
        userId: _selectedUser!.id,
        employeeName: _selectedUser!.fullName,
        employeeEmail: _selectedUser!.email,
        startTime: startDateTime,
        endTime: endDateTime,
        status: 'Scheduled', // Using status from your constants
        notes: _notesController.text.trim(),
      );

      try {
        await ref.read(shiftNotifierProvider.notifier).addShift(shift);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift added successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          setState(() {
            _showAddForm = false;
            _selectedUser = null;
            _notesController.clear();
            _selectedStartDate = DateTime.now();
            _selectedStartTime = TimeOfDay.now();
            _selectedEndDate = DateTime.now();
            _selectedEndTime = TimeOfDay.now();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding shift: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteShift(String shiftId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: const Text('Are you sure you want to delete this shift?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );


    if (confirmed == true) {
      try {
        await ref.read(shiftNotifierProvider.notifier).deleteShift(shiftId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shift deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting shift: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

