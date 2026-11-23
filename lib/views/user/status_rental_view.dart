import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

const int _dendaPerHari = 100000;
const Duration _toleransi = Duration(days: 1);

enum _Level { normal, peringatan, denda }

class _Rental {
  const _Rental({
    required this.mobil,
    required this.ambil,
    required this.kembali,
    required this.status,
  });

  final MitraMobilData mobil;
  final DateTime ambil;
  final DateTime kembali;
  final String status;
}

String _rp(int v) => rupiah(v).replaceFirst('Rp.', 'Rp ');

String _durasi(Duration d) {
  final hari = d.inDays;
  final jam = d.inHours % 24;
  if (hari > 0) return '$hari hari $jam jam';
  if (d.inHours > 0) return '${d.inHours} jam';
  return '${d.inMinutes} menit';
}

class StatusRentalView extends StatefulWidget {
  const StatusRentalView({super.key});

  @override
  State<StatusRentalView> createState() => _StatusRentalViewState();
}

class _StatusRentalViewState extends State<StatusRentalView> {
  late final List<_Rental> _data;

  static MitraMobilData _mobil() => MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N V174 OCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Disewa',
      );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dasar = DateTime(now.year, now.month, now.day, now.hour);
    _data = [
      _Rental(
        mobil: _mobil(),
        ambil: dasar.add(const Duration(days: 1)),
        kembali: dasar.add(const Duration(days: 4, hours: 4)),
        status: 'Pending',
      ),
      _Rental(
        mobil: _mobil(),
        ambil: dasar.subtract(const Duration(days: 2)),
        kembali: dasar.add(const Duration(days: 1, hours: 4)),
        status: 'Confirmed',
      ),
      _Rental(
        mobil: _mobil(),
        ambil: dasar.subtract(const Duration(days: 4)),
        kembali: dasar.subtract(const Duration(hours: 6)),
        status: 'Confirmed',
      ),
      _Rental(
        mobil: _mobil(),
        ambil: dasar.subtract(const Duration(days: 6)),
        kembali: dasar.subtract(const Duration(days: 1, hours: 4)),
        status: 'Completed',
      ),
      _Rental(
        mobil: _mobil(),
        ambil: dasar.add(const Duration(days: 2)),
        kembali: dasar.add(const Duration(days: 5)),
        status: 'Ditolak',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return UserPage(
      title: 'STATUS RENTAL',
      navIndex: 1,
      centerTitle: false,
      showBadge: false,
      child: _data.isEmpty
          ? const Center(
              child: Text(
                'Belum ada rental',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            )
          : ListView.separated(
              itemCount: _data.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(color: Color(0x26FFFFFF), height: 1),
              ),
              itemBuilder: (context, index) =>
                  _RentalItem(rental: _data[index]),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warna ?? const Color(0x40FFFFFF)),
      ),
      child: child,
    );
  }
}

class _RentalItem extends StatelessWidget {
  const _RentalItem({required this.rental});

  final _Rental rental;

  Color get _warnaStatus {
    switch (rental.status) {
      case 'Confirmed':
        return const Color(0xFF4ADE80);
      case 'Completed':
        return const Color(0xFFE5E7EB);
      case 'Ditolak':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  Widget _baris(String t) => Text(
        t,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9,
          height: 1.4,
        ),
      );

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
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 10),
            ),
            Text(
              jamWib(d),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final m = rental.mobil;
    final ditolak = rental.status == 'Ditolak';
    final selisih = DateTime.now().difference(rental.kembali);
    final terlambat = !selisih.isNegative;
    final telat = terlambat ? selisih : Duration.zero;
    final sisa = terlambat ? Duration.zero : -selisih;

    _Level level = _Level.normal;
    if (rental.status != 'Pending' && !ditolak && terlambat) {
      level = telat < _toleransi ? _Level.peringatan : _Level.denda;
    }

    final hariDenda = level == _Level.denda ? telat.inDays : 0;
    final totalDenda = hariDenda * _dendaPerHari;

    final Color? warnaDenda = level == _Level.peringatan
        ? const Color(0xFFFACC15)
        : level == _Level.denda
            ? const Color(0xFFEF4444)
            : null;

    final judulWaktu = ditolak
        ? 'Pesanan ditolak'
        : terlambat
            ? 'Terlambat ${_durasi(telat)}'
            : 'Sisa waktu ${_durasi(sisa)}';
    final subWaktu = ditolak
        ? 'Silakan hubungi admin atau lakukan pemesanan ulang'
        : !terlambat
        ? 'Kembalikan sebelum ${tanggalPendek(rental.kembali)}, ${jamWib(rental.kembali)} agar tidak terkena denda'
        : level == _Level.peringatan
            ? 'Toleransi tersisa ${_durasi(_toleransi - telat)}'
            : 'Toleransi pengembalian sudah habis';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: _warnaStatus.withAlpha(36),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _warnaStatus),
          ),
          child: Text(
            rental.status,
            style: TextStyle(
              color: _warnaStatus,
              fontSize: 10,
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
                      child: Image.asset(
                        'assets/images/car1.png',
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
          warna: ditolak ? const Color(0xFFEF4444) : null,
          child: Row(
            children: [
              Icon(
                ditolak ? Icons.cancel_outlined : Icons.schedule,
                size: 18,
                color: ditolak
                    ? const Color(0xFFEF4444)
                    : AppColors.textPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judulWaktu,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subWaktu,
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
          warna: const Color(0xFFEF4444),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Color(0xFFEF4444)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Denda keterlambatan ${_rp(_dendaPerHari)}/hari',
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
          warna: warnaDenda,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    level == _Level.normal
                        ? Icons.receipt_long_outlined
                        : level == _Level.peringatan
                            ? Icons.warning_amber_rounded
                            : Icons.error_outline,
                    size: 18,
                    color: warnaDenda ?? AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Denda',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (level == _Level.normal)
                          const Text(
                            'Belum ada keterlambatan',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        if (level == _Level.peringatan) ...[
                          const Text(
                            'Peringatan!',
                            style: TextStyle(
                              color: Color(0xFFFACC15),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Terlambat ${_durasi(telat)}. Toleransi tersisa ${_durasi(_toleransi - telat)}. Kembalikan sekarang agar tidak terkena denda.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        if (level == _Level.denda) ...[
                          Text(
                            'Terlambat ${_durasi(telat)}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Denda berjalan $hariDenda hari x ${_rp(_dendaPerHari)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          const Text(
                            'Tim kami akan mengecek denda dan menghubungi Anda.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total denda :',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _rp(totalDenda),
                    style: TextStyle(
                      color: level == _Level.denda
                          ? const Color(0xFFEF4444)
                          : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}