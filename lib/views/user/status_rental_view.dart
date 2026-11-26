import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/formatter.dart';
import '../../core/utils/image_picker_helper.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

class _Rental {
  const _Rental({
    required this.idOrder,
    required this.kode,
    required this.mobil,
    required this.image,
    required this.ambil,
    required this.kembali,
    required this.status,
    required this.buktiPayment,
    required this.denda,
  });

  final int idOrder;
  final String kode;
  final MitraMobilData mobil;
  final String image;
  final DateTime ambil;
  final DateTime kembali;
  final String status;
  final String? buktiPayment;
  final num denda;
}

class StatusRentalView extends StatefulWidget {
  const StatusRentalView({super.key});

  @override
  State<StatusRentalView> createState() => _StatusRentalViewState();
}

class _StatusRentalViewState extends State<StatusRentalView> {
  late final OrderController _order;
  final Map<String, Future<String?>> _buktiFutures = {};

  List<_Rental> get _rentals => _order.orders.map(_dariBaris).toList();

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
        SnackBar(content: Text(_order.errorMessage ?? 'Gagal memuat rental')),
      );
    }
  }

  _Rental _dariBaris(Map<String, dynamic> row) {
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );
    final detail = details.isEmpty ? <String, dynamic>{} : details.first;
    final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();
    final status = row['status']?.toString() ?? '-';
    final path = row['bukti_payment']?.toString();

    num denda = 0;
    for (final d in details) {
      final dendaRows = List<Map<String, dynamic>>.from(
        (d['denda'] as List?) ?? const [],
      );
      for (final itemDenda in dendaRows) {
        denda += (itemDenda['total_denda'] as num?) ?? 0;
      }
    }

    final harga = (katalog?['price'] as num?)?.toInt() ??
        (row['total_price'] as num?)?.toInt() ??
        0;

    return _Rental(
      idOrder: (row['id_order'] as num?)?.toInt() ?? 0,
      kode: row['transaction_code']?.toString() ?? '-',
      mobil: MitraMobilData(
        id: (detail['id_mobil'] as num?)?.toInt() ?? 0,
        nama: katalog?['nama_mobil']?.toString() ?? '-',
        merk: katalog?['merk']?.toString() ?? '',
        nopol: katalog?['nopol']?.toString() ?? '',
        spesifikasi: (katalog?['spesifikasi'] ??
                katalog?['category']?['nama'])
            ?.toString() ??
            '',
        kapasitas: katalog?['kapasitas']?.toString() ?? '',
        bbm: katalog?['bbm']?.toString() ?? '',
        kategori: katalog?['category']?['nama']?.toString() ?? '',
        harga: harga,
        status: Formatter.statusOrder(status),
      ),
      image: katalog?['image']?.toString() ?? '',
      ambil: DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '') ??
          DateTime.now(),
      kembali: DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '') ??
          DateTime.now(),
      status: status,
      buktiPayment: path == null || path.isEmpty ? null : path,
      denda: denda,
    );
  }

  Future<String?> _buktiFuture(_Rental rental) {
    final path = rental.buktiPayment;
    if (path == null) return Future.value(null);
    final key = '${rental.idOrder}:$path';
    return _buktiFutures.putIfAbsent(key, () => _order.buktiUrl(path));
  }

  Future<void> _batal(_Rental rental) async {
    final ok = await _order.cancelOrder(rental.idOrder);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Pesanan berhasil dibatalkan'
              : _order.errorMessage ?? 'Pesanan gagal dibatalkan',
        ),
      ),
    );
  }

  Future<void> _unggahBukti(_Rental rental) async {
    final file = await pickUploadFile();
    if (file == null || !mounted) return;
    final ok = await _order.uploadBukti(rental.idOrder, file);
    if (!mounted) return;
    if (ok) {
      _buktiFutures.clear();
      setState(() {});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Bukti pembayaran berhasil diunggah'
              : _order.errorMessage ?? 'Bukti gagal diunggah',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserPage(
      title: 'STATUS RENTAL',
      navIndex: 1,
      centerTitle: false,
      showBadge: false,
      child: ListenableBuilder(
        listenable: _order,
        builder: (context, _) {
          final rentals = _rentals;
          if (_order.isLoading && rentals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return rentals.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada rental',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  itemCount: rentals.length,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(color: Color(0x26FFFFFF), height: 1),
                  ),
                  itemBuilder: (context, index) {
                    final rental = rentals[index];
                    return _RentalItem(
                      rental: rental,
                      buktiFuture: _buktiFuture(rental),
                      onCancel: () => _batal(rental),
                      onUpload: () => _unggahBukti(rental),
                    );
                  },
                );
        },
      ),
    );
  }
}

class _Kotak extends StatelessWidget {
  const _Kotak({required this.child, this.warna});

  final Widget child;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warna == null ? const Color(0x26FFFFFF) : warna!.withAlpha(36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna ?? const Color(0x40FFFFFF)),
      ),
      child: child,
    );
  }
}

class _RentalItem extends StatelessWidget {
  const _RentalItem({
    required this.rental,
    required this.buktiFuture,
    required this.onCancel,
    required this.onUpload,
  });

  final _Rental rental;
  final Future<String?> buktiFuture;
  final VoidCallback onCancel;
  final VoidCallback onUpload;

  Color get _warnaStatus {
    switch (rental.status) {
      case 'confirmed':
      case 'ongoing':
        return const Color(0xFF4ADE80);
      case 'completed':
        return const Color(0xFFE5E7EB);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFFB923C);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  Widget _baris(String t) {
    final isi = t.split(':').skip(1).join(':').trim();
    if (isi.isEmpty || isi == '-') return const SizedBox.shrink();
    return Text(
      t,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 9,
        height: 1.4,
      ),
    );
  }

  Widget _tanggal(String label, DateTime d) => Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tanggalPendek(d),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 10),
            ),
            Text(
              jamWib(d),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );

  String get _judulWaktu {
    switch (rental.status) {
      case 'pending':
        return 'Menunggu konfirmasi admin';
      case 'confirmed':
        return 'Mobil siap diambil';
      case 'ongoing':
        return 'Sedang digunakan';
      case 'completed':
        return 'Sewa selesai';
      case 'rejected':
        return 'Pesanan ditolak';
      case 'cancelled':
        return 'Pesanan dibatalkan';
      default:
        return Formatter.statusOrder(rental.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = rental.mobil;
    final dendaAktif = rental.denda > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: _warnaStatus.withAlpha(36),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _warnaStatus),
          ),
          child: Text(
            Formatter.statusOrder(rental.status),
            style: TextStyle(
              color: _warnaStatus,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _Kotak(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 84,
                      height: 58,
                      child: rental.image.isEmpty
                          ? Image.asset(
                              'assets/images/car1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xFF1F2937)),
                            )
                          : Image.network(
                              rental.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xFF1F2937)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _baris('Kode : ${rental.kode}'),
                        _baris('Merk Mobil : ${m.merk}'),
                        _baris('Nomor Polisi : ${m.nopol}'),
                        _baris('Spesifikasi : ${m.spesifikasi}'),
                        _baris('Kapasitas penumpang : ${m.kapasitas}'),
                        _baris('Jenis BBM : ${m.bbm}'),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Color(0x40FFFFFF), height: 1),
              ),
              Row(
                children: [
                  _tanggal('Tanggal Ambil', rental.ambil),
                  _tanggal('Tanggal Kembali', rental.kembali),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Kotak(
          warna: rental.status == 'rejected' || rental.status == 'cancelled'
              ? const Color(0xFFEF4444)
              : null,
          child: Row(
            children: [
              Icon(
                rental.status == 'rejected' || rental.status == 'cancelled'
                    ? Icons.cancel_outlined
                    : Icons.schedule,
                size: 18,
                color: rental.status == 'rejected' || rental.status == 'cancelled'
                    ? const Color(0xFFEF4444)
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _judulWaktu,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Kode order ${rental.kode}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Kotak(
          warna: dendaAktif ? const Color(0xFFEF4444) : null,
          child: Row(
            children: [
              Icon(
                dendaAktif
                    ? Icons.warning_amber_rounded
                    : Icons.receipt_long_outlined,
                size: 18,
                color: dendaAktif
                    ? const Color(0xFFEF4444)
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dendaAktif
                      ? 'Denda keterlambatan ${Formatter.rupiah(rental.denda)}'
                      : 'Denda dihitung otomatis saat pengembalian',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Kotak(
          child: FutureBuilder<String?>(
            future: buktiFuture,
            builder: (context, snapshot) {
              final url = snapshot.data;
              return Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti Pembayaran',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          url == null
                              ? 'Bukti belum diunggah'
                              : 'Bukti tersedia',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 40,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1F2937)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (rental.status == 'pending') ...[
          const SizedBox(height: 8),
          _Kotak(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallButton(
                  label: 'Batalkan',
                  color: const Color(0xFFEF4444),
                  onTap: onCancel,
                ),
                SmallButton(label: 'Unggah Bukti', onTap: onUpload),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
