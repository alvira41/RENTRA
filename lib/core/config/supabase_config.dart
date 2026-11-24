import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://pablxnfzlicadmjdrnec.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhYmx4bmZ6bGljYWRtamRybmVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2OTM2NzcsImV4cCI6MjEwODI2OTY3N30.noN9jfLH4vyBPWz-or178hcfY-H1Y9KAJXytT8Sn8fY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
