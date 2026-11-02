import 'package:alimentored/features/auth/presentation/welcome_page.dart';
import 'package:alimentored/features/donations/presentation/donations_page.dart';
import 'package:alimentored/features/donations/presentation/donor_home_page.dart';
import 'package:alimentored/features/donations/presentation/organization_home_page.dart';
import 'package:alimentored/features/donations/presentation/publish_donation_page.dart';
import 'package:alimentored/features/impact/presentation/history_page.dart';
import 'package:alimentored/features/profile/presentation/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
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
