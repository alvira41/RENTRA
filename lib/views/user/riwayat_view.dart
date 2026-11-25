import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/formatter.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

class _Riwayat {
  const _Riwayat({
    required this.idOrder,
    required this.kode,
    required this.status,
    required this.nama,
    required this.image,
    required this.mulai,
    required this.selesai,
    required this.totalPrice,
    required this.detailCount,
    this.denda = 0,
  });

  final int idOrder;
  final String kode;
  final String status;
  final String nama;
  final String image;
  final DateTime mulai;
  final DateTime selesai;
  final num totalPrice;
  final int detailCount;
  final num denda;

  int get hari {
    final d = selesai.difference(mulai).inDays;
    return d < 1 ? 1 : d;
  }

  num get total => totalPrice + denda;
}

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> {
  late final OrderController _order;

  List<_Riwayat> get _data => _order.orders
      .map(_dariBaris)
      .where(
        (item) => ['completed', 'cancelled', 'rejected'].contains(item.status),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _order = AppControllers.of(context).order;
    _muat();
  }

  Future<void> _muat() async {
    final ok = await _order.loadMyOrders();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_order.errorMessage ?? 'Gagal memuat riwayat')),
      );
    }
  }

  _Riwayat _dariBaris(Map<String, dynamic> row) {
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );
    final detail = details.isEmpty ? <String, dynamic>{} : details.first;
    final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();

    num denda = 0;
    for (final d in details) {
      final dendaRows = List<Map<String, dynamic>>.from(
        (d['denda'] as List?) ?? const [],
      );
      for (final itemDenda in dendaRows) {
        denda += (itemDenda['total_denda'] as num?) ?? 0;
      }
    }

    return _Riwayat(
      idOrder: (row['id_order'] as num?)?.toInt() ?? 0,
      kode: row['transaction_code']?.toString() ?? '-',
      status: row['status']?.toString() ?? '-',
      nama: katalog?['nama_mobil']?.toString() ?? '-',
      image: katalog?['image']?.toString() ?? '',
      mulai: DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '') ??
          DateTime.now(),
      selesai: DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '') ??
          DateTime.now(),
      totalPrice: (row['total_price'] as num?) ?? 0,
      detailCount: details.length,
      denda: denda,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserPage(
      title: 'RIWAYAT',
      navIndex: 2,
      centerTitle: false,
      child: ListenableBuilder(
        listenable: _order,
        builder: (context, _) {
          final data = _data;
          if (_order.isLoading && data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return data.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat sewa',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _RiwayatCard(data: data[index]),
                );
        },
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.data});

  final _Riwayat data;

  Color get _warna => data.status == 'completed'
      ? const Color(0xFF4ADE80)
      : const Color(0xFFEF4444);

  Widget _barisHarga(String label, String nilai, {Color? warna, bool tebal = false}) {
    final gaya = TextStyle(
      color: warna ?? AppColors.textPrimary,
      fontSize: 11,
      fontWeight: tebal ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: gaya), Text(nilai, style: gaya)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selesai = data.status == 'completed';
    final rentang =
        '${tanggalPendek(data.mulai).substring(0, 6)} - ${tanggalPendek(data.selesai)}';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: _warna.withAlpha(36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _warna),
                ),
                child: Text(
                  Formatter.statusOrder(data.status),
                  style: TextStyle(
                    color: _warna,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                data.kode,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 84,
                  height: 58,
                  child: data.image.isEmpty
                      ? Image.asset(
                          'assets/images/car1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1F2937)),
                        )
                      : Image.network(
                          data.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1F2937)),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rentang,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${data.hari} Hari • ${data.detailCount} mobil',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (selesai || data.denda > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0x40FFFFFF), height: 1),
            ),
            _barisHarga('Total Sewa', Formatter.rupiah(data.totalPrice)),
            const SizedBox(height: 4),
            if (data.denda > 0) ...[
              _barisHarga(
                'Denda keterlambatan',
                Formatter.rupiah(data.denda),
                warna: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 4),
            ],
            _barisHarga('Total Bayar', Formatter.rupiah(data.total), tebal: true),
          ],
        ],
      ),
    );
  }
}
