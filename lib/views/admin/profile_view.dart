import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/rentra_scaffold.dart';
import 'edit_password_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthController _auth = AuthController();
  bool _siap = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    await _auth.restoreSession();
    if (mounted) setState(() => _siap = true);
  }

  String _ambil(List<String> kunci) {
    final p = _auth.profile;
    if (p == null) return '-';
    for (final k in kunci) {
      final v = p[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '-';
  }

  String get _email {
    final dariProfil = _ambil(['email', 'email_admin']);
    if (dariProfil != '-') return dariProfil;
    try {
      final e = Supabase.instance.client.auth.currentUser?.email;
      return (e == null || e.isEmpty) ? '-' : e;
    } catch (_) {
      return '-';
    }
  }

  String get _nama {
    switch (_auth.role) {
      case 'mitra':
        return _ambil(['nama_rental', 'nama_pemilik']);
      case 'user':
        return _ambil(['nama_user']);
      default:
        return _ambil(['nama_admin']);
    }
  }

  String get _peran {
    switch (_auth.role) {
      case 'mitra':
        return 'Mitra';
      case 'user':
        return 'Pengguna';
      case 'admin':
        return 'Admin';
      default:
        return '-';
    }
  }

  List<MapEntry<String, String>> get _baris {
    switch (_auth.role) {
      case 'mitra':
        return [
          MapEntry('Nama Rental', _ambil(['nama_rental'])),
          MapEntry('Nama Pemilik', _ambil(['nama_pemilik'])),
          MapEntry('Alamat', _ambil(['alamat'])),
          MapEntry('No Telepon', _ambil(['no_telepon'])),
          MapEntry('Email', _email),
          const MapEntry('Password', '••••••'),
        ];
      case 'user':
        return [
          MapEntry('Nama', _ambil(['nama_user'])),
          MapEntry('Jenis Kelamin', _ambil(['jenis_kelamin'])),
          MapEntry('Tanggal Lahir', _ambil(['tanggal_lahir'])),
          MapEntry('Alamat', _ambil(['alamat'])),
          MapEntry('No Telepon', _ambil(['no_telepon_user'])),
          MapEntry('NIK', _ambil(['no_ktp'])),
          MapEntry('Email', _email),
          const MapEntry('Password', '••••••'),
        ];
      default:
        return [
          MapEntry('Nama', _ambil(['nama_admin'])),
          MapEntry('Email', _email),
          const MapEntry('Password', '••••••'),
        ];
    }
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

  @override
  Widget build(BuildContext context) {
    return RentraScaffold(
      title: 'PROFILE',
      bottom: SizedBox(
        width: 112,
        height: 38,
        child: OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, size: 14, color: Color(0xFFEF4444)),
          label: const Text(
            'Logout',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0x33EF4444),
            side: const BorderSide(color: Color(0xFFEF4444)),
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
                : Column(
                    children: [
                      const Icon(Icons.account_circle_outlined,
                          color: AppColors.textPrimary, size: 64),
                      const SizedBox(height: 4),
                      Text(
                        _nama.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3157),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF4F6FB8)),
                        ),
                        child: Text(
                          _peran,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x14FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0x40FFFFFF)),
                            ),
                            child: Column(
                              children: [
                                for (final b in _baris)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 104,
                                          child: Text(
                                            b.key,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            b.value,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditPasswordView(),
                            ),
                          ),
                          icon: const Icon(Icons.lock_outline,
                              size: 14, color: AppColors.textPrimary),
                          label: const Text(
                            'Edit Password',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
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
      ),
    );
  }
}
