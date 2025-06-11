import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coffee_management/core/theme.dart';
import 'package:coffee_management/core/router.dart'; // This imports your router
import 'package:coffee_management/core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // REMOVE THIS LINE: var appRouter;

    return MaterialApp.router(
      title: 'Coffee Management',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter, // This uses the imported appRouter from core/router.dart
      debugShowCheckedModeBanner: false,
    );
  }
}