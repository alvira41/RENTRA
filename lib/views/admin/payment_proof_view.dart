import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PaymentProofView extends StatelessWidget {
  const PaymentProofView({super.key});

  static const String _total = 'Rp.5.600.000';
  static const String _status = 'Berhasil';
  static const String _method = 'Transfer Bank';
  static const String _date = '2 Oktober 2025';
  static const String _orderId = 'ORD-20251002-001';

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
            child: Column(
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
                        const _TotalCard(total: _total),
                        const SizedBox(height: 12),
                        const _InfoCard(
                          status: _status,
                          method: _method,
                          date: _date,
                          orderId: _orderId,
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
                        const _ProofBox(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.textPrimary),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(12),
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
  });

  final String status;
  final String method;
  final String date;
  final String orderId;

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
  const _ProofBox();

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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: Color(0xFF6B7280),
            ),
            SizedBox(height: 8),
            Text(
              'Bukti transfer user',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}