import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';

class AdminBottomBar extends StatelessWidget {
  const AdminBottomBar({
    super.key,
    required this.currentIndex,
    required this.onAddTap,
  });

  final int currentIndex;
  final VoidCallback onAddTap;

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.error_outline_rounded,
    Icons.add_rounded,
    Icons.handshake_outlined,
    Icons.edit_note_rounded,
  ];

  static const List<String?> _routes = [
    AppRoutes.adminDashboard,
    AppRoutes.adminOrder,
    null,
    AppRoutes.adminSupply,
    AppRoutes.adminActivity,
  ];

  void _navigate(BuildContext context, int index) {
    final route = _routes[index];
    if (route == null) return;

    if (ModalRoute.of(context)?.settings.name == route) return;

    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (r) => r.settings.name == AppRoutes.adminDashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E1420),
        border: Border(top: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              return _NavIcon(
                icon: _icons[index],
                active: index == currentIndex,
                onTap: () {
                  if (index == 2) {
                    onAddTap();
                    return;
                  }
                  _navigate(context, index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFF2A3550) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 22,
          color: active ? AppColors.textPrimary : AppColors.primary,
        ),
      ),
    );
  }
}