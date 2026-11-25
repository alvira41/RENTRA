import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _berandaSetelahSesi();
  }

  Future<void> _berandaSetelahSesi() async {
    final auth = AppControllers.of(context).auth;
    final hasil = await Future.wait<Object?>([
      auth.restoreSession(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;

    final peran = hasil.first == true ? auth.role : null;
    final tujuan = switch (peran) {
      'admin' => AppRoutes.adminDashboard,
      'mitra' => AppRoutes.mitraDashboard,
      'user' => AppRoutes.userDashboard,
      _ => AppRoutes.landing,
    };
    Navigator.of(context).pushReplacementNamed(tujuan);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Image.asset(
            'assets/images/logo.png',
            width: 90,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}