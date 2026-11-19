import 'package:flutter/material.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/mitra_page.dart';
import '../widgets/rentra_scaffold.dart';

class MitraCarFormView extends StatefulWidget {
  final bool isEdit;
  final MitraMobilData? mobil;
  const MitraCarFormView({super.key, this.isEdit = false, this.mobil});

  @override
  State<MitraCarFormView> createState() => _MitraCarFormViewState();
}

class _MitraCarFormViewState extends State<MitraCarFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merk;
  late final TextEditingController _nama;
  late final TextEditingController _nopol;
  late final TextEditingController _kapasitas;
  late final TextEditingController _bbm;
  late final TextEditingController _harga;
  late final TextEditingController _deskripsi;
  late String _transmisi;

  @override
  void initState() {
    super.initState();
    final m = widget.mobil;
    _merk = TextEditingController(text: m?.merk ?? '');
    _nama = TextEditingController(text: m?.nama ?? '');
    _nopol = TextEditingController(text: m?.nopol ?? '');
    _kapasitas =
        TextEditingController(text: m?.kapasitas.replaceAll(' orang', '') ?? '');
    _bbm = TextEditingController(text: m?.bbm ?? '');
    _harga = TextEditingController(text: m == null ? '' : '${m.harga}');
    _deskripsi = TextEditingController(text: m?.deskripsi ?? '');
    _transmisi = m?.spesifikasi == 'Manual' ? 'Manual' : 'Matic';
  }

  @override
  void dispose() {
    for (final c in [_merk, _nama, _nopol, _kapasitas, _bbm, _harga, _deskripsi]) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final hasil = MitraMobilData(
      nama: _nama.text.trim(),
      merk: _merk.text.trim(),
      nopol: _nopol.text.trim(),
      spesifikasi: _transmisi,
      kapasitas: '${_kapasitas.text.trim()} orang',
      bbm: _bbm.text.trim(),
      harga: int.tryParse(_harga.text.trim()) ?? 0,
      status: widget.mobil?.status ?? 'Tersedia',
      deskripsi: _deskripsi.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.isEdit
            ? 'Data mobil diperbarui'
            : 'Mobil berhasil ditambahkan')));
    Navigator.pop(context, hasil);
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );

  Widget _field(String hint, TextEditingController c,
      {TextInputType? type, int lines = 1, bool wajib = true}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      maxLines: lines,
      style: const TextStyle(color: Colors.white, fontSize: 11),
      validator: (v) =>
          wajib && (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
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

  Widget _radio(String v) => GestureDetector(
        onTap: () => setState(() => _transmisi = v),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                _transmisi == v
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: Colors.white,
                size: 14),
            const SizedBox(width: 4),
            Text(v,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
            const SizedBox(width: 14),
          ],
        ),
      );

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
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content:
                                      Text('Pilih foto belum dihubungkan'))),
                          child: Container(
                            width: 70,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      _label('Informasi Umum'),
                      _field('Merk Mobil', _merk),
                      const SizedBox(height: 6),
                      _field('Nama Mobil', _nama),
                      const SizedBox(height: 6),
                      _field('Nomor Polisi', _nopol),
                      _label('Spesifikasi'),
                      Row(children: [
                        const Text('Tipe Transmisi  ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)),
                        _radio('Matic'),
                        _radio('Manual'),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Expanded(
                            child: _field('Kapasitas Penumpang', _kapasitas,
                                type: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: _field('Jenis Bahan Bakar', _bbm)),
                      ]),
                      _label('Harga'),
                      _field('Harga Sewa / Hari', _harga,
                          type: TextInputType.number),
                      _label('Deskripsi'),
                      _field('Deskripsi Tambahan', _deskripsi,
                          lines: 4, wajib: false),
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
                    onTap: () => Navigator.pop(context)),
                SmallButton(label: 'Save', onTap: _simpan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}