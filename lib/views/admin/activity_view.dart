import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _ActivityItem {
  const _ActivityItem({
    required this.carName,
    required this.customer,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.status,
  });

  final String carName;
  final String customer;
  final String phone;
  final String startDate;
  final String endDate;
  final String price;
  final String status;
}

const List<_ActivityItem> _dummyActivities = [
  _ActivityItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Budi Santoso',
    phone: '081234567890',
    startDate: '10 Nov 2026',
    endDate: '12 Nov 2026',
    price: 'Rp.500.000',
    status: 'Disewa',
  ),
  _ActivityItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Siti Aminah',
    phone: '082198765432',
    startDate: '08 Nov 2026',
    endDate: '10 Nov 2026',
    price: 'Rp.500.000',
    status: 'Selesai',
  ),
  _ActivityItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Andi Wijaya',
    phone: '085611223344',
    startDate: '01 Nov 2026',
    endDate: '04 Nov 2026',
    price: 'Rp.500.000',
    status: 'Terlambat',
  ),
];

class ActivityView extends StatelessWidget {
  const ActivityView({super.key});

  String _today() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day-$month-${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 4,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: width * 0.3,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'AKTIVITAS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Pendapatan',
                          value: 'Rp 0.000.000',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal',
                          value: _today(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.directions_car_outlined,
                          label: 'Total Mobil',
                          value: '000',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.key_outlined,
                          label: 'Sewa Aktif',
                          value: '4',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dummyActivities.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _ActivityCard(
                        item: _dummyActivities[index],
                        onProof: () => Navigator.of(context)
                            .pushNamed(AppRoutes.adminPaymentProof),
                      );
                    },
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(12),
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
            child: Icon(icon, size: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onProof});

  final _ActivityItem item;
  final VoidCallback onProof;

  Color _statusColor() {
    switch (item.status) {
      case 'Selesai':
        return const Color(0xFF4ADE80);
      case 'Terlambat':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFFB923C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.28;
    final statusColor = _statusColor();

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
                _Chip(label: item.status, color: statusColor),
                const SizedBox(height: 4),
                _Chip(
                  label: 'Bukti',
                  color: const Color(0xFFFACC15),
                  onTap: onProof,
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
        height: 1.5,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}