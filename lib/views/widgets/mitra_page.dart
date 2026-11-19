import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'mitra_bottom_bar.dart';
import 'rentra_scaffold.dart';

class MitraPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final int? navIndex;
  final bool showBack;

  const MitraPage({
    super.key,
    this.title,
    required this.child,
    this.navIndex,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final side = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          navIndex == null ? null : MitraBottomBar(currentIndex: navIndex!),
      body: RentraBackground(
        child: SafeArea(
          bottom: navIndex == null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(side, 16, side, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: width * 0.3,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D3157),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4F6FB8)),
                      ),
                      child: const Text(
                        'Mitra',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (title != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (showBack)
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: AppColors.textPrimary, size: 16),
                          ),
                        ),
                      Text(
                        title!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}