import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

class AppRole {
  static const admin = 'admin';
  static const user = 'user';
  static const mitra = 'mitra';
}

/// Akses Supabase untuk autentikasi. Tidak menyimpan state.
class AuthService {
  SupabaseClient get _db => SupabaseConfig.client;

  User? get currentUser => _db.auth.currentUser;
  String? get currentUid => currentUser?.id;
  bool get isLoggedIn => _db.auth.currentSession != null;

  Future<AuthResponse> signIn({required String email, required String password}) =>
      _db.auth.signInWithPassword(email: email.trim(), password: password);

  /// Daftar sebagai user. Data profil dikirim sebagai metadata, lalu disimpan
  /// ke tabel profil lewat [saveProfileAfterSignUp] (atau trigger jika sudah ada).
  Future<AuthResponse> signUpUser({
    required String email,
    required String password,
    required String namaUser,
    String? jenisKelamin,
    String? tanggalLahir, // 'yyyy-MM-dd'
    String? alamat,
    String? noTeleponUser,
    String? noKtp,
  }) async {
    final res = await _db.auth.signUp(email: email.trim(), password: password, data: {
      'role': AppRole.user,
      'nama_user': namaUser.trim(),
    });
    final uid = res.user?.id;
    if (uid != null && res.session != null) {
      await _db.from(Db.tUser).upsert({
        Db.pkUser: uid,
        'nama_user': namaUser.trim(),
        if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
        if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir,
        if (alamat != null) 'alamat': alamat,
        if (noTeleponUser != null) 'no_telepon_user': noTeleponUser,
        if (noKtp != null && noKtp.isNotEmpty) 'no_ktp': noKtp,
      });
    }
    return res;
  }

  Future<AuthResponse> signUpMitra({
    required String email,
    required String password,
    required String namaRental,
    required String namaPemilik,
    String? alamat,
    String? noTelepon,
  }) async {
    final res = await _db.auth.signUp(email: email.trim(), password: password, data: {
      'role': AppRole.mitra,
      'nama_rental': namaRental.trim(),
    });
    final uid = res.user?.id;
    if (uid != null && res.session != null) {
      await _db.from(Db.tMitra).upsert({
        Db.pkMitra: uid,
        'nama_rental': namaRental.trim(),
        'nama_pemilik': namaPemilik.trim(),
        'email': email.trim(),
        if (alamat != null) 'alamat': alamat,
        if (noTelepon != null) 'no_telepon': noTelepon,
      });
    }
    return res;
  }

  Future<void> signOut() => _db.auth.signOut();

  /// Role akun yang login, atau null jika belum punya profil.
  Future<String?> getRole() async {
    final uid = currentUid;
    if (uid == null) return null;
    if (await _db.from(Db.tAdmin).select(Db.pkAdmin).eq(Db.pkAdmin, uid).maybeSingle() != null) {
      return AppRole.admin;
    }
    if (await _db.from(Db.tMitra).select(Db.pkMitra).eq(Db.pkMitra, uid).maybeSingle() != null) {
      return AppRole.mitra;
    }
    if (await _db.from(Db.tUser).select(Db.pkUser).eq(Db.pkUser, uid).maybeSingle() != null) {
      return AppRole.user;
    }
    return null;
  }

  (String, String) _tablePk(String role) => switch (role) {
        AppRole.admin => (Db.tAdmin, Db.pkAdmin),
        AppRole.mitra => (Db.tMitra, Db.pkMitra),
        _ => (Db.tUser, Db.pkUser),
      };

  Future<Map<String, dynamic>?> getProfile(String role) async {
    final uid = currentUid;
    if (uid == null) return null;
    final (table, pk) = _tablePk(role);
    return _db.from(table).select().eq(pk, uid).maybeSingle();
  }

  Future<void> updateProfile(String role, Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;
    final (table, pk) = _tablePk(role);
    await _db.from(table).update(data).eq(pk, uid);
  }
}