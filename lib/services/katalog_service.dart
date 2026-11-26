import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

typedef Row = Map<String, dynamic>;

/// Kategori, katalog mobil, dan katalog mitra.
class KatalogService {
  SupabaseClient get _db => SupabaseConfig.client;

  List<Row> _rows(dynamic res) => List<Row>.from(res as List);

  // ==========================================
  // CATEGORY
  // ==========================================

  /// Mengambil seluruh kategori: matic dan manual.
  Future<List<Row>> getCategories() async {
    final res = await _db
        .from('category')
        .select()
        .order('nama');

    return _rows(res);
  }

  /// Menambahkan kategori baru.
  Future<Row> addCategory(String name) async {
    return await _db
        .from('category')
        .insert({
          'nama': name.trim(),
        })
        .select()
        .single();
  }

  /// Mengubah nama kategori.
  Future<void> updateCategory(
    int idCategory,
    String name,
  ) async {
    await _db
        .from('category')
        .update({
          'nama': name.trim(),
        })
        .eq('id_category', idCategory);
  }

  /// Menghapus kategori.
  Future<void> deleteCategory(int idCategory) async {
    await _db
        .from('category')
        .delete()
        .eq('id_category', idCategory);
  }

  // ==========================================
  // KATALOG MOBIL (ADMIN)
  // ==========================================

  /// Mengambil katalog mobil beserta nama kategorinya.
  Future<List<Row>> getKatalog({
    int? idCategory,
    String? search,
  }) async {
    var q = _db
        .from('katalog')
        .select('*, category(nama)');

    if (idCategory != null) {
      q = q.eq('id_category', idCategory);
    }

    if (search != null && search.trim().isNotEmpty) {
      q = q.ilike(
        'nama_mobil',
        '%${search.trim()}%',
      );
    }

    final res = await q.order('nama_mobil');

    return _rows(res);
  }

  /// Mengambil detail katalog berdasarkan ID mobil.
  Future<Row?> getKatalogById(int idMobil) async {
    return await _db
        .from('katalog')
        .select('*, category(nama)')
        .eq('id_mobil', idMobil)
        .maybeSingle();
  }

  /// Menambahkan mobil ke katalog admin.
  Future<Row> addKatalog({
    required int idCategory,
    required String namaMobil,
    required num price,
    required int totalStock,
    String? image,
  }) async {
    return await _db
        .from('katalog')
        .insert({
          'id_category': idCategory,
          'nama_mobil': namaMobil.trim(),
          'price': price,
          'total_stock': totalStock,
          'image': image,
        })
        .select()
        .single();
  }

  /// Memperbarui data katalog mobil.
  Future<void> updateKatalog(
    int idMobil,
    Row data,
  ) async {
    await _db
        .from('katalog')
        .update(data)
        .eq('id_mobil', idMobil);
  }

  /// Menghapus mobil dari katalog.
  Future<void> deleteKatalog(int idMobil) async {
    await _db
        .from('katalog')
        .delete()
        .eq('id_mobil', idMobil);
  }

  // ==========================================
  // KATALOG MITRA
  // ==========================================

  /// Mengambil katalog milik mitra beserta kategorinya.
  ///
  /// idMitra null = semua mitra (admin).
  /// Mitra hanya melihat data miliknya sesuai RLS.
  Future<List<Row>> getKatalogMitra({
    String? idMitra,
  }) async {
    var q = _db
        .from('katalog_mitra')
        .select('*, category(nama)');

    if (idMitra != null) {
      q = q.eq('id_mitra', idMitra);
    }

    final res = await q.order('nama_mobil_mitra');

    return _rows(res);
  }

  /// Menambahkan mobil ke katalog mitra.
  Future<Row> addKatalogMitra({
    required String idMitra,
    required String namaMobilMitra,
    required int totalStockMitra,
    int? idCategoryMitra,
    String? imageMitra,
  }) async {
    return await _db
        .from('katalog_mitra')
        .insert({
          'id_mitra': idMitra,
          'id_category_mitra': idCategoryMitra,
          'nama_mobil_mitra': namaMobilMitra.trim(),
          'total_stock_mitra': totalStockMitra,
          'image_mitra': imageMitra,
        })
        .select()
        .single();
  }

  /// Memperbarui katalog mitra.
  Future<void> updateKatalogMitra(
    int idMobilMitra,
    Row data,
  ) async {
    await _db
        .from('katalog_mitra')
        .update(data)
        .eq('id_mobil_mitra', idMobilMitra);
  }

  /// Menghapus katalog mobil mitra.
  Future<void> deleteKatalogMitra(int idMobilMitra) async {
    await _db
        .from('katalog_mitra')
        .delete()
        .eq('id_mobil_mitra', idMobilMitra);
  }
}
