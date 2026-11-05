import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/supabase_config.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/landing/landing_view.dart';
import 'views/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
      },
    );
  }
}