
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class AppRole {
  static const admin = 'admin';
  static const user = 'user';
  static const mitra = 'mitra';
}

/// Akses Supabase untuk autentikasi.
/// Tidak menyimpan state login secara manual.
class AuthService {
  SupabaseClient get _db => SupabaseConfig.client;

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  User? get currentUser => _db.auth.currentUser;

  String? get currentUid => currentUser?.id;

  bool get isLoggedIn => _db.auth.currentSession != null;

  /// Login menggunakan email dan password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _db.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Logout akun.
  Future<void> signOut() async {
    await _db.auth.signOut();
  }

  // ==========================================
  // REGISTER USER
  // ==========================================

  Future<AuthResponse> signUpUser({
    required String email,
    required String password,
    required String namaUser,
    String? jenisKelamin,
    String? tanggalLahir,
    String? alamat,
    String? noTeleponUser,
    String? noKtp,
  }) async {
    final res = await _db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'role': AppRole.user,
        'nama_user': namaUser.trim(),
      },
    );

    final uid = res.user?.id;

    if (uid != null && res.session != null) {
      await _db.from(Db.tUser).upsert({
        Db.pkUser: uid,
        'nama_user': namaUser.trim(),
        'jenis_kelamin':? jenisKelamin,
        'tanggal_lahir':? tanggalLahir,
        'alamat':? alamat,
        'no_telepon_user':? noTeleponUser,
        if (noKtp != null && noKtp.isNotEmpty) 'no_ktp': noKtp,
      });
    }

    return res;
  }

  // ==========================================
  // REGISTER MITRA
  // ==========================================

  Future<AuthResponse> signUpMitra({
    required String email,
    required String password,
    required String namaRental,
    required String namaPemilik,
    String? alamat,
    String? noTelepon,
  }) async {
    final res = await _db.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'role': AppRole.mitra,
        'nama_rental': namaRental.trim(),
      },
    );

    final uid = res.user?.id;

    if (uid != null && res.session != null) {
      await _db.from(Db.tMitra).upsert({
        Db.pkMitra: uid,
        'nama_rental': namaRental.trim(),
        'nama_pemilik': namaPemilik.trim(),
        'email': email.trim(),
        'alamat':? alamat,
        'no_telepon':? noTelepon,
      });
    }

    return res;
  }

  // ==========================================
  // GET ROLE
  // ==========================================

  /// Mengambil role berdasarkan UUID Supabase Auth.
  Future<String?> getRole() async {
    final uid = currentUid;

    if (uid == null) return null;

    // ADMIN:
    // UUID Supabase Auth dicocokkan dengan auth_user_id,
    // BUKAN id_admin yang bertipe BIGINT.

    final admin = await _db
        .from(Db.tAdmin)
        .select('auth_user_id')
        .eq('auth_user_id', uid)
        .maybeSingle();

    if (admin != null) {
      return AppRole.admin;
    }

    // MITRA:
    // Menggunakan primary key sesuai konfigurasi Db.
    final mitra = await _db
        .from(Db.tMitra)
        .select(Db.pkMitra)
        .eq(Db.pkMitra, uid)
        .maybeSingle();

    if (mitra != null) {
      return AppRole.mitra;
    }

    // USER:
    // Menggunakan primary key sesuai konfigurasi Db.
    final user = await _db
        .from(Db.tUser)
        .select(Db.pkUser)
        .eq(Db.pkUser, uid)
        .maybeSingle();

    if (user != null) {
      return AppRole.user;
    }

    return null;
  }

  // ==========================================
  // TABLE AND PRIMARY KEY
  // ==========================================

  /// Menentukan tabel dan kolom penghubung berdasarkan role.
  (String, String) _tablePk(String role) {
    switch (role) {
      case AppRole.admin:
        return (Db.tAdmin, 'auth_user_id');

      case AppRole.mitra:
        return (Db.tMitra, Db.pkMitra);

      case AppRole.user:
        return (Db.tUser, Db.pkUser);

      default:
        throw Exception('Role tidak dikenali: $role');
    }
  }

  // ==========================================
  // GET PROFILE
  // ==========================================

  Future<Map<String, dynamic>?> getProfile(String role) async {
    final uid = currentUid;

    if (uid == null) return null;

    final (table, pk) = _tablePk(role);

    final profile = await _db
        .from(table)
        .select()
        .eq(pk, uid)
        .maybeSingle();

    return profile;
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================

  Future<void> updateProfile(
    String role,
    Map<String, dynamic> data,
  ) async {
    final uid = currentUid;

    if (uid == null) {
      throw Exception('User belum login');
    }

    final (table, pk) = _tablePk(role);

    await _db
        .from(table)
        .update(data)
        .eq(pk, uid);
  }
}
