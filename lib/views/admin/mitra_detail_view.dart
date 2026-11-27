import 'package:flutter/material.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/supply_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/mitra_mobil_card.dart' show rupiah;
import '../widgets/admin_bottom_bar.dart';
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
      _katalog.loadCategories(),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  String _namaKategori(dynamic id) {
    final idKat = id is num ? id.toInt() : int.tryParse(id?.toString() ?? '');
    if (idKat == null) return '-';
    for (final k in _katalog.categories) {
      final kid = k['id_category'];
      if (kid is num && kid.toInt() == idKat) {
        return (k['nama'] ?? k['name'])?.toString() ?? '-';
      }
    }
    return '-';
  }

  List<_Mobil> get _mobil => _katalog.katalogMitra.map((row) {
        String isi(List<String> keys) {
          for (final key in keys) {
            final value = row[key];
            if (value == null) continue;
            final teks = value.toString().trim();
            if (teks.isNotEmpty && teks != '-') return teks;
          }
          return '';
        }

        final image = row['image_mitra']?.toString() ?? '';
        final kategori = _namaKategori(row['id_category_mitra']);
        final stok = (row['total_stock_mitra'] as num?)?.toInt() ?? 0;
        final harga = (row['price'] as num?)?.toInt() ??
            (row['harga'] as num?)?.toInt() ??
            0;
        return _Mobil(
          nama: row['nama_mobil_mitra']?.toString() ?? '-',
          kategori: kategori,
          merk: isi(const ['merk', 'merk_mobil', 'brand']),
          nopol: isi(const ['nopol', 'no_polisi', 'plat_nomor']),
          spesifikasi: isi(const ['spesifikasi']),
          kapasitas: isi(const ['kapasitas', 'kapasitas_penumpang']),
          bbm: isi(const ['bbm', 'jenis_bbm']),
          harga: harga,
          deskripsi: isi(const ['deskripsi', 'keterangan']),
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
    final width = MediaQuery.of(context).size.width;
    final side = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 3,
        onAddTap: () => showAddOptionsDialog(context),
      ),
      body: RentraBackground(
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: _supply,
            builder: (context, _) {
              return ListView(
                padding: EdgeInsets.fromLTRB(side, 16, side, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: width * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(_namaRental,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      )),
                  const SizedBox(height: 8),
                  _InfoLine('Nama Pemilik',
                      _mitraRow?['nama_pemilik']?.toString() ?? '-'),
                  _InfoLine('Alamat', _mitraRow?['alamat']?.toString() ?? '-'),
                  _InfoLine('No Telepon',
                      _mitraRow?['no_telepon']?.toString() ?? '-'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _ajukanSupply,
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('Ajukan Supply ke Mitra Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F6FB8).withAlpha(50),
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFF4F6FB8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mobil Mitra',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 10),
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
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MobilCard(mobil: m),
                      ),
                  if (!_loading && _mobil.isEmpty)
                    const Text('Belum ada mobil milik mitra ini',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
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
    this.merk = '',
    this.nopol = '',
    this.spesifikasi = '',
    this.kapasitas = '',
    this.bbm = '',
    this.harga = 0,
    this.deskripsi = '',
  });

  final String nama;
  final String kategori;
  final int stok;
  final String image;
  final String merk;
  final String nopol;
  final String spesifikasi;
  final String kapasitas;
  final String bbm;
  final int harga;
  final String deskripsi;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 10)),
          ),
          Expanded(
            child: Text(': $value',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _MobilCard extends StatelessWidget {
  const _MobilCard({required this.mobil});

  final _Mobil mobil;

  Widget _gambarKosong() => Container(
        color: AppColors.inputFill,
        child: const Icon(Icons.directions_car,
            color: AppColors.textSecondary, size: 28),
      );

  Widget _baris(String teks) => Text(
        teks,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 9,
          height: 1.4,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.26;
    final tersedia = mobil.stok > 0;
    final warna =
        tersedia ? const Color(0xFF4ADE80) : const Color(0xFFFB923C);

    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: imageWidth,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: mobil.image.isEmpty
                        ? _gambarKosong()
                        : Image.network(
                            mobil.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _gambarKosong(),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: warna.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: warna),
                  ),
                  child: Text(
                    tersedia ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      color: warna,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mobil.nama.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (mobil.merk.isNotEmpty)
                  _baris('Merk Mobil : ${mobil.merk}'),
                if (mobil.nopol.isNotEmpty)
                  _baris('Nomor Polisi : ${mobil.nopol}'),
                if (mobil.spesifikasi.isNotEmpty)
                  _baris('Spesifikasi : ${mobil.spesifikasi}'),
                _baris('Tipe Transmisi : ${mobil.kategori}'),
                if (mobil.kapasitas.isNotEmpty)
                  _baris('Kapasitas penumpang : ${mobil.kapasitas}'),
                if (mobil.bbm.isNotEmpty) _baris('Jenis BBM : ${mobil.bbm}'),
                if (mobil.deskripsi.isNotEmpty)
                  _baris('Deskripsi : ${mobil.deskripsi}'),
                const SizedBox(height: 4),
                if (mobil.harga > 0) ...[
                  const Text(
                    'Harga tidak termasuk BBM',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),
                  _baris('Harga : ${rupiah(mobil.harga)} / hari'),
                ],
                Text(
                  'Stok : ${mobil.stok}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
