import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'base_controller.dart';

/// Login, register, sesi, dan profil. Dipakai semua role.
class AuthController extends BaseController {
  final AuthService _service;
  final StorageService _storage;
  AuthController({AuthService? service, StorageService? storage})
      : _service = service ?? AuthService(),
        _storage = storage ?? StorageService();

  String? _role;
  Map<String, dynamic>? _profile;

  /// 'admin' | 'user' | 'mitra' | null (belum login)
  String? get role => _role;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoggedIn => _service.isLoggedIn && _role != null;
  bool get isAdmin => _role == AppRole.admin;
  bool get isUser => _role == AppRole.user;
  bool get isMitra => _role == AppRole.mitra;
  String? get uid => _service.currentUid;

  Future<void> _loadRole() async {
    final role = await _service.getRole();
    if (role == null) {
      await _service.signOut();
      throw AppException('Akun belum terdaftar sebagai admin, mitra, atau user');
    }
    _role = role;
    _profile = await _service.getProfile(role);
  }

  /// Login semua role. Setelah true, arahkan halaman berdasarkan [role].
  Future<bool> login(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      return Future.value(setError('Email dan password wajib diisi'));
    }
    return run(() async {
      await _service.signIn(email: email, password: password);
      await _loadRole();
    });
  }

  /// Panggil di splash: pulihkan sesi yang tersimpan. true = sudah login.
  Future<bool> restoreSession() async {
    if (!_service.isLoggedIn) return false;
    return run(_loadRole);
  }

  /// Register user. Jika konfirmasi email MATI di Supabase, user langsung login
  /// ([isLoggedIn] true). Jika AKTIF, minta user cek email lalu login manual.
  Future<bool> registerUser({
    required String email,
    required String password,
    required String namaUser,
    String? jenisKelamin,
    String? tanggalLahir, // 'yyyy-MM-dd'
    String? alamat,
    String? noTeleponUser,
    String? noKtp,
  }) {
    if (namaUser.trim().isEmpty) return Future.value(setError('Nama wajib diisi'));
    if (password.length < 6) return Future.value(setError('Password minimal 6 karakter'));
    return run(() async {
      await _service.signUpUser(
        email: email,
        password: password,
        namaUser: namaUser,
        jenisKelamin: jenisKelamin,
        tanggalLahir: tanggalLahir,
        alamat: alamat,
        noTeleponUser: noTeleponUser,
        noKtp: noKtp,
      );
      if (_service.isLoggedIn) await _loadRole();
    });
  }

  Future<bool> registerMitra({
    required String email,
    required String password,
    required String namaRental,
    required String namaPemilik,
    String? alamat,
    String? noTelepon,
  }) {
    if (namaRental.trim().isEmpty || namaPemilik.trim().isEmpty) {
      return Future.value(setError('Nama rental dan nama pemilik wajib diisi'));
    }
    if (password.length < 6) return Future.value(setError('Password minimal 6 karakter'));
    return run(() async {
      await _service.signUpMitra(
        email: email,
        password: password,
        namaRental: namaRental,
        namaPemilik: namaPemilik,
        alamat: alamat,
        noTelepon: noTelepon,
      );
      if (_service.isLoggedIn) await _loadRole();
    });
  }

  /// Ubah profil sendiri. Key sesuai kolom tabel, mis. {'nama_user': 'Budi', 'alamat': '...'}.
  Future<bool> updateProfile(Map<String, dynamic> data) => run(() async {
        await _service.updateProfile(_role!, data);
        _profile = await _service.getProfile(_role!);
      });

  /// User: unggah foto KTP lalu simpan path-nya ke profil.
  Future<bool> uploadKtp(UploadFile file) => run(() async {
        final path = await _storage.uploadKtp(uid!, file.bytes, file.name);
        await _service.updateProfile(AppRole.user, {'foto_ktp': path});
        _profile = await _service.getProfile(AppRole.user);
      });

  /// URL sementara untuk menampilkan foto KTP (null jika belum ada).
  Future<String?> ktpUrl([String? path]) async {
    final p = path ?? _profile?['foto_ktp'] as String?;
    if (p == null || p.isEmpty) return null;
    return _storage.signedUrl(StorageService.bucketKtp, p);
  }

  Future<void> logout() async {
    await _service.signOut();
    _role = null;
    _profile = null;
    clearError();
  }
}