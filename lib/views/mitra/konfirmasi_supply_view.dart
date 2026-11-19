import 'package:flutter/material.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import 'bukti_mitra_view.dart';

class _Permintaan {
  final MitraMobilData mobil;
  final String pemohon;
  final String telepon;
  final String tanggalSewa;
  final String tanggalKembali;
  String status;

  _Permintaan(this.mobil, this.pemohon, this.telepon, this.tanggalSewa,
      this.tanggalKembali, this.status);
}

class KonfirmasiSupplyView extends StatefulWidget {
  const KonfirmasiSupplyView({super.key});

  @override
  State<KonfirmasiSupplyView> createState() => _KonfirmasiSupplyViewState();
}

class _KonfirmasiSupplyViewState extends State<KonfirmasiSupplyView> {
  static MitraMobilData _porsche() => MitraMobilData(
      nama: 'PORSCHE 911 GT3 RS',
      merk: 'Porsche',
      nopol: 'N 1774 DCT',
      spesifikasi: 'Matic',
      kapasitas: '2 orang',
      bbm: 'Pertamax',
      harga: 500000,
      status: 'Menunggu');

  final List<_Permintaan> _data = [
    _Permintaan(_porsche(), 'Nama Admin', '0812xxxxxxx', '-', '-', 'Menunggu'),
    _Permintaan(_porsche(), 'Nama Admin', '0812xxxxxxx', '-', '-', 'Menunggu'),
    _Permintaan(_porsche(), 'Nama Admin', '0812xxxxxxx', '-', '-', 'Menunggu'),
  ];

  Future<void> _putuskan(int i, bool terima) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(terima ? 'Terima Supply' : 'Tolak Supply'),
        content: Text(terima
            ? 'Terima permintaan supply ini?'
            : 'Tolak permintaan supply ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(terima ? 'Terima' : 'Tolak')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _data[i].status = terima ? 'Diterima' : 'Ditolak';
      _data[i].mobil.status = _data[i].status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MitraPage(
      title: 'KONFIRMASI SUPPLY',
      navIndex: 1,
      child: ListView.separated(
        itemCount: _data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = _data[i];
          final menunggu = d.status == 'Menunggu';
          return MitraMobilCard(
            data: d.mobil,
            actions: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pemohon : ${d.pemohon}',
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                Text('No telepon : ${d.telepon}',
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                Text('Tanggal sewa : ${d.tanggalSewa}',
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                Text('Tanggal kembali : ${d.tanggalKembali}',
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SmallButton(
                        label: 'Lihat Bukti',
                        icon: Icons.receipt_long,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BuktiMitraView()))),
                    const SizedBox(width: 6),
                    SmallButton(
                        label: 'Tolak',
                        color: const Color(0xFFEF4444),
                        onTap: menunggu ? () => _putuskan(i, false) : null),
                    const SizedBox(width: 6),
                    SmallButton(
                        label: 'Terima',
                        color: const Color(0xFF4ADE80),
                        onTap: menunggu ? () => _putuskan(i, true) : null),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}