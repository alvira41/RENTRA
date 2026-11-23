import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/supabase_config.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'views/admin/activity_view.dart';
import 'views/admin/car_form_view.dart';
import 'views/admin/dashboard_view.dart';
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
  await SupabaseConfig.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RentraApp());
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
        AppRoutes.adminEditCar: (context) => const CarFormView(isEdit: true),
        AppRoutes.adminOrder: (context) => const OrderView(),
        AppRoutes.adminPaymentProof: (context) => const PaymentProofView(),
        AppRoutes.adminReturn: (context) => const ReturnView(),
        AppRoutes.adminSupply: (context) => const SupplyView(),
        AppRoutes.adminAddMitra: (context) => const MitraFormView(),
        AppRoutes.adminActivity: (context) => const ActivityView(),
        AppRoutes.mitraDashboard: (context) => const DashboardMitraView(),
        AppRoutes.mitraAddCar: (context) => const MitraCarFormView(),
        AppRoutes.mitraSupply: (context) => const KonfirmasiSupplyView(),
        AppRoutes.mitraProof: (context) => const BuktiMitraView(),
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