import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _ReturnItem {
  const _ReturnItem({
    required this.carName,
    required this.customer,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.price,
  });

  final String carName;
  final String customer;
  final String phone;
  final String startDate;
  final String endDate;
  final String price;
}

const List<_ReturnItem> _dummyReturns = [
  _ReturnItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Budi Santoso',
    phone: '081234567890',
    startDate: '10 Nov 2026',
    endDate: '12 Nov 2026',
    price: 'Rp.500.000',
  ),
  _ReturnItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Siti Aminah',
    phone: '082198765432',
    startDate: '11 Nov 2026',
    endDate: '14 Nov 2026',
    price: 'Rp.500.000',
  ),
  _ReturnItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Andi Wijaya',
    phone: '085611223344',
    startDate: '13 Nov 2026',
    endDate: '15 Nov 2026',
    price: 'Rp.500.000',
  ),
];

class ReturnView extends StatefulWidget {
  const ReturnView({super.key});

  @override
  State<ReturnView> createState() => _ReturnViewState();
}

class _ReturnViewState extends State<ReturnView> {
  late final List<_ReturnItem> _items;
  final Set<_ReturnItem> _selected = {};

  @override
  void initState() {
    super.initState();
    _items = List<_ReturnItem>.of(_dummyReturns);
  }

  void _toggle(_ReturnItem item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  void _onReturn() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mobil yang dikembalikan')),
      );
      return;
    }

    final count = _selected.length;
    setState(() {
      _items.removeWhere(_selected.contains);
      _selected.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count mobil dikembalikan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 1,
        onAddTap: () => showAddOptionsDialog(context),
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
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: width * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 8),
                  child: const Text(
                    'Pengembalian',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada mobil yang perlu dikembalikan',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            sidePadding,
                            8,
                            sidePadding,
                            12,
                          ),
                          itemCount: _items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _ReturnCard(
                              item: item,
                              checked: _selected.contains(item),
                              onToggle: () => _toggle(item),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 4, sidePadding, 14),
                  child: Row(
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
                        label: 'Kembali',
                        fill: const Color(0x333B82F6),
                        border: const Color(0xFF3B82F6),
                        textColor: const Color(0xFF60A5FA),
                        onTap: _onReturn,
                      ),
                    ],
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

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.item,
    required this.checked,
    required this.onToggle,
  });

  final _ReturnItem item;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.28;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked
                ? const Color(0xFF60A5FA)
                : const Color(0x40FFFFFF),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageWidth,
              child: ClipRRect(
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
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.carName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'Nama', value: item.customer),
                  _DetailLine(label: 'No telepon', value: item.phone),
                  _DetailLine(label: 'Tanggal sewa', value: item.startDate),
                  _DetailLine(label: 'Tanggal kembali', value: item.endDate),
                  const SizedBox(height: 6),
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
            const SizedBox(width: 6),
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ],
        ),
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
        height: 1.5,
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