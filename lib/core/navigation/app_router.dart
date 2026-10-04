import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/product_details/presentation/screens/product_details_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/quiz/presentation/screens/quiz_selection_screen.dart';
import '../../features/quiz/presentation/screens/quiz_wizard_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import 'main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const projects = '/home/projects';
  static const support = '/home/support';
  static const catalog = '/catalog';
  static const quizzes = '/quizzes';
  static const cart = '/cart';
  static const checkout = '/cart/checkout';
  static const profile = '/profile';
  static const orders = '/profile/orders';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';

  static String product(String id) => '/catalog/product/$id';

  static String quiz(String id) => '/quizzes/$id';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Роутер приложения.
///
/// Все экраны, включая карточку товара и визард, открываются внутри вкладки,
/// поэтому нижний бар остаётся виден — как на макетах.
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    // Заставка живёт поверх табов: своего нижнего бара у неё нет.
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // Вход и регистрация открываются поверх табов — без нижнего бара.
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const PasswordResetScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.quizzes,
              builder: (context, state) => const QuizSelectionScreen(),
              routes: [
                GoRoute(
                  path: ':quizId',
                  builder: (context, state) =>
                      QuizWizardScreen(quizId: state.pathParameters['quizId']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.catalog,
              builder: (context, state) => const CatalogScreen(),
              routes: [
                GoRoute(
                  path: 'product/:id',
                  builder: (context, state) => ProductDetailsScreen(
                    productId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'projects',
                  builder: (context, state) => const ProjectsScreen(),
                ),
                GoRoute(
                  path: 'support',
                  builder: (context, state) => const SupportScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartScreen(),
              routes: [
                GoRoute(
                  path: 'checkout',
                  builder: (context, state) => const CheckoutScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'orders',
                  builder: (context, state) => const OrdersScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
