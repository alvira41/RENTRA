import 'package:flutter/material.dart';
import '../../controllers/base_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/image_picker_helper.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';

class MitraCarFormView extends StatefulWidget {
  const MitraCarFormView({super.key, this.isEdit = false, this.mobil});

  final bool isEdit;
  final MitraMobilData? mobil;

  @override
  State<MitraCarFormView> createState() => _MitraCarFormViewState();
}

class _MitraCarFormViewState extends State<MitraCarFormView> {
  late final KatalogController _katalog;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _stok;
  String? _idKategori;
  UploadFile? _foto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _katalog = AppControllers.of(context).katalog;
    _nama = TextEditingController(text: widget.mobil?.nama ?? '');
    _stok = TextEditingController(
        text: widget.mobil == null ? '' : '${widget.mobil!.stok}');
    _muat();
  }

  Future<void> _muat() async {
    await _katalog.loadCategories();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nama.dispose();
    _stok.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final file = await pickUploadFile();
    if (file == null) return;
    setState(() => _foto = file);
  }

  int? get _kategoriTerpilih =>
      int.tryParse(_idKategori ?? '') ?? _kategoriDariNama(widget.mobil?.merk);

  int? _kategoriDariNama(String? nama) {
    if (nama == null || nama.isEmpty || nama == '-') return null;
    for (final row in _katalog.categories) {
      if (row['name']?.toString() == nama) {
        return (row['id_category'] as num?)?.toInt();
      }
    }
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final stok = int.tryParse(_stok.text.trim());
    final kategori = _kategoriTerpilih;
    if (stok == null || stok < 0) {
      _pesan('Stok harus berupa angka dan tidak negatif');
      return;
    }
    if (kategori == null) {
      _pesan('Pilih kategori mobil dulu');
      return;
    }

    setState(() => _loading = true);
    final bool ok;
    if (widget.isEdit && widget.mobil != null && widget.mobil!.id > 0) {
      ok = await _katalog.updateKatalogMitra(
        widget.mobil!.id,
        namaMobilMitra: _nama.text.trim(),
        totalStockMitra: stok,
        idCategoryMitra: kategori,
        fotoBaru: _foto,
      );
    } else {
      ok = await _katalog.addKatalogMitra(
        namaMobilMitra: _nama.text.trim(),
        totalStockMitra: stok,
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
    _pesan(widget.isEdit
        ? 'Data mobil diperbarui'
        : 'Mobil berhasil ditambahkan');
    Navigator.pop(context, true);
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(t,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            )),
      );

  Widget _field(String hint, TextEditingController c,
      {TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 11),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 11),
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        errorStyle: const TextStyle(fontSize: 10),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
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
                            width: 90,
                            height: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: _foto == null
                                ? const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colors.white,
                                    size: 24)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          color: Color(0xFF4ADE80), size: 20),
                                      Text(
                                        _foto!.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      _label('Informasi Mobil'),
                      _field('Nama Mobil', _nama),
                      const SizedBox(height: 6),
                      _field('Total Stok', _stok,
                          type: TextInputType.number),
                      _label('Kategori'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _kategoriTerpilih?.toString(),
                            isExpanded: true,
                            dropdownColor: const Color(0xFF111B2E),
                            hint: const Text('Pilih kategori',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                            items: [
                              for (final row in _katalog.categories)
                                DropdownMenuItem<String>(
                                  value: (row['id_category'] as num)
                                      .toInt()
                                      .toString(),
                                  child: Text(
                                    row['name']?.toString() ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                            onChanged: (v) =>
                                setState(() => _idKategori = v),
                          ),
                        ),
                      ),
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
