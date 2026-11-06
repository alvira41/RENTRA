import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/app_exception.dart';

export '../core/utils/app_exception.dart';

/// Gambar yang dipilih user (dari image_picker: bytes = await xfile.readAsBytes(), name = xfile.name).
class UploadFile {
  final Uint8List bytes;
  final String name;
  UploadFile(this.bytes, this.name);
}

/// Dasar semua controller: isLoading, errorMessage, dan pembungkus try/catch.
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Jalankan aksi dengan loading + penanganan error. Return true jika sukses.
  @protected
  Future<bool> run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      return setError(e.message);
    } on AuthException catch (e) {
      return setError(_translate(e.message));
    } on PostgrestException catch (e) {
      return setError(_translate(e.message));
    } on StorageException catch (e) {
      return setError('Gagal mengunggah file: ${e.message}');
    } catch (e) {
      return setError('Terjadi kesalahan: $e');
    }
  }

  @protected
  bool setError(String msg) {
    _isLoading = false;
    _errorMessage = msg;
    notifyListeners();
    return false;
  }

  String _translate(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login')) return 'Email atau password salah';
    if (m.contains('already registered') || m.contains('already been registered')) {
      return 'Email sudah terdaftar';
    }
    if (m.contains('email not confirmed')) return 'Email belum dikonfirmasi, cek inbox kamu';
    if (m.contains('rate limit')) return 'Terlalu banyak percobaan, tunggu sebentar';
    if (m.contains('users_no_ktp_key') || m.contains('no_ktp')) return 'No KTP sudah terdaftar';
    if (m.contains('category_name_key')) return 'Nama kategori sudah ada';
    if (m.contains('foreign key')) return 'Data masih dipakai data lain, tidak bisa dihapus';
    if (m.contains('row-level security') || m.contains('permission denied')) {
      return 'Kamu tidak punya akses untuk aksi ini';
    }
    if (m.contains('failed host lookup') || m.contains('socketexception')) {
      return 'Tidak ada koneksi internet';
    }
    return msg; // pesan dari fungsi database sudah berbahasa Indonesia
  }
}