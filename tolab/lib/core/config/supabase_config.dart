import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://joaibmeegtvzoloekrzd.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_-gavwCQADzeJz9QNrtFZuQ_4Jdo4zYH';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
