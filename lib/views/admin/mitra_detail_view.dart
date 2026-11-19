import 'package:flutter/material.dart';
import '../widgets/admin_bottom_bar.dart';
import '../widgets/rentra_scaffold.dart';

class MitraDetailView extends StatefulWidget {
  const MitraDetailView({super.key});

  @override
  State<MitraDetailView> createState() => _MitraDetailViewState();
}

class _MitraDetailViewState extends State<MitraDetailView> {
  static const _namaRental = 'Rental Mobil Malang';
  static const _pemilik = '-';
  static const _alamat = '-';
  static const _telepon = '-';

  final List<_Mobil> _mobil = [
    _Mobil('PORSCHE 911 GT3 RS', 'Porsche', 'N 1774 DCT', 'Matic', '2 orang',
        'Pertamax', 500000, 'Disewa'),
    _Mobil('PORSCHE 911 GT3 RS', 'Porsche', 'N 1774 DCT', 'Matic', '2 orang',
        'Pertamax', 500000, 'Tersedia'),
    _Mobil('PORSCHE 911 GT3 RS', 'Porsche', 'N 1774 DCT', 'Matic', '2 orang',
        'Pertamax', 500000, 'Disewa'),
  ];

  Future<void> _ajukanSupply(_Mobil m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ajukan Supply'),
        content: Text('Ajukan supply untuk ${m.nama}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ajukan')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supply ${m.nama} diajukan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF111B2E), Color(0xFF0B1220)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              const Center(
                child: Text('RENTRA',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6)),
              ),
              const SizedBox(height: 18),
              const Text(_namaRental,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const _InfoLine('Nama Pemilik', _pemilik),
              const _InfoLine('Alamat', _alamat),
              const _InfoLine('No Telepon', _telepon),
              const SizedBox(height: 14),
              for (final m in _mobil)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MobilCard(mobil: m, onAjukan: () => _ajukanSupply(m)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Mobil {
  final String nama, merk, nopol, spesifikasi, kapasitas, bbm, status;
  final int harga;
  _Mobil(this.nama, this.merk, this.nopol, this.spesifikasi, this.kapasitas,
      this.bbm, this.harga, this.status);
}

class _InfoLine extends StatelessWidget {
  final String label, value;
  const _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 8))),
          Text(': $value',
              style: const TextStyle(color: Colors.white70, fontSize: 8)),
        ],
      ),
    );
  }
}

class _MobilCard extends StatelessWidget {
  final _Mobil mobil;
  final VoidCallback onAjukan;
  const _MobilCard({required this.mobil, required this.onAjukan});

  Color get _statusColor =>
      mobil.status == 'Tersedia' ? const Color(0xFF2E7D32) : const Color(0xFF1E3A8A);

  String _rp(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp.$buf';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 70,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.directions_car,
                    color: Colors.white70, size: 28),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(mobil.status,
                    style: const TextStyle(color: Colors.white, fontSize: 7)),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onAjukan,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text('Ajukan Supply',
                      style: TextStyle(color: Colors.white, fontSize: 7)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mobil.nama,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                _Spec('Merk Mobil', mobil.merk),
                _Spec('Nomor Polisi', mobil.nopol),
                _Spec('Spesifikasi', mobil.spesifikasi),
                _Spec('Kapasitas penumpang', mobil.kapasitas),
                _Spec('Jenis BBM', mobil.bbm),
                const SizedBox(height: 2),
                const Text('Harga tidak termasuk BBM',
                    style: TextStyle(color: Colors.white70, fontSize: 7)),
                Text('${_rp(mobil.harga)} / hari',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final String label, value;
  const _Spec(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Text('$label : $value',
        style: const TextStyle(color: Colors.white, fontSize: 7));
  }
}