import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class _CarItem {
  const _CarItem({
    required this.name,
    required this.brand,
    required this.plate,
    required this.spec,
    required this.capacity,
    required this.fuel,
    required this.price,
    required this.available,
  });

  final String name;
  final String brand;
  final String plate;
  final String spec;
  final String capacity;
  final String fuel;
  final String price;
  final bool available;
}

const List<_CarItem> _dummyCars = [
  _CarItem(
    name: 'PORSCHE 911 GT3 RS',
    brand: 'Porsche',
    plate: 'N V174 OCT',
    spec: 'Manic',
    capacity: '2 orang',
    fuel: 'Pertamax',
    price: 'Rp.500.000 / hari',
    available: true,
  ),
  _CarItem(
    name: 'PORSCHE 911 GT3 RS',
    brand: 'Porsche',
    plate: 'N V174 OCT',
    spec: 'Manic',
    capacity: '2 orang',
    fuel: 'Pertamax',
    price: 'Rp.500.000 / hari',
    available: true,
  ),
  _CarItem(
    name: 'PORSCHE 911 GT3 RS',
    brand: 'Porsche',
    plate: 'N V174 OCT',
    spec: 'Manic',
    capacity: '2 orang',
    fuel: 'Pertamax',
    price: 'Rp.500.000 / hari',
    available: true,
  ),
  _CarItem(
    name: 'PORSCHE 911 GT3 RS',
    brand: 'Porsche',
    plate: 'N V174 OCT',
    spec: 'Manic',
    capacity: '2 orang',
    fuel: 'Pertamax',
    price: 'Rp.500.000 / hari',
    available: true,
  ),
];

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Future<void> _openAddDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _AddDialog(),
    );

    if (result == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nominal denda diatur: Rp$result')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _AdminBottomBar(
        onAddTap: () => _openAddDialog(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo_rentra.png',
                        width: width * 0.3,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3157),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4F6FB8)),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 8),
                  child: const Text(
                    'DASHBOARD ADMIN',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      8,
                      sidePadding,
                      16,
                    ),
                    itemCount: _dummyCars.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _CarCard(item: _dummyCars[index]),
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

class _CarCard extends StatelessWidget {
  const _CarCard({required this.item});

  final _CarItem item;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.26;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
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
                    child: Image.asset(
                      'assets/images/car1.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF1F2937)),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _StatusChip(available: item.available),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MiniIconButton(icon: Icons.edit_outlined, onTap: () {}),
                    const SizedBox(width: 8),
                    _MiniIconButton(icon: Icons.delete_outline, onTap: () {}),
                  ],
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
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                _DetailLine(label: 'Merk Mobil', value: item.brand),
                _DetailLine(label: 'Nomor Polisi', value: item.plate),
                _DetailLine(label: 'Spesifikasi', value: item.spec),
                _DetailLine(label: 'Kapasitas penumpang', value: item.capacity),
                _DetailLine(label: 'Jenis BBM', value: item.fuel),
                const SizedBox(height: 4),
                const Text(
                  'Harga tidak termasuk BBM',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                Text(
                  item.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label : $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 9,
        height: 1.4,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color =
        available ? const Color(0xFF4ADE80) : const Color(0xFFFB923C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Text(
        available ? 'Tersedia' : 'Disewa',
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x80FFFFFF)),
        ),
        child: Icon(icon, size: 13, color: AppColors.textPrimary),
      ),
    );
  }
}

class _AdminBottomBar extends StatelessWidget {
  const _AdminBottomBar({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1420),
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const _NavIcon(icon: Icons.home_rounded, active: true),
              const _NavIcon(icon: Icons.error_outline_rounded),
              _NavIcon(icon: Icons.add_rounded, onTap: onAddTap),
              const _NavIcon(icon: Icons.handshake_outlined),
              const _NavIcon(icon: Icons.edit_note_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, this.active = false, this.onTap});

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFF2A3550) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 22,
          color: active ? AppColors.textPrimary : AppColors.primary,
        ),
      ),
    );
  }
}

class _AddDialog extends StatefulWidget {
  const _AddDialog();

  @override
  State<_AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<_AddDialog> {
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
    Navigator.of(context).pop(value);
  }

  Widget _buildOpsi() {
    return Column(
      key: const ValueKey('opsi'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _LightButton(
          label: 'Tambah Mobil',
          onTap: () => Navigator.of(context).pop(),
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