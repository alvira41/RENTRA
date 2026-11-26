import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/rentra_scaffold.dart';

class EditPasswordView extends StatefulWidget {
  const EditPasswordView({super.key});
  @override
  State<EditPasswordView> createState() => _EditPasswordViewState();
}

class _EditPasswordViewState extends State<EditPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _lamaC = TextEditingController();
  final _baruC = TextEditingController();
  final _konfirmC = TextEditingController();
  bool _hideLama = true, _hideBaru = true, _hideKonfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _lamaC.dispose();
    _baruC.dispose();
    _konfirmC.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = SupabaseConfig.client.auth;
      final email = auth.currentUser?.email;
      if (email == null) throw const AuthException('Sesi login tidak ditemukan');

      await auth.signInWithPassword(
        email: email,
        password: _lamaC.text.trim(),
      );
      await auth.updateUser(
        UserAttributes(password: _baruC.text.trim()),
      );
      await auth.signOut();
      await auth.signInWithPassword(
        email: email,
        password: _baruC.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password $email berhasil diubah')),
      );
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      final pesan = e.message.toLowerCase().contains('invalid login') ||
              e.message.toLowerCase().contains('invalid credentials')
          ? 'Password lama salah'
          : e.message;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $pesan')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field({
    required String hint,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          isDense: true,
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          errorStyle: const TextStyle(fontSize: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(hidden ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textPrimary, size: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentraScaffold(
      title: 'EDIT PASSWORD',
      child: Align(
        alignment: Alignment.topCenter,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan password lama, lalu buat password baru.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
                ),
                const SizedBox(height: 14),
                _field(
                  hint: 'Password Lama',
                  controller: _lamaC,
                  hidden: _hideLama,
                  onToggle: () => setState(() => _hideLama = !_hideLama),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                _field(
                  hint: 'Password Baru',
                  controller: _baruC,
                  hidden: _hideBaru,
                  onToggle: () => setState(() => _hideBaru = !_hideBaru),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimal 6 karakter'
                      : null,
                ),
                _field(
                  hint: 'Konfirmasi Password Baru',
                  controller: _konfirmC,
                  hidden: _hideKonfirm,
                  onToggle: () => setState(() => _hideKonfirm = !_hideKonfirm),
                  validator: (v) =>
                      v != _baruC.text ? 'Password tidak sama' : null,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: _loading ? null : _confirm,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F6FB8).withAlpha(50),
                        side: const BorderSide(color: Color(0xFF4F6FB8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 1.5))
                          : const Text('Confirm',
                              style:
                                  TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}