import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../widgets/rentra_scaffold.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _tanggalLahir = TextEditingController();
  final _alamat = TextEditingController();
  final _nik = TextEditingController();
  final _telepon = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _verifikasi = TextEditingController();

  String? _jenisKelamin;
  bool _hidePassword = true;
  bool _hideVerifikasi = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _nama,
      _tanggalLahir,
      _alamat,
      _nik,
      _telepon,
      _email,
      _password,
      _verifikasi,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (hasil == null) return;
    _tanggalLahir.text =
        '${hasil.year}-${hasil.month.toString().padLeft(2, '0')}-${hasil.day.toString().padLeft(2, '0')}';
  }

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _daftar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService().registerUser(
        name: _nama.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _telepon.text.trim(),
      );
      if (!mounted) return;
      _pesan('Akun berhasil dibuat. Silakan login');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _pesan(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dekor(String hint, {Widget? suffix}) {
    const garis = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(22)),
      borderSide: BorderSide(color: Color(0x80FFFFFF)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      isDense: true,
      filled: true,
      fillColor: const Color(0x26FFFFFF),
      suffixIcon: suffix,
      errorStyle: const TextStyle(fontSize: 9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: garis,
      enabledBorder: garis,
      focusedBorder: garis.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
      ),
    );
  }

  Widget _jarak() => const SizedBox(height: 10);

  TextStyle get _isi =>
      const TextStyle(color: AppColors.textPrimary, fontSize: 12);

  String? _wajib(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RentraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _nama,
                    style: _isi,
                    decoration: _dekor('Nama'),
                    validator: _wajib,
                  ),
                  _jarak(),
                  DropdownButtonFormField<String>(
                    initialValue: _jenisKelamin,
                    dropdownColor: const Color(0xFF0F1621),
                    style: _isi,
                    decoration: _dekor('Jenis Kelamin'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(
                          value: 'Perempuan', child: Text('Perempuan')),
                    ],
                    onChanged: (v) => setState(() => _jenisKelamin = v),
                    validator: (v) => v == null ? 'Wajib dipilih' : null,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _tanggalLahir,
                    readOnly: true,
                    onTap: _pilihTanggal,
                    style: _isi,
                    decoration: _dekor('Tanggal Lahir'),
                    validator: _wajib,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _alamat,
                    style: _isi,
                    decoration: _dekor('Alamat'),
                    validator: _wajib,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _nik,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    style: _isi,
                    decoration: _dekor('NIK').copyWith(counterText: ''),
                    validator: (v) => (v == null || v.trim().length != 16)
                        ? 'NIK harus 16 digit'
                        : null,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _telepon,
                    keyboardType: TextInputType.phone,
                    style: _isi,
                    decoration: _dekor('No. Telp'),
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Nomor telepon tidak valid'
                        : null,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: _isi,
                    decoration: _dekor('Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Email tidak valid'
                        : null,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    style: _isi,
                    decoration: _dekor(
                      'Password',
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 8)
                        ? 'Minimal 8 karakter'
                        : null,
                  ),
                  _jarak(),
                  TextFormField(
                    controller: _verifikasi,
                    obscureText: _hideVerifikasi,
                    style: _isi,
                    decoration: _dekor(
                      'Verifikasi',
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _hideVerifikasi = !_hideVerifikasi),
                        icon: Icon(
                          _hideVerifikasi
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v != _password.text ? 'Password tidak sama' : null,
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Foto KTP',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pesan('Unggah foto belum dihubungkan'),
                    child: Container(
                      width: double.infinity,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0x26FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x80FFFFFF)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: AppColors.textPrimary, size: 34),
                          SizedBox(height: 6),
                          Text(
                            'Klik untuk unggah foto',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '*KTP akan digunakan sebagai jaminan saat menyewa mobil.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _daftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9CA3AF),
                        foregroundColor: const Color(0xFF111827),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Sign-up',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}