import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../admin/profile_view.dart';
import '../user/dashboard_user_view.dart';

class UserBottomBar extends StatelessWidget {
  final int currentIndex;
  const UserBottomBar({super.key, required this.currentIndex});

  static const _icons = [
    Icons.home_rounded,
    Icons.edit_note_rounded,
    Icons.info_outline_rounded,
    Icons.person_outline_rounded,
  ];

  void _go(BuildContext context, int i) {
    if (i == currentIndex) return;
    if (i == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const DashboardUserView()));
      return;
    }
    if (i == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProfileView()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman ini belum tersedia')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1621),
        border: Border(top: BorderSide(color: Color(0x26FFFFFF))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _icons.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _go(context, i),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentIndex
                          ? const Color(0x33FFFFFF)
                          : Colors.transparent,
                    ),
                    child: Icon(
                      _icons[i],
                      color: i == currentIndex
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}