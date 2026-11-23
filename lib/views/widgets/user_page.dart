import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'rentra_scaffold.dart';
import 'user_bottom_bar.dart';

class UserPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final int? navIndex;
  final bool centerTitle;
  final bool showBadge;

  const UserPage({
    super.key,
    this.title,
    required this.child,
    this.navIndex,
    this.centerTitle = true,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final side = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar:
          navIndex == null ? null : UserBottomBar(currentIndex: navIndex!),
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
                    if (showBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3157),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4F6FB8)),
                        ),
                        child: const Text(
                          'User',
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
                  Align(
                    alignment:
                        centerTitle ? Alignment.center : Alignment.centerLeft,
                    child: Text(
                      title!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
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