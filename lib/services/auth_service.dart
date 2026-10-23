
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  User? get currentAuthUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // REGISTRASI PELANGGAN
  Future<AuthResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    return _register(
      email: email,
      password: password,
      role: 'user',
      metadata: {
        'nama_user': name,
        'no_telepon_user': phone,
      },
    );
  }

  // REGISTRASI MITRA
  Future<AuthResponse> registerMitra({
    required String ownerName,
    required String rentalName,
    required String address,
    required String phone,
    required String email,
    required String password,
  }) async {
    return _register(
      email: email,
      password: password,
      role: 'mitra',
      metadata: {
        'nama_pemilik': ownerName,
        'nama_rental': rentalName,
        'alamat': address,
        'no_telepon': phone,
      },
    );
  }

  Future<AuthResponse> _register({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> metadata,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (password.length < 8) {
      throw Exception('Password minimal 8 karakter.');
    }

    if (role != 'user' && role != 'mitra') {
      throw Exception('Role registrasi tidak valid.');
    }

    return _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        ...metadata,
        'requested_role': role,
      },
    );
  }

  // LOGIN
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final authUser = response.user;

    if (authUser == null) {
      throw Exception('Login gagal. Pengguna tidak ditemukan.');
    }

    return getMyProfile();
  }

  // AMBIL PROFIL DAN TENTUKAN ROLE DARI TABEL DATABASE
  Future<AppUser> getMyProfile() async {
    final authUser = _client.auth.currentUser;

    if (authUser == null) {
      throw Exception('Silakan login terlebih dahulu.');
    }

    final userId = authUser.id;
    final email = authUser.email ?? '';

    final admin = await _client
        .from('admin')
        .select('id_admin, nama_admin')
        .eq('auth_user_id', userId)
        .maybeSingle();

    if (admin != null) {
      return AppUser(
        id: userId,
        email: email,
        role: 'admin',
        profileId: (admin['id_admin'] as num).toInt(),
        name: admin['nama_admin'] as String? ?? '',
      );
    }

    final mitra = await _client
        .from('mitra')
        .select('id_mitra, nama_pemilik, nama_rental')
        .eq('auth_user_id', userId)
        .maybeSingle();

    if (mitra != null) {
      return AppUser(
        id: userId,
        email: email,
        role: 'mitra',
        profileId: (mitra['id_mitra'] as num).toInt(),
        name: mitra['nama_rental'] as String? ??
            mitra['nama_pemilik'] as String? ??
            '',
      );
    }

    final user = await _client
        .from('users')
        .select('id_user, nama_user')
        .eq('auth_user_id', userId)
        .maybeSingle();

    if (user != null) {
      return AppUser(
        id: userId,
        email: email,
        role: 'user',
        profileId: (user['id_user'] as num).toInt(),
        name: user['nama_user'] as String? ?? '',
      );
    }

    throw Exception(
      'Akun berhasil login, tetapi profil belum tersedia. '
      'Selesaikan pembuatan profil atau hubungi admin.',
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // CEK SESI
  Future<AppUser?> getCurrentAccount() async {
    if (_client.auth.currentSession == null) {
      return null;
    }

    try {
      return await getMyProfile();
    } on AuthException {
      rethrow;
    }
  }
}
