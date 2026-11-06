import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/utils/app_exception.dart';
import '../core/utils/formatter.dart';

typedef Row = Map<String, dynamic>;

/// Order, order_details, dan denda. Semua logika (harga, stok, denda) ada di sini.
class OrderService {
  SupabaseClient get _db => SupabaseConfig.client;

  List<Row> _rows(dynamic res) => List<Row>.from(res as List);
  int _int(dynamic v) => (v as num).toInt();

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw AppException('Silakan login terlebih dahulu');
    return id;
  }

  static final String _orderSelect =
      '*, ${Db.tUser}(nama_user, no_telepon_user), '
      'order_details(*, katalog(nama_mobil, image, price), denda(*))';

  // ---------- USER ----------
  /// items: [{id_mobil, tanggal_pinjam:'yyyy-MM-dd', tanggal_kembali:'yyyy-MM-dd'}]
  /// Harga = price x jumlah hari (min 1). Return id_order.
  Future<int> createOrder(List<Row> items, {String? buktiPaymentPath}) async {
    final uid = _uid;
    if (items.isEmpty) throw AppException('Pilih minimal satu mobil');

    final ids = items.map((e) => _int(e['id_mobil'])).toSet().toList();
    final cars = _rows(await _db
        .from('katalog')
        .select('id_mobil, nama_mobil, price, total_stock')
        .inFilter('id_mobil', ids));
    final byId = {for (final c in cars) _int(c['id_mobil']): c};

    num total = 0;
    final details = <Row>[];
    for (final it in items) {
      final car = byId[_int(it['id_mobil'])];
      if (car == null) throw AppException('Mobil tidak ditemukan');
      if (_int(car['total_stock']) < 1) throw AppException('Stok ${car['nama_mobil']} habis');
      final pinjam = DateTime.parse(it['tanggal_pinjam'].toString());
      final kembali = DateTime.parse(it['tanggal_kembali'].toString());
      if (kembali.isBefore(pinjam)) throw AppException('Tanggal kembali tidak valid');
      final sub = (car['price'] as num) * Formatter.jumlahHari(pinjam, kembali);
      total += sub;
      details.add({
        'id_mobil': car['id_mobil'],
        'tanggal_pinjam': Formatter.isoDate(pinjam),
        'tanggal_kembali': Formatter.isoDate(kembali),
        'subtotal': sub,
      });
    }

    final code =
        'TRX-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final order = await _db.from('orders').insert({
      'id_user': uid,
      'transaction_code': code,
      'status': 'pending',
      'total_price': total,
      'bukti_payment': buktiPaymentPath,
    }).select('id_order').single();
    final idOrder = _int(order['id_order']);

    try {
      await _db
          .from('order_details')
          .insert(details.map((d) => {...d, 'id_order': idOrder}).toList());
    } catch (_) {
      await _db.from('orders').delete().eq('id_order', idOrder); // batalkan order setengah jadi
      rethrow;
    }
    return idOrder;
  }

  Future<void> setBuktiPayment(int idOrder, String path) async {
    final res = await _db
        .from('orders')
        .update({'bukti_payment': path})
        .eq('id_order', idOrder)
        .eq('id_user', _uid)
        .eq('status', 'pending')
        .select('id_order');
    if ((res as List).isEmpty) throw AppException('Order tidak ditemukan atau sudah diproses');
  }

  Future<void> cancelOrder(int idOrder) async {
    final res = await _db
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id_order', idOrder)
        .eq('id_user', _uid)
        .eq('status', 'pending')
        .select('id_order');
    if ((res as List).isEmpty) throw AppException('Order tidak bisa dibatalkan');
  }

  Future<List<Row>> getMyOrders() async => _rows(await _db
      .from('orders')
      .select(_orderSelect)
      .eq('id_user', _uid)
      .order('created_at', ascending: false));

  // ---------- ADMIN ----------
  Future<List<Row>> getAllOrders({String? status}) async {
    var q = _db.from('orders').select(_orderSelect);
    if (status != null) q = q.eq('status', status);
    return _rows(await q.order('created_at', ascending: false));
  }

  Future<Row?> getOrderById(int idOrder) async =>
      await _db.from('orders').select(_orderSelect).eq('id_order', idOrder).maybeSingle();

  Future<Row> _orderRow(int idOrder) async {
    final o = await _db.from('orders').select().eq('id_order', idOrder).maybeSingle();
    if (o == null) throw AppException('Order tidak ditemukan');
    return o;
  }

  /// Ubah stok. delta: {id_mobil: perubahan}. Gagal jika stok jadi negatif.
  Future<void> _adjustStock(Map<int, int> delta) async {
    for (final e in delta.entries) {
      final car = await _db
          .from('katalog')
          .select('nama_mobil, total_stock')
          .eq('id_mobil', e.key)
          .single();
      final next = _int(car['total_stock']) + e.value;
      if (next < 0) throw AppException('Stok ${car['nama_mobil']} tidak mencukupi');
      await _db.from('katalog').update({'total_stock': next}).eq('id_mobil', e.key);
    }
  }

  Future<List<Row>> _details(int idOrder) async => _rows(await _db
      .from('order_details')
      .select('*, katalog(price)')
      .eq('id_order', idOrder));

  /// Pending -> confirmed. Stok berkurang. Wajib ada bukti pembayaran.
  Future<void> confirmOrder(int idOrder) async {
    final adminId = _uid;
    final order = await _orderRow(idOrder);
    if (order['status'] != 'pending') throw AppException('Order sudah diproses');
    final bukti = order['bukti_payment'];
    if (bukti == null || bukti.toString().isEmpty) {
      throw AppException('Bukti pembayaran belum diunggah');
    }
    final need = <int, int>{};
    for (final d in await _details(idOrder)) {
      need[_int(d['id_mobil'])] = (need[_int(d['id_mobil'])] ?? 0) - 1;
    }
    await _adjustStock(need);
    await _db
        .from('orders')
        .update({'status': 'confirmed', 'id_admin': adminId}).eq('id_order', idOrder);
  }

  Future<void> rejectOrder(int idOrder) async {
    final adminId = _uid;
    final res = await _db
        .from('orders')
        .update({'status': 'rejected', 'id_admin': adminId})
        .eq('id_order', idOrder)
        .eq('status', 'pending')
        .select('id_order');
    if ((res as List).isEmpty) throw AppException('Order tidak ditemukan atau sudah diproses');
  }

  /// Confirmed -> ongoing (mobil sudah diambil).
  Future<void> startOrder(int idOrder) async {
    final res = await _db
        .from('orders')
        .update({'status': 'ongoing'})
        .eq('id_order', idOrder)
        .eq('status', 'confirmed')
        .select('id_order');
    if ((res as List).isEmpty) throw AppException('Order belum dikonfirmasi');
  }

  /// Mobil kembali: buat denda per item, stok bertambah, status completed.
  /// tanggalKembaliAktual 'yyyy-MM-dd' (default hari ini). dendaPerHari null = harga sewa/hari.
  Future<void> completeOrder(int idOrder,
      {String? tanggalKembaliAktual, num? dendaPerHari}) async {
    final order = await _orderRow(idOrder);
    if (order['status'] != 'confirmed' && order['status'] != 'ongoing') {
      throw AppException('Order belum dikonfirmasi atau sudah selesai');
    }
    final aktual = DateTime.parse(tanggalKembaliAktual ?? Formatter.isoDate(DateTime.now()));
    final back = <int, int>{};
    final dendaRows = <Row>[];
    for (final d in await _details(idOrder)) {
      final seharusnya = DateTime.parse(d['tanggal_kembali'].toString());
      final telat = aktual.difference(seharusnya).inDays;
      final hari = telat < 0 ? 0 : telat;
      final perHari = dendaPerHari ?? (d['katalog']['price'] as num);
      dendaRows.add({
        'id_order_details': d['id_order_details'],
        'tanggal_kembali_seharusnya': Formatter.isoDate(seharusnya),
        'tanggal_kembali_aktual': Formatter.isoDate(aktual),
        'denda_per_hari': perHari,
        'keterlambatan_hari': hari,
        'total_denda': hari * perHari,
      });
      back[_int(d['id_mobil'])] = (back[_int(d['id_mobil'])] ?? 0) + 1;
    }
    if (dendaRows.isNotEmpty) await _db.from('denda').insert(dendaRows);
    await _adjustStock(back);
    await _db.from('orders').update({'status': 'completed'}).eq('id_order', idOrder);
  }

  /// Semua denda (admin) atau milik user (jika RLS membatasi).
  Future<List<Row>> getDenda() async => _rows(await _db
      .from('denda')
      .select('*, order_details(id_order, tanggal_pinjam, katalog(nama_mobil))')
      .order('id_denda', ascending: false));

  /// Angka dashboard admin.
  Future<Row> getAdminStats() async {
    final orders = _rows(await _db.from('orders').select('status, total_price'));
    int n(String s) => orders.where((o) => o['status'] == s).length;
    num sum(Iterable<Row> r, String k) => r.fold<num>(0, (a, e) => a + ((e[k] as num?) ?? 0));
    final denda = _rows(await _db.from('denda').select('total_denda'));
    final users = _rows(await _db.from(Db.tUser).select(Db.pkUser));
    final mitra = _rows(await _db.from(Db.tMitra).select(Db.pkMitra));
    final mobil = _rows(await _db.from('katalog').select('id_mobil'));
    final supply = _rows(await _db.from('supply').select('status'));
    return {
      'total_order': orders.length,
      'order_pending': n('pending'),
      'order_confirmed': n('confirmed'),
      'order_ongoing': n('ongoing'),
      'order_completed': n('completed'),
      'total_user': users.length,
      'total_mitra': mitra.length,
      'total_mobil': mobil.length,
      'supply_pending': supply.where((s) => s['status'] == 'pending').length,
      'total_pendapatan': sum(
          orders.where((o) => ['confirmed', 'ongoing', 'completed'].contains(o['status'])),
          'total_price'),
      'total_denda': sum(denda, 'total_denda'),
    };
  }
}