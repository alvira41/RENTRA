import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  /// logo.png berukuran 500x500, tapi isinya hanya di Y 212..288.
  /// Padding transparan bawah (211px) bikin tagline ikut turun jika
  /// gambar dirender apa adanya. Potong saat render saja.
  Widget _logoTanpaPadding(double lebar) {
    const asli = 500.0;
    const atas = 212.0;
    const tinggiIsi = 76.0;
    final skala = lebar / asli;

    return SizedBox(
      width: lebar,
      height: tinggiIsi * skala,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(0, -atas * skala),
          child: Image.asset(
            'assets/images/logo.png',
            width: lebar,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/background.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.6),
                    AppColors.background.withValues(alpha: 0.2),
                    AppColors.background.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.08),
                _logoTanpaPadding(size.width * 0.6),
                const SizedBox(height: 4),
                const Text(
                  'DRIVE YOUR JOURNEY',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: size.height * 0.08),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.12),
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.buttonText,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Let's Drive"),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: const Offset(24, 0),
                      child: Image.asset(
                        'assets/images/car1.png',
                        width: size.width * 0.85,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomRight,
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