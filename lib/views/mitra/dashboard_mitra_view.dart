import 'package:flutter/material.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import 'mitra_car_form_view.dart';

class DashboardMitraView extends StatefulWidget {
  const DashboardMitraView({super.key});

  @override
  State<DashboardMitraView> createState() => _DashboardMitraViewState();
}

class _DashboardMitraViewState extends State<DashboardMitraView> {
  final List<MitraMobilData> _mobil = [
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N 1774 DCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Disewa'),
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N 1774 DCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Tersedia'),
    MitraMobilData(
        nama: 'PORSCHE 911 GT3 RS',
        merk: 'Porsche',
        nopol: 'N 1774 DCT',
        spesifikasi: 'Matic',
        kapasitas: '2 orang',
        bbm: 'Pertamax',
        harga: 500000,
        status: 'Tersedia'),
  ];

  Future<void> _edit(int i) async {
    final hasil = await Navigator.push<MitraMobilData>(
      context,
      MaterialPageRoute(
          builder: (_) => MitraCarFormView(isEdit: true, mobil: _mobil[i])),
    );
    if (hasil != null && mounted) {
      setState(() => _mobil[i] = hasil);
    }
  }

  Future<void> _hapus(int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Mobil'),
        content: Text('Hapus ${_mobil[i].nama}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _mobil.removeAt(i));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Mobil dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return MitraPage(
      title: 'DASHBOARD MITRA',
      navIndex: 0,
      child: _mobil.isEmpty
          ? const Center(
              child: Text('Belum ada mobil',
                  style: TextStyle(color: Colors.white70, fontSize: 11)))
          : ListView.separated(
              itemCount: _mobil.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => MitraMobilCard(
                data: _mobil[i],
                actions: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SmallButton(
                        label: 'Edit',
                        icon: Icons.edit,
                        onTap: () => _edit(i)),
                    const SizedBox(width: 6),
                    SmallButton(
                        label: 'Hapus',
                        icon: Icons.delete_outline,
                        color: const Color(0xFFEF4444),
                        onTap: () => _hapus(i)),
                  ],
                ),
              ),
            ),
    );
  }
}