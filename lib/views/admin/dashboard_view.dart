import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

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

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final List<_CarItem> _cars;

  @override
  void initState() {
    super.initState();
    _cars = List<_CarItem>.of(_dummyCars);
  }

  Future<void> _confirmDelete(_CarItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F1621),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        title: const Text(
          'Hapus mobil?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Data ${item.name} akan dihapus dari katalog.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cars.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mobil dihapus')),
    );
  }

  void _onNavSelected(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed(AppRoutes.adminOrder);
      return;
    }
    if (index == 3 || index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Halaman ini menyusul')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 0,
        onAddTap: () => showAddOptionsDialog(context),
        onItemSelected: _onNavSelected,
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
                        'assets/images/logo.png',
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
                  child: _cars.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada mobil di katalog',
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
                            16,
                          ),
                          itemCount: _cars.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _cars[index];
                            return _CarCard(
                              item: item,
                              onEdit: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.adminEditCar),
                              onDelete: () => _confirmDelete(item),
                            );
                          },
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
  const _CarCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final _CarItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                    _MiniIconButton(
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _MiniIconButton(
                      icon: Icons.delete_outline,
                      onTap: onDelete,
                    ),
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