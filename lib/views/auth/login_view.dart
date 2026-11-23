import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _auth = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _auth.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();

    final ok = await _auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    if (!ok) {
      _showMessage(_auth.errorMessage ?? 'Login gagal');
      return;
    }

    final String tujuan;
    switch (_auth.role) {
      case 'admin':
        tujuan = AppRoutes.adminDashboard;
        break;
      case 'mitra':
        tujuan = AppRoutes.mitraDashboard;
        break;
      case 'user':
        tujuan = AppRoutes.userDashboard;
        break;
      default:
        _showMessage('Role akun tidak dikenali');
        return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(tujuan, (route) => false);
  }

  void _onCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
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
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.14),
                    Image.asset(
                      'assets/images/logo.png',
                      width: size.width * 0.4,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSignIn(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        isDense: true,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.08),
                    ListenableBuilder(
                      listenable: _auth,
                      builder: (context, _) => SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: _auth.isLoading ? null : _onSignIn,
                          child: _auth.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: OutlinedButton(
                        onPressed: _onCreateAccount,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Color(0x80FFFFFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Create Account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}