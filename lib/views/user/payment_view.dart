import 'package:flutter/material.dart';
import '../../controllers/base_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_picker_helper.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/rentra_scaffold.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  UploadFile? _bukti;

  Future<void> _pilihBukti() async {
    final file = await pickUploadFile();
    if (file == null) return;
    setState(() => _bukti = file);
  }

  void _confirm() {
    if (_bukti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unggah bukti pembayaran dulu')),
      );
      return;
    }
    Navigator.pop(context, _bukti);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final side = width * 0.06;

    return Scaffold(
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
                        const Text(
                          'PAYMENT',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SizedBox(
                            width: width * 0.5,
                            height: width * 0.5,
                            child: CustomPaint(painter: _QrPainter()),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scan QR Code untuk melakukan pembayaran',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 9),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Upload Bukti Pembayaran',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pilihBukti,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _bukti != null
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0x80FFFFFF),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _bukti != null
                                      ? Icons.check_circle_outline
                                      : Icons.add_a_photo_outlined,
                                  size: 38,
                                  color: _bukti != null
                                      ? const Color(0xFF4ADE80)
                                      : AppColors.textPrimary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _bukti?.name ?? 'Klik untuk unggah foto',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 10),
                                ),
                                if (_bukti != null)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Ketuk untuk mengganti',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallButton(
                      label: 'Cancel',
                      color: const Color(0xFFEF4444),
                      onTap: () => Navigator.pop(context, false),
                    ),
                    SmallButton(label: 'Confirm', onTap: _confirm),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final hitam = Paint()..color = Colors.black;
    final putih = Paint()..color = Colors.white;

    bool pojok(int x, int y) =>
        (x < 8 && y < 8) || (x >= n - 8 && y < 8) || (x < 8 && y >= n - 8);

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (pojok(x, y)) continue;
        final h = (x * 73856093) ^ (y * 19349663) ^ 0x5bd1e995;
        if ((h & 7) < 4) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), hitam);
        }
      }
    }

    void kotak(int ox, int oy) {
      canvas.drawRect(
          Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), hitam);
      canvas.drawRect(
          Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
          putih);
      canvas.drawRect(
          Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
          hitam);
    }

    kotak(0, 0);
    kotak(n - 7, 0);
    kotak(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}