import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;

  SupabaseService._internal();

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseClient get client => Supabase.instance.client;
}

// Global getter for easy access
SupabaseClient get supabase => SupabaseService.instance.client;
