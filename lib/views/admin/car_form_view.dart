import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/admin_bottom_bar.dart';

class CarFormView extends StatefulWidget {
  const CarFormView({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<CarFormView> createState() => _CarFormViewState();
}

class _CarFormViewState extends State<CarFormView> {
  static const List<String> _capacities = [
    '2 orang',
    '4 orang',
    '5 orang',
    '7 orang',
  ];
  static const List<String> _fuels = [
    'Pertamax',
    'Pertalite',
    'Solar',
    'Dexlite',
  ];

  late final TextEditingController _brandController;
  late final TextEditingController _plateController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;

  String _transmission = 'Matic';
  String? _capacity;
  String? _fuel;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(
      text: widget.isEdit ? 'Porsche' : '',
    );
    _plateController = TextEditingController(
      text: widget.isEdit ? 'N V174 OCT' : '',
    );
    _priceController = TextEditingController(
      text: widget.isEdit ? '500000' : '',
    );
    _descController = TextEditingController();
    if (widget.isEdit) {
      _capacity = '2 orang';
      _fuel = 'Pertamax';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _plateController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onSave() {
    FocusScope.of(context).unfocus();

    if (_brandController.text.trim().isEmpty ||
        _plateController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _capacity == null ||
        _fuel == null) {
      _showMessage('Lengkapi data mobil terlebih dahulu');
      return;
    }

    _showMessage(
      widget.isEdit ? 'Data mobil diperbarui' : 'Mobil berhasil ditambahkan',
    );
    Navigator.of(context).pop();
  }

  void _onNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.adminDashboard,
        (route) => false,
      );
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminOrder);
    }
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
        onAddTap: () {},
        onItemSelected: _onNavSelected,
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
                    onTap: () => _showMessage('Fitur unggah foto menyusul'),
                    child: Container(
                      width: uploadWidth,
                      height: uploadWidth * 0.7,
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x66FFFFFF)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 28,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Klik untuk\nunggah foto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Informasi Utama'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Merk Mobil',
                          child: _FormInput(controller: _brandController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LabeledField(
                          label: 'Nomor Polisi',
                          child: _FormInput(controller: _plateController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Spesifikasi'),
                  const SizedBox(height: 8),
                  const _FieldLabel('Tipe Transmisi'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _RadioOption(
                        label: 'Matic',
                        selected: _transmission == 'Matic',
                        onTap: () => setState(() => _transmission = 'Matic'),
                      ),
                      const SizedBox(width: 16),
                      _RadioOption(
                        label: 'Manual',
                        selected: _transmission == 'Manual',
                        onTap: () => setState(() => _transmission = 'Manual'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Kapasitas Penumpang',
                          child: _DropdownBox(
                            value: _capacity,
                            items: _capacities,
                            onChanged: (v) => setState(() => _capacity = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LabeledField(
                          label: 'Jenis Bahan Bakar',
                          child: _DropdownBox(
                            value: _fuel,
                            items: _fuels,
                            onChanged: (v) => setState(() => _fuel = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Harga'),
                  const SizedBox(height: 8),
                  _LabeledField(
                    label: 'Harga Sewa / Hari',
                    child: _FormInput(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Deskripsi'),
                  const SizedBox(height: 8),
                  _LabeledField(
                    label: 'Deskripsi Tambahan:',
                    child: _FormInput(
                      controller: _descController,
                      maxLines: 5,
                    ),
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
                        label: 'Save',
                        fill: const Color(0x333B82F6),
                        border: const Color(0xFF3B82F6),
                        textColor: const Color(0xFF60A5FA),
                        onTap: _onSave,
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
    this.maxLines = 1,
    this.prefixText,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final int maxLines;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
      inputFormatters: formatters,
      minLines: maxLines,
      maxLines: maxLines,
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
  });

  final String? value;
  final List<String> items;
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
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
        ],
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
  final VoidCallback onTap;

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