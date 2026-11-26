import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatter.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _ActivityItem {
  const _ActivityItem({
    required this.idOrder,
    required this.transactionCode,
    required this.carName,
    required this.customer,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.image,
    required this.status,
    required this.denda,
  });

  final int idOrder;
  final String transactionCode;
  final String carName;
  final String customer;
  final String phone;
  final String startDate;
  final String endDate;
  final String price;
  final String image;
  final String status;
  final num denda;
}

class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  late final OrderController _order;

  List<_ActivityItem> get _items => _order.orders.map(_dariBaris).toList();

  @override
  void initState() {
    super.initState();
    _order = AppControllers.of(context).order;
    _muat();
  }

  Future<void> _muat() async {
    final hasil = await Future.wait([
      _order.loadAllOrders(),
      _order.loadDenda(),
      _order.loadStats(),
    ]);
    if (!hasil.every((e) => e) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_order.errorMessage ?? 'Gagal memuat aktivitas')),
      );
    }
  }

  _ActivityItem _dariBaris(Map<String, dynamic> row) {
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );
    final detail = details.isEmpty ? <String, dynamic>{} : details.first;
    final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();
    final user = (row['user'] as Map?)?.cast<String, dynamic>();
    final mulai = DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '');
    final kembali = DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '');

    num denda = 0;
    for (final d in details) {
      final dendaRows = List<Map<String, dynamic>>.from(
        (d['denda'] as List?) ?? const [],
      );
      for (final itemDenda in dendaRows) {
        denda += (itemDenda['total_denda'] as num?) ?? 0;
      }
    }

    return _ActivityItem(
      idOrder: (row['id_order'] as num?)?.toInt() ?? 0,
      transactionCode: row['transaction_code']?.toString() ?? '-',
      carName: katalog?['nama_mobil']?.toString() ?? '-',
      customer: user?['nama_user']?.toString() ?? '-',
      phone: user?['no_telepon_user']?.toString() ?? '-',
      startDate: Formatter.tanggal(mulai),
      endDate: Formatter.tanggal(kembali),
      price: Formatter.rupiah(row['total_price'] as num?),
      image: katalog?['image']?.toString() ?? '',
      status: row['status']?.toString() ?? '-',
      denda: denda,
    );
  }

  String _today() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day-$month-${now.year}';
  }

  String _angka(String key) =>
      (_order.stats[key]?.toString() ?? '0').padLeft(3, '0');

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
            child: ListenableBuilder(
              listenable: _order,
              builder: (context, _) {
                final items = _items;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    16,
                    sidePadding,
                    16,
                  ),
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
                              value: Formatter.rupiah(
                                _order.stats['total_pendapatan'] as num?,
                              ),
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
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.directions_car_outlined,
                              label: 'Total Mobil',
                              value: _angka('total_mobil'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.key_outlined,
                              label: 'Sewa Aktif',
                              value: _angka('order_ongoing'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Denda tercatat: ${_order.dendaList.length}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_order.isLoading && items.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else if (items.isEmpty)
                        const Center(
                          child: Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _ActivityCard(
                              item: item,
                              onProof: () => Navigator.of(context).pushNamed(
                                AppRoutes.adminPaymentProof,
                                arguments: item.idOrder,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
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
      case 'completed':
        return const Color(0xFF4ADE80);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'ongoing':
      case 'confirmed':
        return const Color(0xFF60A5FA);
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
                    child: item.image.isEmpty
                        ? Image.asset(
                            'assets/images/car1.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFF1F2937)),
                          )
                        : Image.network(
                            item.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFF1F2937)),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                _Chip(
                  label: Formatter.statusOrder(item.status),
                  color: statusColor,
                ),
                if (item.denda > 0) ...[
                  const SizedBox(height: 4),
                  _Chip(
                    label: 'Denda ${Formatter.rupiah(item.denda)}',
                    color: const Color(0xFFEF4444),
                  ),
                ],
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
                _DetailLine(label: 'Kode', value: item.transactionCode),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
