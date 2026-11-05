import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/supabase_config.dart';
import 'view/core/routes/app_routes.dart';
import 'view/core/theme/app_theme.dart';
import 'view/features/auth/presentation/pages/login_page.dart';
import 'view/features/landing/presentation/pages/landing_page.dart';
import 'view/features/splash/presentation/pages/splash_page.dart';

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
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.landing: (context) => const LandingPage(),
        AppRoutes.login: (context) => const LoginPage(),
      },
    );
  }
}