import '../core/utils/formatter.dart';
import '../services/supply_service.dart';
import 'base_controller.dart';

/// Supply admin -> mitra.
class SupplyController extends BaseController {
  final SupplyService _service;
  SupplyController({SupplyService? service}) : _service = service ?? SupplyService();

  List<Map<String, dynamic>> supplies = [];
  List<Map<String, dynamic>> mitraList = [];
  String? _idMitra; // filter terakhir (untuk mitra), dipakai saat refresh

  Future<void> _reload() async =>
      supplies = await _service.getSupplies(idMitra: _idMitra);

  /// Admin: daftar mitra untuk dropdown.
  Future<bool> loadMitraList() => run(() async => mitraList = await _service.getMitraList());

  /// Admin: semua supply. Mitra: isi [idMitra] dengan uid miliknya (auth.uid).
  Future<bool> loadSupplies({String? status, String? idMitra}) => run(() async {
        _idMitra = idMitra;
        supplies = await _service.getSupplies(status: status, idMitra: idMitra);
      });

  /// Admin mengajukan supply ke mitra.
  Future<bool> createSupply({
    required String idMitra,
    required DateTime tanggalSupply,
    DateTime? tanggalKembali,
    int? idOrder,
  }) {
    if (tanggalKembali != null && tanggalKembali.isBefore(tanggalSupply)) {
      return Future.value(setError('Tanggal kembali tidak boleh sebelum tanggal supply'));
    }
    return run(() async {
      await _service.createSupply(
        idMitra: idMitra,
        tanggalSupply: Formatter.isoDate(tanggalSupply),
        tanggalKembali: tanggalKembali == null ? null : Formatter.isoDate(tanggalKembali),
        idOrder: idOrder,
      );
      await _reload();
    });
  }

  Future<bool> deleteSupply(int idSupply) => run(() async {
        await _service.deleteSupply(idSupply);
        await _reload();
      });

  /// Admin: tandai supply sudah dikembalikan / ubah status manual.
  Future<bool> updateStatus(int idSupply, String status) => run(() async {
        await _service.updateSupply(idSupply, {'status': status});
        await _reload();
      });

  // ---------- MITRA ----------
  Future<bool> approve(int idSupply) => _respond(idSupply, 'approved');
  Future<bool> reject(int idSupply) => _respond(idSupply, 'rejected');
  Future<bool> markReturned(int idSupply) => _respond(idSupply, 'returned');

  Future<bool> _respond(int idSupply, String status) => run(() async {
        await _service.respondSupply(idSupply, status);
        await _reload();
      });
}