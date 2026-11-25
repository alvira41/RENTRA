import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/formatter.dart';

class PaymentProofView extends StatefulWidget {
  const PaymentProofView({super.key, this.idOrder});

  final int? idOrder;

  @override
  State<PaymentProofView> createState() => _PaymentProofViewState();
}

class _PaymentProofViewState extends State<PaymentProofView> {
  late final OrderController _order;
  late final Future<String?> _buktiFuture;

  @override
  void initState() {
    super.initState();
    _order = AppControllers.of(context).order;
    _buktiFuture = _muat();
  }

  Future<String?> _muat() async {
    if (widget.idOrder == null) return null;
    await _order.loadOrderDetail(widget.idOrder!);
    final path = _order.selectedOrder?['bukti_payment']?.toString();
    return _order.buktiUrl(path == null || path.isEmpty ? null : path);
  }

  String? _aksi() {
    final status = _order.selectedOrder?['status']?.toString();
    if (status == 'pending') return 'Konfirmasi';
    if (status == 'confirmed') return 'Mulai Sewa';
    return null;
  }

  Future<void> _proses() async {
    final id = widget.idOrder;
    if (id == null) return;
    final status = _order.selectedOrder?['status']?.toString();
    final bool ok;
    if (status == 'pending') {
      ok = await _order.confirmOrder(id, refreshStatus: 'pending');
    } else if (status == 'confirmed') {
      ok = await _order.startOrder(id, refreshStatus: 'confirmed');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada aksi untuk status ini')),
        );
      }
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Aksi berhasil diproses'
              : _order.errorMessage ?? 'Aksi gagal diproses',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.08;

    return Scaffold(
      backgroundColor: AppColors.background,
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
            child: ListenableBuilder(
              listenable: _order,
              builder: (context, _) {
                final order = widget.idOrder == null ? null : _order.selectedOrder;
                final valid = order != null &&
                    (order['id_order'] as num?)?.toInt() == widget.idOrder;
                final row = valid ? order : <String, dynamic>{};
                final aksi = valid ? _aksi() : null;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sidePadding,
                          16,
                          sidePadding,
                          16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: width * 0.3,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (!valid && _order.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (!valid)
                              const Center(
                                child: Text(
                                  'Pilih pesanan terlebih dahulu',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else ...[
                              _TotalCard(
                                total: Formatter.rupiah(row['total_price'] as num?),
                              ),
                              const SizedBox(height: 12),
                              _InfoCard(
                                status: Formatter.statusOrder(row['status']?.toString()),
                                method: 'Transfer Bank',
                                date: _waktu(row['created_at']?.toString()),
                                orderId: row['transaction_code']?.toString() ?? '-',
                                customer:
                                    (row['app_user'] as Map?)?['nama_user']?.toString() ??
                                    '-',
                                phone: (row['app_user'] as Map?)?['no_telepon_user']
                                        ?.toString() ??
                                    '-',
                                details: _detailMobil(row),
                              ),
                              const SizedBox(height: 18),
                              const Center(
                                child: Text(
                                  'Bukti Pembayaran',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<String?>(
                                future: _buktiFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return _ProofBox(url: snapshot.data);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        0,
                        sidePadding,
                        16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PillButton(
                            label: 'Back',
                            color: AppColors.textPrimary,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          if (aksi != null)
                            _PillButton(
                              label: aksi,
                              color: const Color(0xFF4ADE80),
                              onTap: _proses,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _waktu(String? iso) {
    final waktu = DateTime.tryParse(iso ?? '');
    if (waktu == null) return '-';
    final jam = waktu.hour.toString().padLeft(2, '0');
    final menit = waktu.minute.toString().padLeft(2, '0');
    return '${Formatter.tanggal(waktu)}, $jam:$menit';
  }

  List<String> _detailMobil(Map<String, dynamic> row) {
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );
    return details.map((detail) {
      final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();
      final mulai = DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '');
      final kembali = DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '');
      return '${katalog?['nama_mobil'] ?? '-'} | ${Formatter.tanggal(mulai)} - '
          '${Formatter.tanggal(kembali)} | ${Formatter.rupiah(detail['subtotal'] as num?)}';
    }).toList();
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: child,
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.status,
    required this.method,
    required this.date,
    required this.orderId,
    required this.customer,
    required this.phone,
    required this.details,
  });

  final String status;
  final String method;
  final String date;
  final String orderId;
  final String customer;
  final String phone;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Status',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80).withAlpha(40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4ADE80)),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.credit_card_outlined,
            label: 'Metode Pembayaran',
            trailing: _ValueText(method),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Dan Waktu',
            trailing: _ValueText(date),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.description_outlined,
            label: 'ID Order',
            trailing: _ValueText(orderId),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Nama',
            trailing: _ValueText(customer),
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'No Telepon',
            trailing: _ValueText(phone),
          ),
          const _RowDivider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Sewa',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              ...(details.isEmpty
                  ? [
                      const Text(
                        '-',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 9,
                        ),
                      ),
                    ]
                  : details.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: trailing),
      ],
    );
  }
}

class _ValueText extends StatelessWidget {
  const _ValueText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, thickness: 0.5, color: Color(0x40FFFFFF)),
    );
  }
}

class _ProofBox extends StatelessWidget {
  const _ProofBox({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: width * 0.55,
        height: width * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: url == null || url!.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 36,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bukti belum diunggah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 36,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bukti tidak dapat ditampilkan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
