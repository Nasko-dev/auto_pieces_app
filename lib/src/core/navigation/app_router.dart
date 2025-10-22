import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_providers.dart' as session;
import '../providers/session_providers.dart' show sessionServiceProvider;
import 'custom_transitions.dart';
import '../../features/auth/presentation/pages/yannko_welcome_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/seller_login_page.dart';
import '../../features/auth/presentation/pages/seller_register_page.dart';
import '../../features/auth/presentation/pages/seller_forgot_password_page.dart';
import '../../features/parts/presentation/pages/particulier/home_page.dart';
import '../../features/parts/presentation/pages/particulier/requests_page.dart';
import '../../features/parts/presentation/pages/particulier/become_seller_page.dart';
import '../../features/parts/presentation/pages/particulier/seller_ads_list_page.dart';
import '../../features/parts/presentation/pages/Vendeur/seller_initial_choice_page.dart';
import '../../features/parts/presentation/pages/Vendeur/seller_create_request_page.dart';
import '../../features/parts/presentation/pages/particulier/conversations_list_page.dart';
import '../../features/parts/presentation/pages/particulier/chat_page.dart';
import '../../features/parts/presentation/pages/particulier/help_page.dart';
import '../../features/parts/presentation/pages/particulier/profile_page.dart';
import '../../features/parts/presentation/pages/particulier/settings_page.dart';
import '../../features/parts/presentation/pages/Vendeur/messages_page.dart';
import '../../features/parts/presentation/pages/Vendeur/conversation_detail_page.dart';
import '../../features/parts/presentation/pages/Vendeur/all_notifications_page.dart';
import '../../features/parts/presentation/pages/Particulier/particulier_notifications_page.dart';
import '../../shared/presentation/widgets/main_wrapper.dart';
import '../../features/parts/presentation/pages/Vendeur/home_selleur.dart';
import '../../features/parts/presentation/pages/Vendeur/my_ads_page.dart';
import '../../features/parts/presentation/pages/seller/seller_profile_page.dart';
import '../../features/parts/presentation/pages/seller/seller_settings_page.dart';
import '../../features/parts/presentation/pages/seller/seller_help_page.dart';
import '../../shared/presentation/widgets/seller_wrapper.dart';
import '../../shared/presentation/pages/under_development_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Tracker pour la localisation précédente pour les transitions
  String? previousLocation;

  // Fonction helper pour créer des pages avec transitions
  Page<T> buildPageWithTransition<T extends Object?>(
    GoRouterState state,
    Widget child,
  ) {
    final page = slideTransitionPage<T>(
      child: child,
      state: state,
      previousLocation: previousLocation,
    );
    previousLocation = state.matchedLocation;
    return page;
  }

  // Utiliser try-catch pour éviter les erreurs au démarrage
  String getInitialLocation() {
    try {
      // Récupérer les infos de session depuis le cache
      final sessionService = ref.read(sessionServiceProvider);
      final supabase = ref.read(session.supabaseClientProvider);

      // Vérifier d'abord si Supabase a une session active
      final hasSupabaseSession = supabase.auth.currentSession != null;
      final cachedUserType = sessionService.getCachedUserType();

      // Ne rediriger que si BOTH Supabase et le cache sont cohérents
      if (hasSupabaseSession && cachedUserType != null) {
        if (cachedUserType == 'vendeur') {
          return '/seller/home';
        } else {
          return '/home';
        }
      } else if (!hasSupabaseSession && cachedUserType != null) {
        // Incohérence détectée - nettoyer le cache
        sessionService.clearCache();
      }
    } catch (e) {
      // En cas d'erreur, retourner à la page d'accueil
      return '/';
    }
    return '/';
  }

  return GoRouter(
    initialLocation: getInitialLocation(),
    redirect: (context, state) {
      // Permettre la navigation normale sans re-direction forcée
      // Les pages géreront leur propre auth si nécessaire
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
      GoRoute(
        path: '/under-development',
        name: 'under-development',
        builder: (context, state) => const UnderDevelopmentPage(),
      ),
      // Routes d'authentification vendeur
      GoRoute(
        path: '/seller/login',
        name: 'seller-login',
        builder: (context, state) => const SellerLoginPage(),
      ),
      GoRoute(
        path: '/seller/register',
        name: 'seller-register',
        builder: (context, state) => const SellerRegisterPage(),
      ),
      GoRoute(
        path: '/seller/forgot-password',
        name: 'seller-forgot-password',
        builder: (context, state) => const SellerForgotPasswordPage(),
      ),
      // Routes particuliers avec MainWrapper
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const HomePage(),
            ),
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const RequestsPage(),
            ),
          ),
          GoRoute(
            path: '/conversations',
            name: 'conversations',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const ConversationsListPage(),
            ),
            routes: [
              GoRoute(
                path: '/:conversationId',
                name: 'chat',
                builder: (context, state) {
                  final conversationId =
                      state.pathParameters['conversationId']!;
                  final prefilledMessage = state.uri.queryParameters['prefilled'];
                  return ChatPage(
                    conversationId: conversationId,
                    prefilledMessage: prefilledMessage,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/messages-clients',
            name: 'messages-clients',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const ConversationsListPage(),
            ),
          ),
          GoRoute(
            path: '/notifications-particulier',
            name: 'notifications-particulier',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const ParticulierNotificationsPage(),
            ),
          ),
          GoRoute(
            path: '/become-seller',
            name: 'become-seller',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerAdsListPage(),
            ),
          ),
          GoRoute(
            path: '/help',
            name: 'help',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const HelpPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const ProfilePage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SettingsPage(),
            ),
          ),
          GoRoute(
            path: '/create-advertisement',
            name: 'create-advertisement',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const BecomeSellerPage(mode: SellerMode.particulier),
            ),
          ),
        ],
      ),

      // Routes vendeurs avec SellerWrapper
      ShellRoute(
        builder: (context, state, child) => SellerWrapper(child: child),
        routes: [
          GoRoute(
            path: '/seller/home',
            name: 'seller-home',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const HomeSellerPage(),
            ),
          ),
          GoRoute(
            path: '/seller/add',
            name: 'seller-add',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerInitialChoicePage(),
            ),
          ),
          GoRoute(
            path: '/seller/create-ad',
            name: 'seller-create-ad',
            builder: (context, state) =>
                const BecomeSellerPage(mode: SellerMode.vendeur),
          ),
          GoRoute(
            path: '/seller/create-request',
            name: 'seller-create-request',
            builder: (context, state) => const SellerCreateRequestPage(),
          ),
          GoRoute(
            path: '/seller/ads',
            name: 'seller-ads',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const MyAdsPage(),
            ),
          ),
          GoRoute(
            path: '/seller/messages',
            name: 'seller-messages',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerMessagesPage(),
            ),
          ),
          GoRoute(
            path: '/seller/notifications',
            name: 'seller-notifications',
            builder: (context, state) => const AllNotificationsPage(),
          ),
          GoRoute(
            path: '/seller/conversation/:conversationId',
            name: 'seller-conversation-detail',
            builder: (context, state) {
              final conversationId = state.pathParameters['conversationId']!;
              final prefilledMessage = state.uri.queryParameters['prefilled'];
              return SellerConversationDetailPage(
                conversationId: conversationId,
                prefilledMessage: prefilledMessage,
              );
            },
          ),
          GoRoute(
            path: '/seller/profile',
            name: 'seller-profile',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerProfilePage(),
            ),
          ),
          GoRoute(
            path: '/seller/settings',
            name: 'seller-settings',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerSettingsPage(),
            ),
          ),
          GoRoute(
            path: '/seller/help',
            name: 'seller-help',
            pageBuilder: (context, state) => buildPageWithTransition(
              state,
              const SellerHelpPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
