import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Koneksi Supabase. Nilai diambil dari file `assets/config/supabase.json`
/// atau bisa ditimpa lewat --dart-define saat diperlukan.
class SupabaseConfig {
  static const String _configAsset = 'assets/config/supabase.json';

  static String url = const String.fromEnvironment('SUPABASE_URL');
  static String anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Panggil sekali di main() sebelum runApp().
  static Future<void> init() async {
    if (_isEmpty(url) || _isEmpty(anonKey)) {
      final raw = await rootBundle.loadString(_configAsset);
      final config = jsonDecode(raw) as Map<String, dynamic>;
      url = config['SUPABASE_URL']?.toString() ?? url;
      anonKey = config['SUPABASE_ANON_KEY']?.toString() ?? anonKey;
    }

    if (_isEmpty(url) ||
        _isEmpty(anonKey) ||
        url.contains('YOUR_PROJECT') ||
        anonKey.contains('YOUR_ANON_KEY')) {
      throw StateError(
        'SUPABASE_URL / SUPABASE_ANON_KEY belum diisi. Ubah file assets/config/supabase.json',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static bool _isEmpty(String value) => value.trim().isEmpty;

  static SupabaseClient get client => Supabase.instance.client;
}

/// Nama tabel & kolom kunci akun. CEK di Supabase > Table Editor,
/// lalu samakan di sini (hanya perlu diubah di file ini).
class Db {
  static const tAdmin = 'admin';
  static const pkAdmin = 'id_admin';

  static const tUser = 'app_user'; // ganti ke 'users' jika tabelmu bernama users
  static const pkUser = 'id_user'; // ganti ke 'id' jika kolom kuncinya id

  static const tMitra = 'mitra';
  static const pkMitra = 'id_mitra';
}
