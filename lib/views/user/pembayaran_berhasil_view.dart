import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/rentra_scaffold.dart';
import 'checkout_view.dart';
import 'dashboard_user_view.dart';

class PembayaranBerhasilView extends StatefulWidget {
  const PembayaranBerhasilView({super.key, required this.pesanan});

  final PesananData pesanan;

  @override
  State<PembayaranBerhasilView> createState() => _PembayaranBerhasilViewState();
}

class _PembayaranBerhasilViewState extends State<PembayaranBerhasilView> {
  late final DateTime _waktu;
  late final String _idOrder;

  @override
  void initState() {
    super.initState();
    _waktu = DateTime.now();
    _idOrder = _waktu.millisecondsSinceEpoch.toString();
  }

  void _selesai() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardUserView()),
      (route) => false,
    );
  }

  Widget _info(IconData icon, String label, Widget nilai) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 10),
              ),
            ),
            nilai,
          ],
        ),
      );

  Widget _teks(String t) => Text(
        t,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _garisSkeleton(double lebar) => Container(
        width: lebar,
        height: 5,
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(3),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final side = width * 0.06;
    final p = widget.pesanan;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RentraBackground(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(side, 16, side, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: width * 0.3,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4ADE80),
                            ),
                            child: const Icon(Icons.check_rounded,
                                size: 64, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Pembayaran Berhasil',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Terima kasih, pembayaran telah diterima',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 9),
                          ),
                          const SizedBox(height: 18),
                          GlassCard(
                            radius: 10,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined,
                                    size: 20, color: AppColors.textPrimary),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Pembayaran',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      rupiah(p.total),
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassCard(
                            radius: 10,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            child: Column(
                              children: [
                                _info(
                                  Icons.check_circle,
                                  'Status',
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ADE80)
                                          .withAlpha(40),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFF4ADE80)),
                                    ),
                                    child: const Text(
                                      'Berhasil',
                                      style: TextStyle(
                                        color: Color(0xFF4ADE80),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                _info(Icons.credit_card_outlined,
                                    'Metode Pembayaran', _teks('Transfer Bank')),
                                _info(
                                  Icons.event_note_outlined,
                                  'Tanggal Dan Waktu',
                                  _teks(
                                      '${tanggalPanjang(_waktu)}, ${jamWib(_waktu)}'),
                                ),
                                _info(Icons.receipt_long_outlined, 'ID Order',
                                    _teks(_idOrder)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassCard(
                            radius: 10,
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              width: width * 0.5,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF4ADE80), size: 30),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Transfer Berhasil',
                                    style: TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    rupiah(p.total),
                                    style: const TextStyle(
                                        color: Color(0xFF374151),
                                        fontSize: 9),
                                  ),
                                  const SizedBox(height: 6),
                                  _garisSkeleton(double.infinity),
                                  _garisSkeleton(double.infinity),
                                  _garisSkeleton(60),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: SmallButton(label: 'Confirm', onTap: _selesai)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}