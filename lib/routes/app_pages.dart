import 'package:get/get.dart';
import './app_routes.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/common/responsive_scaffold.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const ResponsiveScaffold(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
