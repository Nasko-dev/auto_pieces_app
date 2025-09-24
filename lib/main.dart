import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/navigation/app_router.dart';
import 'src/core/constants/app_constants.dart';
import 'src/core/providers/particulier_auth_providers.dart';
import 'src/core/providers/session_providers.dart' as session_providers;
import 'src/core/providers/user_settings_providers.dart' as user_settings;
import 'src/core/services/realtime_service.dart';
import 'src/core/services/session_service.dart';
import 'src/core/services/device_service.dart';
import 'src/core/services/notification_manager.dart';
import 'src/core/services/notification_navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le fichier .env (ou .env.example en fallback)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    try {
      await dotenv.load(fileName: ".env.example");
    } catch (e2) {
      // Continuer avec les valeurs par défaut
    }
  }

  try {
    // Initialiser OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("dd1bf04c-a036-4654-9c19-92e7b20bae08");

    // Demander permission notifications
    OneSignal.Notifications.requestPermission(true);

    // Initialiser Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // Initialiser SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();

    // Initialiser le service de session et tenter l'auto-reconnexion
    final sessionService = SessionService(sharedPreferences, Supabase.instance.client);

    // Tenter l'auto-reconnexion si une session est en cache
    final hasReconnected = await sessionService.autoReconnect();

    if (hasReconnected) {
      // Forcer la mise à jour du cache pour avoir le bon type d'utilisateur
      await sessionService.updateCachedSession();
    }

    // Vérifier l'état de l'auth final
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Mettre à jour le cache avec les infos actuelles
      await sessionService.updateCachedSession();
    }

    // MAINTENANT initialiser le service de notifications (après l'auth)
    try {
      debugPrint('🚀 Initialisation NotificationManager après auth...');
      final notificationManager = NotificationManager.instance;
      await notificationManager.initialize();

      // Forcer immédiatement la sauvegarde si on a un utilisateur
      if (user != null) {
        debugPrint('👤 Utilisateur connecté, forcer sync Player ID...');
        await notificationManager.forceSyncPlayerId();
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
    }

    // Initialiser le service Realtime
    try {
      final realtimeService = RealtimeService();
      await realtimeService.startRealtimeSubscriptions();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du service Realtime: $e');
    }

    runApp(
      ProviderScope(
        overrides: [
          // Override pour les providers de SharedPreferences dans tous les fichiers
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          // Override pour le provider de session_providers.dart
          session_providers.sessionSharedPreferencesProvider.overrideWithValue(sharedPreferences),
          // Override pour le DeviceService dans user_settings
          user_settings.deviceServiceProvider.overrideWithValue(DeviceService(sharedPreferences)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Configurer le router global pour les notifications
    NotificationNavigationService.setGlobalRouter(router);

    return MaterialApp.router(
      title: 'Pièces d\'Occasion',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
