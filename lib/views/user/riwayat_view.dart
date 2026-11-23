import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/user_page.dart';
import 'checkout_view.dart';

class _Riwayat {
  const _Riwayat({
    required this.kode,
    required this.status,
    required this.nama,
    required this.mulai,
    required this.selesai,
    required this.harga,
    this.denda = 0,
  });

  final String kode;
  final String status;
  final String nama;
  final DateTime mulai;
  final DateTime selesai;
  final int harga;
  final int denda;

  int get hari {
    final d = selesai.difference(mulai).inDays;
    return d < 1 ? 1 : d;
  }

  int get total => harga * hari + denda;
}

String _rp(int v) => rupiah(v).replaceFirst('Rp.', 'Rp ');

class RiwayatView extends StatelessWidget {
  const RiwayatView({super.key});

  static final List<_Riwayat> _data = [
    _Riwayat(
      kode: '#0001791',
      status: 'Completed',
      nama: 'PORSCHE 911 GT3 RS',
      mulai: DateTime(2026, 9, 25),
      selesai: DateTime(2026, 9, 28),
      harga: 500000,
    ),
    _Riwayat(
      kode: '#0001754',
      status: 'Completed',
      nama: 'PORSCHE 911 GT3 RS',
      mulai: DateTime(2026, 9, 10),
      selesai: DateTime(2026, 9, 12),
      harga: 500000,
      denda: 100000,
    ),
    _Riwayat(
      kode: '#0001702',
      status: 'Reject',
      nama: 'PORSCHE 911 GT3 RS',
      mulai: DateTime(2026, 9, 2),
      selesai: DateTime(2026, 9, 5),
      harga: 500000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return UserPage(
      title: 'RIWAYAT',
      navIndex: 2,
      centerTitle: false,
      child: _data.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat sewa',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            )
          : ListView.separated(
              itemCount: _data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _RiwayatCard(data: _data[index]),
            ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.data});

  final _Riwayat data;

  Color get _warna =>
      data.status == 'Completed' ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);

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
    final selesai = data.status == 'Completed';
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: _warna.withAlpha(36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _warna),
                ),
                child: Text(
                  data.status,
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
                  child: Image.asset(
                    'assets/images/car1.png',
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
                      '${data.hari} Hari',
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
          if (selesai) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0x40FFFFFF), height: 1),
            ),
            if (data.denda > 0) ...[
              _barisHarga(
                'Denda keterlambatan',
                _rp(data.denda),
                warna: const Color(0xFFEF4444),
              ),
              const SizedBox(height: 4),
            ],
            _barisHarga('Total Bayar', _rp(data.total), tebal: true),
          ],
        ],
      ),
    );
  }
}