import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://joaibmeegtvzoloekrzd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpvYWlibWVlZ3R2em9sb2VrcnpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMTkzNjEsImV4cCI6MjA2Nzg5NTM2MX0.UjSrEmVVVYCWqf9tpO_lGmPFzjDVsEoLJYdZtYt5TSM';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
