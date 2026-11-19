import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RentraBackground extends StatelessWidget {
  final Widget child;
  const RentraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        child,
      ],
    );
  }
}

class RentraScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom;
  final bool showBack;

  const RentraScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.showBack = true,
  });

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
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(child: child),
                if (bottom != null) ...[
                  const SizedBox(height: 12),
                  Center(child: bottom!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x40FFFFFF)),
          ),
          child: child,
        ),
      ),
    );
  }
}