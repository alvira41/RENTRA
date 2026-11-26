import 'package:flutter/material.dart';
import '../../controllers/supply_controller.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import 'bukti_mitra_view.dart';

class _Permintaan {
  const _Permintaan({
    required this.id,
    required this.tanggalSupply,
    required this.tanggalKembali,
    required this.status,
  });

  final int id;
  final String tanggalSupply;
  final String tanggalKembali;
  final String status;
}

class KonfirmasiSupplyView extends StatefulWidget {
  const KonfirmasiSupplyView({super.key});

  @override
  State<KonfirmasiSupplyView> createState() => _KonfirmasiSupplyViewState();
}

class _KonfirmasiSupplyViewState extends State<KonfirmasiSupplyView> {
  late final SupplyController _supply;
  late final String? _idMitra;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final controllers = AppControllers.of(context);
    _supply = controllers.supply;
    _idMitra = controllers.auth.idMitra;
    _muat();
  }

  Future<void> _muat() async {
    final ok = await _supply.loadSupplies(status: 'pending', idMitra: _idMitra);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      _pesan(_supply.errorMessage ?? 'Gagal memuat supply');
    }
  }

  List<_Permintaan> get _data => _supply.supplies.map((row) {
        final kembali = row['tanggal_kembali']?.toString();
        return _Permintaan(
          id: (row['id_supply'] as num?)?.toInt() ?? 0,
          tanggalSupply: row['tanggal_supply']?.toString() ?? '-',
          tanggalKembali: (kembali == null || kembali.isEmpty) ? '-' : kembali,
          status: row['status']?.toString() ?? 'Menunggu',
        );
      }).toList();

  Future<void> _putuskan(_Permintaan item, bool terima) async {
    final okDialog = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(terima ? 'Terima Supply' : 'Tolak Supply'),
        content: Text(terima
            ? 'Terima permintaan supply ini?'
            : 'Tolak permintaan supply ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(terima ? 'Terima' : 'Tolak'),
          ),
        ],
      ),
    );
    if (okDialog != true || !mounted) return;

    final ok = terima
        ? await _supply.approve(item.id)
        : await _supply.reject(item.id);
    if (!mounted) return;
    _pesan(ok
        ? (terima ? 'Supply diterima' : 'Supply ditolak')
        : _supply.errorMessage ?? 'Gagal memperbarui supply');
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return MitraPage(
      title: 'KONFIRMASI SUPPLY',
      navIndex: 1,
      child: ListenableBuilder(
        listenable: _supply,
        builder: (context, _) {
          final data = _data;
          if (_loading) return const Center(child: CircularProgressIndicator());
          if (data.isEmpty) {
            return const Center(
              child: Text('Tidak ada supply menunggu konfirmasi',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            );
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final d = data[i];
              return MitraMobilCard(
                data: MitraMobilData(
                  nama: 'Supply #${d.id}',
                  merk: '-',
                  nopol: '-',
                  spesifikasi: '-',
                  kapasitas: '-',
                  bbm: '-',
                  harga: 0,
                  status: d.status == 'pending' ? 'Menunggu' : d.status,
                ),
                actions: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal supply : ${d.tanggalSupply}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9)),
                    Text('Tanggal kembali : ${d.tanggalKembali}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9)),
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
                              builder: (_) =>
                                  BuktiMitraView(idSupply: d.id),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SmallButton(
                          label: 'Tolak',
                          color: const Color(0xFFEF4444),
                          onTap: () => _putuskan(d, false),
                        ),
                        const SizedBox(width: 6),
                        SmallButton(
                          label: 'Terima',
                          color: const Color(0xFF4ADE80),
                          onTap: () => _putuskan(d, true),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
