import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/base_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/image_picker_helper.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class CarFormView extends StatefulWidget {
  const CarFormView({super.key, this.isEdit = false, this.idMobil});

  final bool isEdit;
  final int? idMobil;

  @override
  State<CarFormView> createState() => _CarFormViewState();
}

class _CarFormViewState extends State<CarFormView> {
  late final KatalogController _katalog;
  late final TextEditingController _namaController;
  late final TextEditingController _stokController;
  late final TextEditingController _priceController;

  String? _idKategori;
  UploadFile? _foto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _katalog = AppControllers.of(context).katalog;
    _namaController = TextEditingController();
    _stokController = TextEditingController(text: '1');
    _priceController = TextEditingController();
    _muat();
  }

  Future<void> _muat() async {
    await _katalog.loadCategories();
    if (widget.isEdit && widget.idMobil != null) {
      final mobil = await _katalog.getKatalogById(widget.idMobil!);
      if (mobil == null || !mounted) return;
      _namaController.text = mobil['nama_mobil']?.toString() ?? '';
      _priceController.text = (mobil['price'] as num?)?.toString() ?? '';
      _stokController.text = (mobil['total_stock'] as num?)?.toString() ?? '1';
      _idKategori = (mobil['id_category'] as num?)?.toInt().toString();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    final nama = _namaController.text.trim();
    final harga = num.tryParse(_priceController.text.trim());
    final stok = int.tryParse(_stokController.text.trim());
    final kategori = int.tryParse(_idKategori ?? '');

    if (nama.isEmpty || harga == null || harga <= 0 || stok == null || stok < 0) {
      _showMessage('Lengkapi data mobil terlebih dahulu');
      return;
    }
    if (kategori == null) {
      _showMessage('Pilih kategori mobil terlebih dahulu');
      return;
    }

    setState(() => _loading = true);
    final bool ok;
    if (widget.isEdit && widget.idMobil != null) {
      ok = await _katalog.updateKatalog(
        widget.idMobil!,
        idCategory: kategori,
        namaMobil: nama,
        price: harga,
        totalStock: stok,
        fotoBaru: _foto,
      );
    } else {
      ok = await _katalog.addKatalog(
        idCategory: kategori,
        namaMobil: nama,
        price: harga,
        totalStock: stok,
        foto: _foto,
      );
    }
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      _showMessage(_katalog.errorMessage ?? 'Data mobil gagal disimpan');
      return;
    }
    _showMessage(
      widget.isEdit ? 'Data mobil diperbarui' : 'Mobil berhasil ditambahkan',
    );
    Navigator.of(context).pop();
  }

  Future<void> _pilihFoto() async {
    final file = await pickUploadFile();
    if (file == null) return;
    setState(() => _foto = file);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.07;
    final uploadWidth = width * 0.42;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: widget.isEdit ? -1 : 2,
        onAddTap: () => showAddOptionsDialog(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/background.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(sidePadding, 20, sidePadding, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEdit ? 'Edit Data Mobil' : 'TAMBAH MOBIL BARU',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _SectionTitle('Unggah Foto Mobil'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pilihFoto,
                    child: Container(
                      width: uploadWidth,
                      height: uploadWidth * 0.7,
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x66FFFFFF)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 28,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _foto?.name ?? 'Klik untuk\nunggah foto',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Informasi Mobil'),
                  const SizedBox(height: 8),
                  _LabeledField(
                    label: 'Nama Mobil',
                    child: _FormInput(controller: _namaController),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Kategori',
                    child: _DropdownBox(
                      value: _idKategori,
                      items: [
                        for (final k in _katalog.categories)
                          (k['id_category'] as num).toInt().toString(),
                      ],
                      labels: {
                        for (final k in _katalog.categories)
                          (k['id_category'] as num).toInt().toString():
                              k['name']?.toString() ?? '-',
                      },
                      onChanged: (v) => setState(() => _idKategori = v),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Harga dan Stok'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Harga Sewa / Hari',
                          child: _FormInput(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            formatters: [FilteringTextInputFormatter.digitsOnly],
                            prefixText: 'Rp ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LabeledField(
                          label: 'Total Stok',
                          child: _FormInput(
                            controller: _stokController,
                            keyboardType: TextInputType.number,
                            formatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PillButton(
                        label: 'Cancel',
                        fill: const Color(0x33EF4444),
                        border: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _PillButton(
                        label: _loading ? 'Menyimpan...' : 'Save',
                        fill: const Color(0x333B82F6),
                        border: const Color(0xFF3B82F6),
                        textColor: const Color(0xFF60A5FA),
                        onTap: _loading ? null : _onSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 9,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.controller,
    this.keyboardType,
    this.formatters,
    this.prefixText,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      maxLines: 1,
      style: const TextStyle(
        color: AppColors.buttonText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFD3D6E0),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: AppColors.buttonText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
    this.labels,
  });

  final String? value;
  final List<String> items;
  final Map<String, String>? labels;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD3D6E0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFFD3D6E0),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.buttonText,
            size: 18,
          ),
          style: const TextStyle(
            color: AppColors.buttonText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(labels?[item] ?? item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.fill,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color fill;
  final Color border;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}