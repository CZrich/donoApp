import 'package:alimentored/features/auth/application/auth_controller.dart';
import 'package:alimentored/features/auth/presentation/login_page.dart';
import 'package:alimentored/features/auth/presentation/register_page.dart';
import 'package:alimentored/features/auth/presentation/welcome_page.dart';
import 'package:alimentored/features/donations/presentation/donations_page.dart';
import 'package:alimentored/features/donations/presentation/donor_home_page.dart';
import 'package:alimentored/features/donations/presentation/organization_home_page.dart';
import 'package:alimentored/features/donations/presentation/publish_donation_page.dart';
import 'package:alimentored/features/impact/presentation/history_page.dart';
import 'package:alimentored/features/profile/presentation/profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final isAuth = ref.read(authControllerProvider).isAuthenticated;
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';

      if (isAuth && isAuthRoute) {
        return '/donor';
      }

      final isProtected = path == '/publish' || path == '/profile';
      if (!isAuth && isProtected) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/donor',
        name: 'donor-home',
        builder: (context, state) => const DonorHomePage(),
      ),
      GoRoute(
        path: '/organization',
        name: 'organization-home',
        builder: (context, state) => const OrganizationHomePage(),
      ),
      GoRoute(
        path: '/publish',
        name: 'publish',
        builder: (context, state) => const PublishDonationPage(),
      ),
      GoRoute(
        path: '/donations',
        name: 'donations',
        builder: (context, state) => const DonationsPage(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
