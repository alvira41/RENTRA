import 'package:flutter/material.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';
import 'bukti_mitra_view.dart';

class AktivitasMitraView extends StatelessWidget {
  const AktivitasMitraView({super.key});

  static MitraMobilData _porsche(String status) => MitraMobilData(
      nama: 'PORSCHE 911 GT3 RS',
      merk: 'Porsche',
      nopol: 'N 1774 DCT',
      spesifikasi: 'Matic',
      kapasitas: '2 orang',
      bbm: 'Pertamax',
      harga: 500000,
      status: status);

  Widget _chip(String label, String value) => Expanded(
        child: GlassCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final data = [
      _porsche('Disewa'),
      _porsche('Selesai'),
      _porsche('Disewa'),
    ];
    return MitraPage(
      title: 'AKTIVITAS',
      navIndex: 3,
      child: Column(
        children: [
          Row(
            children: [
              _chip('Total Order', '${data.length}'),
              const SizedBox(width: 8),
              _chip('Supply Aktif',
                  '${data.where((d) => d.status == 'Disewa').length}'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => MitraMobilCard(
                data: data[i],
                actions: Align(
                  alignment: Alignment.centerRight,
                  child: SmallButton(
                      label: 'Lihat Bukti',
                      icon: Icons.receipt_long,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BuktiMitraView()))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}