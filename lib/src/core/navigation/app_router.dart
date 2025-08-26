import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/yannko_welcome_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/parts/presentation/pages/home_page.dart';
import '../../features/parts/presentation/pages/requests_page.dart';
import '../../features/parts/presentation/pages/conversations_page.dart';
import '../../features/parts/presentation/pages/become_seller_page.dart';
import '../../shared/presentation/widgets/main_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isInitialPage = state.matchedLocation == '/';
      final isWelcomePage = state.matchedLocation == '/welcome';
      
      if (!isAuthenticated && !isInitialPage && !isWelcomePage) {
        return '/';
      }
      
      if (isAuthenticated && (isInitialPage || isWelcomePage)) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'initial',
        builder: (context, state) => const YannkoWelcomePage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            builder: (context, state) => const RequestsPage(),
          ),
          GoRoute(
            path: '/conversations',
            name: 'conversations',
            builder: (context, state) => const MessagesPageColored(),
          ),
          GoRoute(
            path: '/become-seller',
            name: 'become-seller',
            builder: (context, state) => const BecomeSellerPage(),
          ),
        ],
      ),
    ],
  );
});