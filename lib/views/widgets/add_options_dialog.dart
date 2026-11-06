import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class _AddResult {
  const _AddResult({this.addCar = false, this.dendaAmount});

  final bool addCar;
  final String? dendaAmount;
}

Future<void> showAddOptionsDialog(BuildContext context) async {
  final result = await showDialog<_AddResult>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const _AddOptionsDialog(),
  );

  if (result == null || !context.mounted) return;

  if (result.addCar) {
    Navigator.of(context).pushNamed(AppRoutes.adminAddCar);
    return;
  }

  if (result.dendaAmount != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nominal denda diatur: Rp${result.dendaAmount}')),
    );
  }
}

class _AddOptionsDialog extends StatefulWidget {
  const _AddOptionsDialog();

  @override
  State<_AddOptionsDialog> createState() => _AddOptionsDialogState();
}

class _AddOptionsDialogState extends State<_AddOptionsDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _showDenda = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(_AddResult(dendaAmount: value));
  }

  Widget _buildOpsi() {
    return Column(
      key: const ValueKey('opsi'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _LightButton(
          label: 'Tambah Mobil',
          onTap: () => Navigator.of(context).pop(
            const _AddResult(addCar: true),
          ),
        ),
        const SizedBox(height: 12),
        _LightButton(
          label: 'Atur Denda',
          onTap: () => setState(() => _showDenda = true),
        ),
      ],
    );
  }

  Widget _buildDenda() {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide.none,
    );

    return Column(
      key: const ValueKey('denda'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Masukan Nominal Denda',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.buttonText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            hintText: 'Atur Denda',
            hintStyle: TextStyle(
              color: AppColors.buttonText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: Color(0xFFD3D6E0),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: inputBorder,
          ),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '*Denda dihitung keterlambatan 1 hari',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 8),
          ),
        ),
        const SizedBox(height: 12),
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
              onTap: _save,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1621),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showDenda ? _buildDenda() : _buildOpsi(),
          ),
        ),
      ),
    );
  }
}

class _LightButton extends StatelessWidget {
  const _LightButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD3D6E0),
          foregroundColor: AppColors.buttonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}