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