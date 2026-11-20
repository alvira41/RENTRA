import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

typedef Row = Map<String, dynamic>;

/// Kategori, katalog mobil, dan katalog mitra.
class KatalogService {
  SupabaseClient get _db => SupabaseConfig.client;

  List<Row> _rows(dynamic res) => List<Row>.from(res as List);

  // ---------- CATEGORY ----------
  Future<List<Row>> getCategories() async =>
      _rows(await _db.from('category').select().order('name'));

  Future<Row> addCategory(String name) async =>
      await _db.from('category').insert({'name': name.trim()}).select().single();

  Future<void> updateCategory(int idCategory, String name) async =>
      await _db.from('category').update({'name': name.trim()}).eq('id_category', idCategory);

  Future<void> deleteCategory(int idCategory) async =>
      await _db.from('category').delete().eq('id_category', idCategory);

  // ---------- KATALOG (milik rental / admin) ----------
  /// Hasil: {id_mobil, id_category, nama_mobil, price, image, total_stock, category: {name}}
  Future<List<Row>> getKatalog({int? idCategory, String? search}) async {
    var q = _db.from('katalog').select('*, category(name)');
    if (idCategory != null) q = q.eq('id_category', idCategory);
    if (search != null && search.trim().isNotEmpty) {
      q = q.ilike('nama_mobil', '%${search.trim()}%');
    }
    return _rows(await q.order('nama_mobil'));
  }

  Future<Row?> getKatalogById(int idMobil) async => await _db
      .from('katalog')
      .select('*, category(name)')
      .eq('id_mobil', idMobil)
      .maybeSingle();

  Future<Row> addKatalog({
    required int idCategory,
    required String namaMobil,
    required num price,
    required int totalStock,
    String? image,
  }) async =>
      await _db.from('katalog').insert({
        'id_category': idCategory,
        'nama_mobil': namaMobil.trim(),
        'price': price,
        'total_stock': totalStock,
        'image': image,
      }).select().single();

  Future<void> updateKatalog(int idMobil, Row data) async =>
      await _db.from('katalog').update(data).eq('id_mobil', idMobil);

  Future<void> deleteKatalog(int idMobil) async =>
      await _db.from('katalog').delete().eq('id_mobil', idMobil);

  // ---------- KATALOG MITRA ----------
  /// idMitra null = semua mitra (admin). Mitra otomatis hanya melihat miliknya (RLS).
  /// Hasil: {..., category: {name}}
  Future<List<Row>> getKatalogMitra({String? idMitra}) async {
    var q = _db.from('katalog_mitra').select('*, category(name)');
    if (idMitra != null) q = q.eq('id_mitra', idMitra);
    return _rows(await q.order('nama_mobil_mitra'));
  }

  Future<Row> addKatalogMitra({
    required String idMitra,
    required String namaMobilMitra,
    required int totalStockMitra,
    int? idCategoryMitra,
    String? imageMitra,
  }) async =>
      await _db.from('katalog_mitra').insert({
        'id_mitra': idMitra,
        'id_category_mitra': idCategoryMitra,
        'nama_mobil_mitra': namaMobilMitra.trim(),
        'total_stock_mitra': totalStockMitra,
        'image_mitra': imageMitra,
      }).select().single();

  Future<void> updateKatalogMitra(int idMobilMitra, Row data) async =>
      await _db.from('katalog_mitra').update(data).eq('id_mobil_mitra', idMobilMitra);

  Future<void> deleteKatalogMitra(int idMobilMitra) async =>
      await _db.from('katalog_mitra').delete().eq('id_mobil_mitra', idMobilMitra);
}