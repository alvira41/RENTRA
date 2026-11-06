import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/utils/app_exception.dart';

typedef Row = Map<String, dynamic>;

/// Supply: admin mengajukan ke mitra, mitra merespons.
class SupplyService {
  SupabaseClient get _db => SupabaseConfig.client;

  List<Row> _rows(dynamic res) => List<Row>.from(res as List);

  static final String _select = '*, ${Db.tMitra}(nama_rental, nama_pemilik, no_telepon)';

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw AppException('Silakan login terlebih dahulu');
    return id;
  }

  /// Admin: daftar mitra untuk dropdown.
  Future<List<Row>> getMitraList() async =>
      _rows(await _db.from(Db.tMitra).select().order('nama_rental'));

  /// Admin: semua supply. Mitra: hanya milik sendiri (lewat [idMitra]).
  Future<List<Row>> getSupplies({String? status, String? idMitra}) async {
    var q = _db.from('supply').select(_select);
    if (status != null) q = q.eq('status', status);
    if (idMitra != null) q = q.eq('id_mitra', idMitra);
    return _rows(await q.order('id_supply', ascending: false));
  }

  Future<Row> createSupply({
    required String idMitra,
    required String tanggalSupply, // 'yyyy-MM-dd'
    String? tanggalKembali,
    int? idOrder,
  }) async =>
      await _db.from('supply').insert({
        'id_admin': _uid,
        'id_mitra': idMitra,
        'id_order': idOrder,
        'tanggal_supply': tanggalSupply,
        'tanggal_kembali': tanggalKembali,
        'status': 'pending',
      }).select(_select).single();

  Future<void> updateSupply(int idSupply, Row data) async =>
      await _db.from('supply').update(data).eq('id_supply', idSupply);

  Future<void> deleteSupply(int idSupply) async =>
      await _db.from('supply').delete().eq('id_supply', idSupply);

  /// Mitra: pending -> approved/rejected, approved -> returned.
  Future<void> respondSupply(int idSupply, String status) async {
    final uid = _uid;
    final row = await _db
        .from('supply')
        .select('status')
        .eq('id_supply', idSupply)
        .eq('id_mitra', uid)
        .maybeSingle();
    if (row == null) throw AppException('Supply tidak ditemukan');
    final cur = row['status'];
    final ok = (cur == 'pending' && (status == 'approved' || status == 'rejected')) ||
        (cur == 'approved' && status == 'returned');
    if (!ok) throw AppException('Perubahan status tidak valid');
    await _db.from('supply').update({'status': status}).eq('id_supply', idSupply).eq('id_mitra', uid);
  }
}