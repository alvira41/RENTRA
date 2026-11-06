import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _OrderItem {
  const _OrderItem({
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

const List<_OrderItem> _dummyOrders = [
  _OrderItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Budi Santoso',
    phone: '081234567890',
    startDate: '10 Nov 2026',
    endDate: '12 Nov 2026',
    price: 'Rp.500.000',
  ),
  _OrderItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Siti Aminah',
    phone: '082198765432',
    startDate: '11 Nov 2026',
    endDate: '14 Nov 2026',
    price: 'Rp.500.000',
  ),
  _OrderItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Andi Wijaya',
    phone: '085611223344',
    startDate: '13 Nov 2026',
    endDate: '15 Nov 2026',
    price: 'Rp.500.000',
  ),
  _OrderItem(
    carName: 'PORSCHE 911 GT3 RS',
    customer: 'Dewi Lestari',
    phone: '087755667788',
    startDate: '15 Nov 2026',
    endDate: '18 Nov 2026',
    price: 'Rp.500.000',
  ),
];

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  late final List<_OrderItem> _orders;

  @override
  void initState() {
    super.initState();
    _orders = List<_OrderItem>.of(_dummyOrders);
  }

  void _handleDecision(_OrderItem item, String message) {
    setState(() => _orders.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.adminDashboard,
        (route) => false,
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
        currentIndex: 1,
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
                    'KONFIRMASI PESANAN',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(
                  child: _orders.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada pesanan masuk',
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
                          itemCount: _orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _orders[index];
                            return _OrderCard(
                              item: item,
                              onConfirm: () => _handleDecision(
                                item,
                                'Pesanan ${item.customer} dikonfirmasi',
                              ),
                              onReject: () => _handleDecision(
                                item,
                                'Pesanan ${item.customer} ditolak',
                              ),
                              onDetail: () =>
                                  _showMessage('Detail pesanan menyusul'),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.onConfirm,
    required this.onReject,
    required this.onDetail,
  });

  final _OrderItem item;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.28;

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
                _ActionChip(
                  label: 'Confirm',
                  color: const Color(0xFF3B82F6),
                  onTap: onConfirm,
                ),
                const SizedBox(height: 4),
                _ActionChip(
                  label: 'Tolak',
                  color: const Color(0xFFEF4444),
                  onTap: onReject,
                ),
                const SizedBox(height: 4),
                _ActionChip(
                  label: 'Detail',
                  color: const Color(0xFF4ADE80),
                  onTap: onDetail,
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

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