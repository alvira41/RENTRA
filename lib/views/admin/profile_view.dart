import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/rentra_scaffold.dart';
import 'edit_password_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const _namaPanggilan = 'FERNANDO';
  static const _role = 'Pengguna';
  static const _namaRental = 'Rezeki Rental';
  static const _namaPemilik = 'Nama';
  static const _alamat = 'Alamat';
  static const _noTelepon = '08726473xxxx';
  static const _email = 'fernan@gmail.com';

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return RentraScaffold(
      title: 'PROFILE',
      bottom: SizedBox(
        width: 90,
        height: 30,
        child: OutlinedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout, size: 12, color: Colors.white),
          label: const Text('Logout',
              style: TextStyle(color: Colors.white, fontSize: 10)),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFB3261E),
            side: const BorderSide(color: Color(0xFFE57373)),
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Column(
          children: [
            const Icon(Icons.account_circle_outlined,
                color: Colors.white, size: 52),
            const SizedBox(height: 4),
            const Text(_namaPanggilan,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF60A5FA)),
              ),
              child: const Text(_role,
                  style: TextStyle(color: Colors.white, fontSize: 8)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Column(
                children: const [
                  _InfoRow('Nama Rental', _namaRental),
                  _InfoRow('Nama Pemilik', _namaPemilik),
                  _InfoRow('Alamat', _alamat),
                  _InfoRow('No Telepon', _noTelepon),
                  SizedBox(height: 8),
                  _InfoRow('Email', _email),
                  _InfoRow('Password', '••••••'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 30,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditPasswordView()),
                ),
                icon: const Icon(Icons.lock_outline,
                    size: 12, color: Colors.white),
                label: const Text('Edit Password',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white70, fontSize: 8)),
          ),
        ],
      ),
    );
  }
}