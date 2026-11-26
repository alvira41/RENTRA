import 'package:flutter/material.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/supply_controller.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/rentra_scaffold.dart';

class MitraDetailView extends StatefulWidget {
  const MitraDetailView({super.key, this.idMitra});

  final String? idMitra;

  @override
  State<MitraDetailView> createState() => _MitraDetailViewState();
}

class _MitraDetailViewState extends State<MitraDetailView> {
  late final KatalogController _katalog;
  late final SupplyController _supply;
  String? _idMitra;
  bool _loading = true;
  bool _dimuat = false;

  String get _namaRental => _supply.mitraList
          .where((m) => m['id_mitra']?.toString() == _idMitra)
          .firstOrNull?['nama_rental']
          ?.toString() ??
      _supply.supplies
          .where((s) => s['id_mitra']?.toString() == _idMitra)
          .firstOrNull?['mitra']?['nama_rental']
          ?.toString() ??
      '-';

  Map<String, dynamic>? get _mitraRow => _supply.mitraList
      .where((m) => m['id_mitra']?.toString() == _idMitra)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    final controllers = AppControllers.of(context);
    _katalog = controllers.katalog;
    _supply = controllers.supply;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dimuat) return;
    _dimuat = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    _idMitra = widget.idMitra ??
        (args is String ? args : args?.toString());
    _muat();
  }

  Future<void> _muat() async {
    await Future.wait([
      _supply.loadMitraList(),
      _supply.loadSupplies(idMitra: _idMitra),
      _katalog.loadKatalogMitra(idMitra: _idMitra),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<_Mobil> get _mobil => _katalog.katalogMitra.map((row) {
        final image = row['image_mitra']?.toString() ?? '';
        final kategori = row['id_category_mitra']?.toString() ?? '-';
        final stok = (row['total_stock_mitra'] as num?)?.toInt() ?? 0;
        return _Mobil(
          nama: row['nama_mobil_mitra']?.toString() ?? '-',
          kategori: kategori,
          stok: stok,
          image: image,
        );
      }).toList();

  Future<void> _ajukanSupply() async {
    final idMitra = _idMitra;
    if (idMitra == null || idMitra.isEmpty) {
      _pesan('Mitra tidak valid');
      return;
    }
    final ok = await _supply.createSupply(
      idMitra: idMitra,
      tanggalSupply: DateTime.now(),
    );
    if (!mounted) return;
    _pesan(ok
        ? 'Supply berhasil diajukan'
        : _supply.errorMessage ?? 'Supply gagal diajukan');
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
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
          child: ListenableBuilder(
            listenable: _supply,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  const Center(
                    child: Text('RENTRA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6,
                    )),
                  ),
                  const SizedBox(height: 18),
                  Text(_namaRental,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  _InfoLine('Nama Pemilik',
                      _mitraRow?['nama_pemilik']?.toString() ?? '-'),
                  _InfoLine('Alamat', _mitraRow?['alamat']?.toString() ?? '-'),
                  _InfoLine('No Telepon',
                      _mitraRow?['no_telepon']?.toString() ?? '-'),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _ajukanSupply,
                      icon: const Icon(Icons.local_shipping_outlined, size: 14),
                      label: const Text('Ajukan Supply ke Mitra Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Mobil Mitra',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    for (final m in _mobil)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MobilCard(mobil: m),
                      ),
                  if (!_loading && _mobil.isEmpty)
                    const Text('Belum ada mobil milik mitra ini',
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Mobil {
  const _Mobil({
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.image,
  });

  final String nama;
  final String kategori;
  final int stok;
  final String image;
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 8)),
          ),
          Expanded(
            child: Text(': $value',
                style: const TextStyle(color: Colors.white70, fontSize: 8)),
          ),
        ],
      ),
    );
  }
}

class _MobilCard extends StatelessWidget {
  const _MobilCard({required this.mobil});

  final _Mobil mobil;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 70,
              height: 48,
              child: mobil.image.isEmpty
                  ? Container(
                      color: Colors.white.withValues(alpha: 0.1),
                      child: const Icon(Icons.directions_car,
                          color: Colors.white70, size: 28),
                    )
                  : Image.network(
                      mobil.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white.withValues(alpha: 0.1),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white70, size: 28),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mobil.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 3),
                Text('Kategori : ${mobil.kategori}',
                    style: const TextStyle(color: Colors.white70, fontSize: 8)),
                Text('Stok : ${mobil.stok}',
                    style: const TextStyle(color: Colors.white70, fontSize: 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
