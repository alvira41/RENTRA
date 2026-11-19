import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _MitraItem {
  const _MitraItem({
    required this.name,
    required this.owner,
    required this.online,
  });

  final String name;
  final String owner;
  final bool online;
}

const List<_MitraItem> _dummyMitra = [
  _MitraItem(
    name: 'Rental Mobil Malang',
    owner: 'Pak Hendra',
    online: false,
  ),
  _MitraItem(
    name: 'Batu Car Rental',
    owner: 'Bu Rina',
    online: true,
  ),
  _MitraItem(
    name: 'Arema Trans',
    owner: 'Pak Dimas',
    online: true,
  ),
];

class SupplyView extends StatelessWidget {
  const SupplyView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 3,
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
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: width * 0.3,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 12),
                  child: const Text(
                    'Mitra',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: const _SummaryCard(
                    label: 'Status Supply',
                    value: 'Rp 0.000.000',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 10, sidePadding, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.adminAddMitra),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3D6E0),
                        foregroundColor: AppColors.buttonText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Tambah Mitra'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      0,
                      sidePadding,
                      16,
                    ),
                    itemCount: _dummyMitra.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _MitraRow(
                        item: _dummyMitra[index],
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Detail mitra menyusul'),
                            ),
                          );
                        },
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
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

class _MitraRow extends StatelessWidget {
  const _MitraRow({required this.item, required this.onTap});

  final _MitraItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        item.online ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x40FFFFFF)),
        ),
        child: Row(
          children: [
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
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.owner,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color),
              ),
              child: Text(
                item.online ? 'Online' : 'Offline',
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}