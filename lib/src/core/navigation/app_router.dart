import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_providers.dart';
import '../../features/auth/presentation/pages/yannko_welcome_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/seller_login_page.dart';
import '../../features/auth/presentation/pages/seller_register_page.dart';
import '../../features/auth/presentation/pages/seller_forgot_password_page.dart';
import '../../features/parts/presentation/pages/particulier/home_page.dart';
import '../../features/parts/presentation/pages/particulier/requests_page.dart';
import '../../features/parts/presentation/pages/particulier/become_seller_page.dart';
import '../../features/parts/presentation/pages/particulier/conversations_list_page.dart';
import '../../features/parts/presentation/pages/particulier/chat_page.dart';
import '../../features/parts/presentation/pages/Vendeur/messages_page.dart';
import '../../features/parts/presentation/pages/Vendeur/conversation_detail_page.dart';
import '../../features/parts/presentation/pages/Vendeur/all_notifications_page.dart';
import '../../shared/presentation/widgets/main_wrapper.dart';
import '../../features/parts/presentation/pages/Vendeur/home_selleur.dart';
import '../../features/parts/presentation/pages/Vendeur/my_ads_page.dart';
import '../../shared/presentation/widgets/seller_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Utiliser try-catch pour éviter les erreurs au démarrage
  String getInitialLocation() {
    try {
      // Récupérer les infos de session depuis le cache
      final sessionService = ref.read(sessionServiceProvider);
      final cachedUserType = sessionService.getCachedUserType();
      final hasValidSession = sessionService.isAutoReconnectEnabled() && cachedUserType != null;
      
      print('🚀 [Router] Initialisation - Type en cache: $cachedUserType');
      
      if (hasValidSession) {
        if (cachedUserType == 'vendeur') {
          print('📍 [Router] Redirection vers page vendeur');
          return '/seller';
        } else {
          print('📍 [Router] Redirection vers page particulier');
          return '/home';
        }
      }
    } catch (e) {
      print('⚠️ [Router] Erreur lors de la récupération du cache: $e');
    }
    
    print('📍 [Router] Pas de session, page d\'accueil');
    return '/';
  }

  return GoRouter(
    initialLocation: getInitialLocation(),
    redirect: (context, state) {
      final location = state.matchedLocation;
      
      print('🔍 [Router] Navigation vers: $location');
      
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
            builder: (context, state) => const ConversationsListPage(),
            routes: [
              GoRoute(
                path: '/:conversationId',
                name: 'chat',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ChatPage(conversationId: conversationId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/messages-clients',
            name: 'messages-clients',
            builder: (context, state) => const ConversationsListPage(),
          ),
          GoRoute(
            path: '/become-seller',
            name: 'become-seller',
            builder: (context, state) => const BecomeSellerPage(),
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
            builder: (context, state) => const HomeSellerPage(),
          ),
          GoRoute(
            path: '/seller/add',
            name: 'seller-add',
            builder: (context, state) => const BecomeSellerPage(mode: SellerMode.vendeur),
          ),
          GoRoute(
            path: '/seller/ads',
            name: 'seller-ads',
            builder: (context, state) => const MyAdsPage(),
          ),
          GoRoute(
            path: '/seller/messages',
            name: 'seller-messages',
            builder: (context, state) => const SellerMessagesPage(),
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
              return SellerConversationDetailPage(conversationId: conversationId);
            },
          ),
        ],
      ),
    ],
  );
});
