import 'package:flutter/material.dart';
import '../../controllers/supply_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _MitraItem {
  const _MitraItem({
    required this.id,
    required this.name,
    required this.owner,
    required this.phone,
    required this.pending,
  });

  final String id;
  final String name;
  final String owner;
  final String phone;
  final int pending;
}

class SupplyView extends StatefulWidget {
  const SupplyView({super.key});

  @override
  State<SupplyView> createState() => _SupplyViewState();
}

class _SupplyViewState extends State<SupplyView> {
  late final SupplyController _supply;

  @override
  void initState() {
    super.initState();
    _supply = AppControllers.of(context).supply;
    _muat();
  }

  Future<void> _muat() async {
    await _supply.loadMitraList();
    final ok = await _supply.loadSupplies();
    if (!mounted) return;
    setState(() {});
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_supply.errorMessage ?? 'Gagal memuat supply')),
      );
    }
  }

  List<_MitraItem> get _mitra => _supply.mitraList.map((row) {
        final id = row['id_mitra']?.toString() ?? '';
        return _MitraItem(
          id: id,
          name: row['nama_rental']?.toString() ?? '-',
          owner: row['nama_pemilik']?.toString() ?? '-',
          phone: row['no_telepon']?.toString() ?? '-',
          pending: _supply.supplies
              .where((s) =>
                  s['id_mitra']?.toString() == id && s['status'] == 'pending')
              .length,
        );
      }).toList();

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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: _SummaryCard(
                    label: 'Status Supply',
                    value:
                        '${_supply.supplies.length} supply • ${_supply.supplies.where((s) => s['status'] == 'pending').length} menunggu',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 10, sidePadding, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: () async {
                        final hasil = await Navigator.of(context)
                            .pushNamed(AppRoutes.adminAddMitra);
                        if (hasil == true && mounted) _muat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F6FB8).withAlpha(50),
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFF4F6FB8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Tambah Mitra'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _supply,
                    builder: (context, _) {
                      final data = _mitra;
                      return data.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada mitra terdaftar',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                sidePadding,
                                0,
                                sidePadding,
                                16,
                              ),
                              itemCount: data.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = data[index];
                                return _MitraRow(
                                  item: item,
                                  onTap: () async {
                                    await Navigator.of(context).pushNamed(
                                      AppRoutes.adminMitraDetail,
                                      arguments: item.id,
                                    );
                                    if (mounted) _muat();
                                  },
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
        borderRadius: BorderRadius.circular(14),
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
    final color = item.pending > 0
        ? const Color(0xFFFACC15)
        : const Color(0xFF4ADE80);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(14),
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
                    item.owner.isEmpty ? item.phone : item.owner,
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
                '${item.pending} pending',
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