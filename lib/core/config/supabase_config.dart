import 'package:supabase_flutter/supabase_flutter.dart';

/// Koneksi Supabase. Key TIDAK ditulis di kode, kirim lewat --dart-define:
/// flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxxx
class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Panggil sekali di main() sebelum runApp().
  static Future<void> init() async {
    assert(url.isNotEmpty && anonKey.isNotEmpty,
        'SUPABASE_URL / SUPABASE_ANON_KEY belum diisi via --dart-define');
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

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