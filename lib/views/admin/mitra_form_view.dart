import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';

class MitraFormView extends StatefulWidget {
  const MitraFormView({super.key});

  @override
  State<MitraFormView> createState() => _MitraFormViewState();
}

class _MitraFormViewState extends State<MitraFormView> {
  late final AuthController _auth;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _auth = AppControllers.of(context).auth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    if (_nameController.text.trim().isEmpty ||
        _ownerController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        email.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      _showMessage('Lengkapi semua data mitra');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Format email tidak valid');
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showMessage('Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);
    final ok = await _auth.registerMitra(
      email: email,
      password: _passwordController.text,
      namaRental: _nameController.text.trim(),
      namaPemilik: _ownerController.text.trim(),
      alamat: _addressController.text.trim(),
      noTelepon: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      _showMessage(_auth.errorMessage ?? 'Mitra gagal ditambahkan');
      return;
    }
    _showMessage('Mitra berhasil ditambahkan');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.08;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/background.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: width * 0.3,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Tambah Mitra',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: 'Nama Mitra',
                          child: _FormInput(controller: _nameController),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LabeledField(
                          label: 'Nama Pemilik',
                          child: _FormInput(controller: _ownerController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Alamat',
                    child: _FormInput(controller: _addressController),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'No Telepon',
                    child: _FormInput(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Email',
                    child: _FormInput(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Password',
                    child: _FormInput(
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      onToggleObscure: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Konfirmasi Password',
                    child: _FormInput(
                      controller: _confirmController,
                      obscure: _obscureConfirm,
                      onToggleObscure: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PillButton(
                        label: 'Cancel',
                        fill: const Color(0x33EF4444),
                        border: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _PillButton(
                        label: _loading ? 'Menyimpan...' : 'Save',
                        fill: const Color(0x333B82F6),
                        border: const Color(0xFF3B82F6),
                        textColor: const Color(0xFF60A5FA),
                        onTap: _loading ? null : _onSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.controller,
    this.keyboardType,
    this.formatters,
    this.obscure = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: obscure,
      style: const TextStyle(
        color: AppColors.buttonText,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFD3D6E0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.buttonText,
                ),
              ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.fill,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color fill;
  final Color border;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}