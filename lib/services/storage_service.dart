import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Upload file. Menerima bytes (dari XFile.readAsBytes()) agar jalan di Android, iOS, dan web.
class StorageService {
  SupabaseClient get _db => SupabaseConfig.client;

  static const bucketKatalog = 'katalog';
  static const bucketKatalogMitra = 'katalog-mitra';
  static const bucketBukti = 'bukti-payment';
  static const bucketKtp = 'ktp';

  String _ext(String name) =>
      name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';

  String _mime(String ext) => switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        'pdf' => 'application/pdf',
        _ => 'image/jpeg',
      };

  Future<String> _upload(String bucket, String folder, String prefix,
      Uint8List bytes, String fileName) async {
    final ext = _ext(fileName);
    final path = '$folder/${prefix}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _db.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mime(ext), upsert: true),
        );
    return path;
  }

  /// Admin: foto mobil. Return URL publik (simpan ke katalog.image).
  Future<String> uploadKatalogImage(Uint8List bytes, String fileName) async {
    final path = await _upload(bucketKatalog, 'mobil', 'mobil', bytes, fileName);
    return _db.storage.from(bucketKatalog).getPublicUrl(path);
  }

  /// Mitra: foto mobil. Return URL publik (simpan ke katalog_mitra.image_mitra).
  Future<String> uploadKatalogMitraImage(String uid, Uint8List bytes, String fileName) async {
    final path = await _upload(bucketKatalogMitra, uid, 'mobil', bytes, fileName);
    return _db.storage.from(bucketKatalogMitra).getPublicUrl(path);
  }

  /// User: foto KTP. Return PATH (simpan ke users.foto_ktp). Tampilkan via signedUrl().
  Future<String> uploadKtp(String uid, Uint8List bytes, String fileName) =>
      _upload(bucketKtp, uid, 'ktp', bytes, fileName);

  /// User: bukti pembayaran. Return PATH (kirim ke create_order / set_bukti_payment).
  Future<String> uploadBuktiPayment(String uid, Uint8List bytes, String fileName) =>
      _upload(bucketBukti, uid, 'bukti', bytes, fileName);

  /// URL sementara untuk file privat (KTP, bukti payment). Default berlaku 1 jam.
  Future<String> signedUrl(String bucket, String path, {int expiresInSeconds = 3600}) =>
      _db.storage.from(bucket).createSignedUrl(path, expiresInSeconds);

  Future<void> delete(String bucket, String path) =>
      _db.storage.from(bucket).remove([path]);
}