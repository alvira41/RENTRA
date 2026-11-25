import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/formatter.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _OrderItem {
  const _OrderItem({
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
    required this.detailCount,
    this.buktiPayment,
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
  final int detailCount;
  final String? buktiPayment;
}

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  late final OrderController _order;

  List<_OrderItem> get _orders => _order.orders.map(_dariBaris).toList();

  @override
  void initState() {
    super.initState();
    _order = AppControllers.of(context).order;
    _muat();
  }

  Future<void> _muat() async {
    final ok = await _order.loadAllOrders(status: 'pending');
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_order.errorMessage ?? 'Gagal memuat pesanan')),
      );
    }
  }

  _OrderItem _dariBaris(Map<String, dynamic> row) {
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );
    final detail = details.isEmpty ? <String, dynamic>{} : details.first;
    final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();
    final user = (row['app_user'] as Map?)?.cast<String, dynamic>();
    final mulai = DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '');
    final kembali = DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '');

    return _OrderItem(
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
      detailCount: details.length,
      buktiPayment: row['bukti_payment']?.toString(),
    );
  }

  Future<void> _onConfirm(_OrderItem item) async {
    final ok = await _order.confirmOrder(
      item.idOrder,
      refreshStatus: 'pending',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Pesanan ${item.customer} dikonfirmasi'
              : _order.errorMessage ?? 'Pesanan gagal dikonfirmasi',
        ),
      ),
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
                  child: ListenableBuilder(
                    listenable: _order,
                    builder: (context, _) {
                      final items = _orders;
                      if (_order.isLoading && items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return items.isEmpty
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
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _OrderCard(
                                  item: item,
                                  onConfirm: () => _onConfirm(item),
                                  onProof: () => Navigator.of(context).pushNamed(
                                    AppRoutes.adminPaymentProof,
                                    arguments: item.idOrder,
                                  ),
                                  onReturn: () => Navigator.of(context).pushNamed(
                                    AppRoutes.adminReturn,
                                    arguments: item.idOrder,
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.onConfirm,
    required this.onProof,
    required this.onReturn,
  });

  final _OrderItem item;
  final VoidCallback onConfirm;
  final VoidCallback onProof;
  final VoidCallback onReturn;

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
                _ActionChip(
                  label: 'Confirm',
                  color: const Color(0xFF3B82F6),
                  onTap: onConfirm,
                ),
                const SizedBox(height: 4),
                _ActionChip(
                  label: item.buktiPayment == null || item.buktiPayment!.isEmpty
                      ? 'Bukti -'
                      : 'Bukti',
                  color: const Color(0xFFFACC15),
                  onTap: onProof,
                ),
                const SizedBox(height: 4),
                _ActionChip(
                  label: 'Kembalikan',
                  color: const Color(0xFF4ADE80),
                  onTap: onReturn,
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
                _DetailLine(label: 'Status', value: Formatter.statusOrder(item.status)),
                _DetailLine(label: 'Nama', value: item.customer),
                _DetailLine(label: 'No telepon', value: item.phone),
                _DetailLine(label: 'Tanggal sewa', value: item.startDate),
                _DetailLine(label: 'Tanggal kembali', value: item.endDate),
                _DetailLine(label: 'Jumlah mobil', value: '${item.detailCount}'),
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
