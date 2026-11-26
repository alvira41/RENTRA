import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/supabase_config.dart';
import 'core/controllers/app_controllers.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'views/admin/activity_view.dart';
import 'views/admin/car_form_view.dart';
import 'views/admin/dashboard_view.dart';
import 'views/admin/mitra_detail_view.dart';
import 'views/admin/mitra_form_view.dart';
import 'views/admin/order_view.dart';
import 'views/admin/payment_proof_view.dart';
import 'views/admin/return_view.dart';
import 'views/admin/supply_view.dart';
import 'views/auth/login_view.dart';
import 'views/landing/landing_view.dart';
import 'views/splash/splash_view.dart';
import 'views/mitra/dashboard_mitra_view.dart';
import 'views/mitra/mitra_car_form_view.dart';
import 'views/mitra/konfirmasi_supply_view.dart';
import 'views/mitra/bukti_mitra_view.dart';
import 'views/mitra/aktivitas_mitra_view.dart';
import 'views/auth/register_view.dart';
import 'views/user/dashboard_user_view.dart';
import 'views/admin/profile_view.dart';
import 'views/admin/edit_password_view.dart';
import 'views/user/status_rental_view.dart';
import 'views/user/riwayat_view.dart';
import 'views/user/profile_user_view.dart';
import 'views/user/payment_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.init();
  } catch (error) {
    runApp(StartupErrorView(message: error.toString()));
    return;
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AppControllers(child: RentraApp()));
}

class RentraApp extends StatelessWidget {
  const RentraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RENTRA',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final width =
            mediaQuery.size.width > 430 ? 430.0 : mediaQuery.size.width;

        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: SizedBox(
              width: width,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: Size(width, mediaQuery.size.height),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
      routes: {
        AppRoutes.splash: (context) => const SplashView(),
        AppRoutes.landing: (context) => const LandingView(),
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.adminDashboard: (context) => const DashboardView(),
        AppRoutes.adminAddCar: (context) => const CarFormView(),
        AppRoutes.adminEditCar: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CarFormView(isEdit: true, idMobil: args is int ? args : null);
        },
        AppRoutes.adminOrder: (context) => const OrderView(),
        AppRoutes.adminPaymentProof: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return PaymentProofView(idOrder: args is int ? args : null);
        },
        AppRoutes.adminReturn: (context) => const ReturnView(),
        AppRoutes.adminSupply: (context) => const SupplyView(),
        AppRoutes.adminAddMitra: (context) => const MitraFormView(),
        AppRoutes.adminMitraDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return MitraDetailView(idMitra: args is String ? args : '');
        },
        AppRoutes.adminActivity: (context) => const ActivityView(),
        AppRoutes.mitraDashboard: (context) => const DashboardMitraView(),
        AppRoutes.mitraAddCar: (context) => const MitraCarFormView(),
        AppRoutes.mitraSupply: (context) => const KonfirmasiSupplyView(),
        AppRoutes.mitraProof: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final argsMap = args is Map ? args.cast<String, dynamic>() : null;
          return BuktiMitraView(
            idSupply: args is int
                ? args
                : (argsMap?['id_supply'] as num?)?.toInt(),
            supply: argsMap,
          );
        },
        AppRoutes.mitraActivity: (context) => const AktivitasMitraView(),
        AppRoutes.register: (context) => const RegisterView(),
        AppRoutes.userDashboard: (context) => const DashboardUserView(),
        AppRoutes.adminProfile: (context) => const ProfileView(),
        AppRoutes.adminEditPassword: (context) => const EditPasswordView(),
        AppRoutes.userStatus: (context) => const StatusRentalView(),
        AppRoutes.userHistory: (context) => const RiwayatView(),
        AppRoutes.userProfile: (context) => const ProfileUserView(),
        AppRoutes.userPayment: (context) => const PaymentView(),
      },
    );
  }
}

class StartupErrorView extends StatelessWidget {
  const StartupErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Gagal menyiapkan Supabase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
