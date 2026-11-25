import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/routes/app_routes.dart';
import '../admin/edit_password_view.dart';
import '../widgets/rentra_scaffold.dart';
import '../widgets/user_page.dart';

class ProfileUserView extends StatefulWidget {
  const ProfileUserView({super.key});

  @override
  State<ProfileUserView> createState() => _ProfileUserViewState();
}

class _ProfileUserViewState extends State<ProfileUserView> {
  late final AuthController _auth;
  bool _siap = false;
  String? _ktp;

  @override
  void initState() {
    super.initState();
    _auth = AppControllers.of(context).auth;
    _muat();
  }

  Future<void> _muat() async {
    if (_auth.role == null) await _auth.restoreSession();
    if (_auth.role == 'user') {
      try {
        _ktp = await _auth.ktpUrl();
      } catch (_) {
        _ktp = null;
      }
    }
    if (mounted) setState(() => _siap = true);
  }

  String _ambil(String kunci) {
    final v = _auth.profile?[kunci];
    if (v == null || v.toString().trim().isEmpty) return '-';
    return v.toString();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F1621),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Yakin ingin keluar dari akun?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _auth.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Widget _baris(String label, String isi) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                isi,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _fotoKtp() {
    final kosong = Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge_outlined, size: 34, color: AppColors.textSecondary),
          SizedBox(height: 6),
          Text(
            'Belum ada foto KTP',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );

    if (_ktp == null) return kosong;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _ktp!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => kosong,
      ),
    );
  }

  Widget _isiKartu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined,
              color: AppColors.textPrimary, size: 64),
          const SizedBox(height: 4),
          Text(
            _ambil('nama_user').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1D3157),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4F6FB8)),
            ),
            child: const Text(
              'Pengguna',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 10),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x40FFFFFF)),
            ),
            child: Column(
              children: [
                _baris('Nama', _ambil('nama_user')),
                _baris('No Telepon', _ambil('no_telepon_user')),
                _baris('Password', '••••••'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FOTO KTP',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _fotoKtp(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditPasswordView()),
              ),
              icon: const Icon(Icons.lock_outline,
                  size: 14, color: AppColors.textPrimary),
              label: const Text(
                'Edit Password',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0x1AFFFFFF),
                side: const BorderSide(color: Color(0x4DFFFFFF)),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserPage(
      title: 'PROFILE',
      navIndex: 3,
      centerTitle: false,
      showBadge: false,
      child: Column(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: !_siap
                  ? const Center(child: CircularProgressIndicator())
                  : _auth.role == null
                      ? Center(
                          child: Text(
                            _auth.errorMessage ?? 'Sesi login tidak ditemukan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : _isiKartu(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 112,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout,
                  size: 14, color: Color(0xFFEF4444)),
              label: const Text(
                'Logout',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0x33EF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}