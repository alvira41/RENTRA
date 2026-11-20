import '../core/utils/formatter.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/storage_service.dart';
import 'base_controller.dart';

/// Order, denda, dan statistik dashboard admin.
class OrderController extends BaseController {
  final OrderService _service;
  final StorageService _storage;
  final AuthService _auth;
  OrderController({OrderService? service, StorageService? storage, AuthService? auth})
      : _service = service ?? OrderService(),
        _storage = storage ?? StorageService(),
        _auth = auth ?? AuthService();

  List<Map<String, dynamic>> orders = [];
  Map<String, dynamic>? selectedOrder;
  List<Map<String, dynamic>> dendaList = [];
  Map<String, dynamic> stats = {};

  // ---------- USER ----------
  /// items: [{'id_mobil': 1, 'tanggal_pinjam': DateTime, 'tanggal_kembali': DateTime}]
  /// (DateTime atau String 'yyyy-MM-dd' sama-sama boleh). [bukti] opsional, bisa menyusul.
  /// Setelah sukses, id order baru ada di [lastOrderId].
  int? lastOrderId;

  Future<bool> createOrder(List<Map<String, dynamic>> items, {UploadFile? bukti}) {
    if (items.isEmpty) return Future.value(setError('Pilih minimal satu mobil'));
    return run(() async {
      final normalized = items
          .map((e) => {
                'id_mobil': e['id_mobil'],
                'tanggal_pinjam': _d(e['tanggal_pinjam']),
                'tanggal_kembali': _d(e['tanggal_kembali']),
              })
          .toList();
      final path =
          bukti == null ? null : await _storage.uploadBuktiPayment(_auth.currentUid!, bukti.bytes, bukti.name);
      lastOrderId = await _service.createOrder(normalized, buktiPaymentPath: path);
      orders = await _service.getMyOrders();
    });
  }

  /// Upload / ganti bukti pembayaran untuk order yang masih pending.
  Future<bool> uploadBukti(int idOrder, UploadFile bukti) => run(() async {
        final path = await _storage.uploadBuktiPayment(_auth.currentUid!, bukti.bytes, bukti.name);
        await _service.setBuktiPayment(idOrder, path);
        orders = await _service.getMyOrders();
      });

  Future<bool> cancelOrder(int idOrder) => run(() async {
        await _service.cancelOrder(idOrder);
        orders = await _service.getMyOrders();
      });

  Future<bool> loadMyOrders() => run(() async => orders = await _service.getMyOrders());

  // ---------- ADMIN ----------
  /// [status]: 'pending' | 'confirmed' | 'ongoing' | 'completed' | 'rejected' | 'cancelled' | null (semua)
  Future<bool> loadAllOrders({String? status}) =>
      run(() async => orders = await _service.getAllOrders(status: status));

  Future<bool> loadOrderDetail(int idOrder) =>
      run(() async => selectedOrder = await _service.getOrderById(idOrder));

  Future<bool> confirmOrder(int idOrder, {String? refreshStatus}) =>
      _act(idOrder, () => _service.confirmOrder(idOrder), refreshStatus);

  Future<bool> rejectOrder(int idOrder, {String? refreshStatus}) =>
      _act(idOrder, () => _service.rejectOrder(idOrder), refreshStatus);

  Future<bool> startOrder(int idOrder, {String? refreshStatus}) =>
      _act(idOrder, () => _service.startOrder(idOrder), refreshStatus);

  /// Mobil dikembalikan: denda dihitung otomatis dari tanggal kembali aktual.
  Future<bool> completeOrder(int idOrder,
          {DateTime? tanggalKembaliAktual, num? dendaPerHari, String? refreshStatus}) =>
      _act(
          idOrder,
          () => _service.completeOrder(idOrder,
              tanggalKembaliAktual:
                  tanggalKembaliAktual == null ? null : Formatter.isoDate(tanggalKembaliAktual),
              dendaPerHari: dendaPerHari),
          refreshStatus);

  Future<bool> _act(int idOrder, Future<void> Function() action, String? refreshStatus) =>
      run(() async {
        await action();
        orders = await _service.getAllOrders(status: refreshStatus);
        selectedOrder = await _service.getOrderById(idOrder);
      });

  /// Admin: semua denda. User: denda miliknya.
  Future<bool> loadDenda() => run(() async => dendaList = await _service.getDenda());

  /// Admin: angka dashboard (total_order, order_pending, total_pendapatan, dst).
  Future<bool> loadStats() => run(() async => stats = await _service.getAdminStats());

  /// URL sementara untuk melihat bukti pembayaran (admin / pemilik order).
  Future<String?> buktiUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    return _storage.signedUrl(StorageService.bucketBukti, path);
  }

  String _d(dynamic v) => v is DateTime ? Formatter.isoDate(v) : v.toString();
}