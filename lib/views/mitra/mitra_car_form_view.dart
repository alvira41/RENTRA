import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/base_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/image_picker_helper.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';

class MitraCarFormView extends StatefulWidget {
  const MitraCarFormView({super.key, this.isEdit = false, this.mobil});

  final bool isEdit;
  final Map<String, dynamic>? mobil;

  @override
  State<MitraCarFormView> createState() => _MitraCarFormViewState();
}

class _MitraCarFormViewState extends State<MitraCarFormView> {
  final _formKey = GlobalKey<FormState>();
  late final KatalogController _katalog;
  late final TextEditingController _merk;
  late final TextEditingController _nama;
  late final TextEditingController _nopol;
  late final TextEditingController _kapasitas;
  late final TextEditingController _bbm;
  late final TextEditingController _harga;
  late final TextEditingController _deskripsi;

  String? _idKategori;
  UploadFile? _foto;
  bool _loading = false;
  bool _kategoriSiap = false;

  @override
  void initState() {
    super.initState();
    _katalog = AppControllers.of(context).katalog;
    final m = widget.mobil;
    String teks(List<String> keys) {
      for (final key in keys) {
        final value = m?[key];
        if (value == null) continue;
        final s = value.toString().trim();
        if (s.isNotEmpty && s != '-') return s;
      }
      return '';
    }

    _merk = TextEditingController(text: teks(const ['merk', 'merk_mobil']));
    _nama = TextEditingController(text: m?['nama_mobil_mitra']?.toString() ?? '');
    _nopol = TextEditingController(text: teks(const ['nopol', 'no_polisi']));
    _kapasitas = TextEditingController(
        text: teks(const ['kapasitas', 'kapasitas_penumpang']));
    _bbm = TextEditingController(text: teks(const ['bbm', 'jenis_bbm']));
    _harga = TextEditingController(text: teks(const ['price', 'harga']));
    _deskripsi = TextEditingController(text: teks(const ['deskripsi', 'keterangan']));
    _idKategori = (m?['id_category_mitra'] as num?)?.toInt().toString();
    _muatKategori();
  }

  @override
  void dispose() {
    for (final c in [_merk, _nama, _nopol, _kapasitas, _bbm, _harga, _deskripsi]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _muatKategori() async {
    final ok = await _katalog.loadCategories();
    if (!mounted) return;
    if (!ok) {
      _pesan(_katalog.errorMessage ?? 'Kategori gagal dimuat');
    }
    final ada = _katalog.categories.any(
      (k) => (k['id_category'] as num).toInt().toString() == _idKategori,
    );
    setState(() {
      if (!ada) _idKategori = null;
      _kategoriSiap = true;
    });
  }

  void _ulangiKategori() {
    setState(() => _kategoriSiap = false);
    _muatKategori();
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _pilihFoto() async {
    final file = await pickUploadFile();
    if (file == null) return;
    setState(() => _foto = file);
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final kategori = int.tryParse(_idKategori ?? '');
    if (kategori == null) {
      _pesan('Pilih tipe transmisi terlebih dahulu');
      return;
    }

    setState(() => _loading = true);
    final bool ok;
    if (widget.isEdit && widget.mobil != null) {
      ok = await _katalog.updateKatalogMitra(
        (widget.mobil!['id_mobil_mitra'] as num).toInt(),
        namaMobilMitra: _nama.text.trim(),
        idCategoryMitra: kategori,
        fotoBaru: _foto,
      );
    } else {
      ok = await _katalog.addKatalogMitra(
        namaMobilMitra: _nama.text.trim(),
        totalStockMitra: 1,
        idCategoryMitra: kategori,
        foto: _foto,
      );
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      _pesan(_katalog.errorMessage ?? 'Data mobil gagal disimpan');
      return;
    }
    _pesan(widget.isEdit ? 'Data mobil diperbarui' : 'Mobil berhasil ditambahkan');
    Navigator.pop(context, true);
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(
          t,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _field(
    String hint,
    TextEditingController c, {
    TextInputType? type,
    List<TextInputFormatter>? formatters,
    int lines = 1,
    bool wajib = false,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      inputFormatters: formatters,
      maxLines: lines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
      validator: (v) =>
          wajib && (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        isDense: true,
        filled: true,
        fillColor: const Color(0x14FFFFFF),
        errorStyle: const TextStyle(fontSize: 10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)),
        ),
      ),
    );
  }

  Widget _radio(String id, String nama) => GestureDetector(
        onTap: () => setState(() => _idKategori = id),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _idKategori == id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: AppColors.textPrimary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              nama,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      );

  Widget _pilihanTransmisi() {
    if (!_kategoriSiap) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_katalog.categories.isEmpty) {
      return Row(
        children: [
          const Text(
            'Kategori kosong atau gagal dimuat',
            style: TextStyle(color: Color(0xFFEF4444), fontSize: 10),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _ulangiKategori,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }
    return Wrap(
      children: [
        for (final k in _katalog.categories)
          _radio(
            (k['id_category'] as num).toInt().toString(),
            (k['nama'] ?? k['name'])?.toString() ?? '-',
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MitraPage(
      title: widget.isEdit ? 'EDIT DATA MOBIL' : 'TAMBAH MOBIL BARU',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Unggah Foto Mobil'),
                      Center(
                        child: GestureDetector(
                          onTap: _pilihFoto,
                          child: Container(
                            width: 84,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0x4DFFFFFF)),
                            ),
                            child: _foto == null
                                ? const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Center(
                                      child: Text(
                                        _foto!.name,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      _label('Informasi Umum'),
                      _field('Merk Mobil', _merk),
                      const SizedBox(height: 6),
                      _field('Nama Mobil', _nama, wajib: true),
                      const SizedBox(height: 6),
                      _field('Nomor Polisi', _nopol),
                      _label('Spesifikasi'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Tipe Transmisi  ',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                          Expanded(child: _pilihanTransmisi()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              'Kapasitas Penumpang',
                              _kapasitas,
                              type: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _field('Jenis Bahan Bakar', _bbm)),
                        ],
                      ),
                      _label('Harga'),
                      _field(
                        'Harga Sewa / Hari',
                        _harga,
                        type: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      _label('Deskripsi'),
                      _field('Deskripsi Tambahan', _deskripsi, lines: 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallButton(
                  label: 'Cancel',
                  color: const Color(0xFFEF4444),
                  onTap: () => Navigator.pop(context),
                ),
                SmallButton(
                  label: _loading ? 'Menyimpan...' : 'Save',
                  onTap: _loading ? null : _simpan,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}