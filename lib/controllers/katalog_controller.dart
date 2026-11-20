import '../services/auth_service.dart';
import '../services/katalog_service.dart';
import '../services/storage_service.dart';
import 'base_controller.dart';

/// Kategori, katalog mobil, dan katalog mitra.
class KatalogController extends BaseController {
  final KatalogService _service;
  final StorageService _storage;
  final AuthService _auth;
  KatalogController({KatalogService? service, StorageService? storage, AuthService? auth})
      : _service = service ?? KatalogService(),
        _storage = storage ?? StorageService(),
        _auth = auth ?? AuthService();

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> katalog = [];
  List<Map<String, dynamic>> katalogMitra = [];

  // ---------- CATEGORY ----------
  Future<bool> loadCategories() => run(() async => categories = await _service.getCategories());

  Future<bool> addCategory(String name) {
    if (name.trim().isEmpty) return Future.value(setError('Nama kategori wajib diisi'));
    return run(() async {
      await _service.addCategory(name);
      categories = await _service.getCategories();
    });
  }

  Future<bool> updateCategory(int idCategory, String name) {
    if (name.trim().isEmpty) return Future.value(setError('Nama kategori wajib diisi'));
    return run(() async {
      await _service.updateCategory(idCategory, name);
      categories = await _service.getCategories();
    });
  }

  Future<bool> deleteCategory(int idCategory) => run(() async {
        await _service.deleteCategory(idCategory);
        categories = await _service.getCategories();
      });

  // ---------- KATALOG ----------
  /// Semua role boleh (termasuk sebelum login). Filter opsional.
  Future<bool> loadKatalog({int? idCategory, String? search}) => run(
      () async => katalog = await _service.getKatalog(idCategory: idCategory, search: search));

  /// Satu mobil untuk halaman detail.
  Future<Map<String, dynamic>?> getKatalogById(int idMobil) async {
    Map<String, dynamic>? result;
    await run(() async => result = await _service.getKatalogById(idMobil));
    return result;
  }

  /// Admin: tambah mobil. [foto] opsional; kalau ada akan diunggah dulu.
  Future<bool> addKatalog({
    required int idCategory,
    required String namaMobil,
    required num price,
    required int totalStock,
    UploadFile? foto,
  }) {
    if (namaMobil.trim().isEmpty) return Future.value(setError('Nama mobil wajib diisi'));
    if (price <= 0) return Future.value(setError('Harga harus lebih dari 0'));
    if (totalStock < 0) return Future.value(setError('Stok tidak boleh negatif'));
    return run(() async {
      final url = foto == null ? null : await _storage.uploadKatalogImage(foto.bytes, foto.name);
      await _service.addKatalog(
          idCategory: idCategory,
          namaMobil: namaMobil,
          price: price,
          totalStock: totalStock,
          image: url);
      katalog = await _service.getKatalog();
    });
  }

  /// Admin: ubah mobil. Isi hanya field yang berubah.
  Future<bool> updateKatalog(
    int idMobil, {
    int? idCategory,
    String? namaMobil,
    num? price,
    int? totalStock,
    UploadFile? fotoBaru,
  }) =>
      run(() async {
        final data = <String, dynamic>{
          if (idCategory != null) 'id_category': idCategory,
          if (namaMobil != null) 'nama_mobil': namaMobil.trim(),
          if (price != null) 'price': price,
          if (totalStock != null) 'total_stock': totalStock,
          if (fotoBaru != null)
            'image': await _storage.uploadKatalogImage(fotoBaru.bytes, fotoBaru.name),
        };
        if (data.isNotEmpty) await _service.updateKatalog(idMobil, data);
        katalog = await _service.getKatalog();
      });

  Future<bool> deleteKatalog(int idMobil) => run(() async {
        await _service.deleteKatalog(idMobil);
        katalog = await _service.getKatalog();
      });

  // ---------- KATALOG MITRA ----------
  /// Admin: kosongkan [idMitra] untuk semua mitra. Mitra: otomatis hanya miliknya.
  Future<bool> loadKatalogMitra({String? idMitra}) =>
      run(() async => katalogMitra = await _service.getKatalogMitra(idMitra: idMitra));

  /// Mitra menambah mobilnya sendiri.
  Future<bool> addKatalogMitra({
    required String namaMobilMitra,
    required int totalStockMitra,
    int? idCategoryMitra,
    UploadFile? foto,
  }) {
    if (namaMobilMitra.trim().isEmpty) return Future.value(setError('Nama mobil wajib diisi'));
    return run(() async {
      final uid = _auth.currentUid!;
      final url = foto == null
          ? null
          : await _storage.uploadKatalogMitraImage(uid, foto.bytes, foto.name);
      await _service.addKatalogMitra(
          idMitra: uid,
          namaMobilMitra: namaMobilMitra,
          totalStockMitra: totalStockMitra,
          idCategoryMitra: idCategoryMitra,
          imageMitra: url);
      katalogMitra = await _service.getKatalogMitra(idMitra: uid);
    });
  }

  Future<bool> updateKatalogMitra(
    int idMobilMitra, {
    String? namaMobilMitra,
    int? totalStockMitra,
    int? idCategoryMitra,
    UploadFile? fotoBaru,
  }) =>
      run(() async {
        final uid = _auth.currentUid!;
        final data = <String, dynamic>{
          if (namaMobilMitra != null) 'nama_mobil_mitra': namaMobilMitra.trim(),
          if (totalStockMitra != null) 'total_stock_mitra': totalStockMitra,
          if (idCategoryMitra != null) 'id_category_mitra': idCategoryMitra,
          if (fotoBaru != null)
            'image_mitra':
                await _storage.uploadKatalogMitraImage(uid, fotoBaru.bytes, fotoBaru.name),
        };
        if (data.isNotEmpty) await _service.updateKatalogMitra(idMobilMitra, data);
        katalogMitra = await _service.getKatalogMitra(idMitra: uid);
      });

  Future<bool> deleteKatalogMitra(int idMobilMitra) => run(() async {
        await _service.deleteKatalogMitra(idMobilMitra);
        katalogMitra = await _service.getKatalogMitra(idMitra: _auth.currentUid);
      });
}