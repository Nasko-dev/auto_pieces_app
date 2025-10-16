import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🔧 Configuration des environnements
/// Gère les différentes configurations selon l'environnement (dev/staging/prod)
class EnvironmentConfig {
  // Environnement actuel
  static const String _environment = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );

  /// Type d'environnement
  static AppEnvironment get environment {
    switch (_environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  /// Vérifie si on est en développement
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// Vérifie si on est en staging
  static bool get isStaging => environment == AppEnvironment.staging;

  /// Vérifie si on est en production
  static bool get isProduction => environment == AppEnvironment.production;

  // ==========================================================================
  // 🔗 SUPABASE CONFIGURATION
  // ==========================================================================

  static String get supabaseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return dotenv.env['SUPABASE_URL_PROD'] ??
            'https://your-prod-project.supabase.co';
      case AppEnvironment.staging:
        return dotenv.env['SUPABASE_URL_STAGING'] ??
            'https://your-staging-project.supabase.co';
      case AppEnvironment.development:
        return dotenv.env['SUPABASE_URL_DEV'] ??
            'https://your-dev-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (environment) {
      case AppEnvironment.production:
        return dotenv.env['SUPABASE_ANON_KEY_PROD'] ?? 'your-prod-anon-key';
      case AppEnvironment.staging:
        return dotenv.env['SUPABASE_ANON_KEY_STAGING'] ??
            'your-staging-anon-key';
      case AppEnvironment.development:
        return dotenv.env['SUPABASE_ANON_KEY_DEV'] ?? 'your-dev-anon-key';
    }
  }

  // ==========================================================================
  // 🚗 TECALLIANCE API
  // ==========================================================================

  static String get tecallianceApiKey {
    return dotenv.env['TECALLIANCE_API_KEY'] ?? 'your-tecalliance-key';
  }

  static String get tecallianceBaseUrl {
    return dotenv.env['TECALLIANCE_BASE_URL'] ??
        'https://vehicle-identification.tecalliance.services';
  }

  static String get tecallianceClientId {
    return dotenv.env['TECALLIANCE_CLIENT_ID'] ?? 'your-client-id';
  }

  // ==========================================================================
  // 🔥 FIREBASE CONFIGURATION
  // ==========================================================================

  static String get firebaseApiKey {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'FIREBASE_ANDROID_API_KEY',
        defaultValue: 'your-android-api-key',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'FIREBASE_IOS_API_KEY',
        defaultValue: 'your-ios-api-key',
      );
    } else {
      return const String.fromEnvironment(
        'FIREBASE_WEB_API_KEY',
        defaultValue: 'your-web-api-key',
      );
    }
  }

  static String get firebaseAppId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment(
        'FIREBASE_ANDROID_APP_ID',
        defaultValue: 'your-android-app-id',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'FIREBASE_IOS_APP_ID',
        defaultValue: 'your-ios-app-id',
      );
    } else {
      return const String.fromEnvironment(
        'FIREBASE_WEB_APP_ID',
        defaultValue: 'your-web-app-id',
      );
    }
  }

  static String get firebaseProjectId {
    return const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'your-firebase-project',
    );
  }

  // ==========================================================================
  // 💳 STRIPE CONFIGURATION
  // ==========================================================================

  static String get stripePublishableKey {
    return isProduction
        ? const String.fromEnvironment(
            'STRIPE_PUBLISHABLE_KEY_PROD',
            defaultValue: 'pk_live_your-prod-key',
          )
        : const String.fromEnvironment(
            'STRIPE_PUBLISHABLE_KEY_DEV',
            defaultValue: 'pk_test_your-dev-key',
          );
  }

  // ==========================================================================
  // 📊 MONITORING & ANALYTICS
  // ==========================================================================

  static String get sentryDsn {
    return const String.fromEnvironment(
      'SENTRY_DSN',
      defaultValue: 'https://your-sentry-dsn@sentry.io/project',
    );
  }

  static String get googleAnalyticsMeasurementId {
    return const String.fromEnvironment(
      'GA_MEASUREMENT_ID',
      defaultValue: 'G-XXXXXXXXXX',
    );
  }

  // ==========================================================================
  // 🔧 CONFIGURATION TECHNIQUE
  // ==========================================================================

  static int get rateLimitRequestsPerMinute {
    return const int.fromEnvironment(
      'RATE_LIMIT_REQUESTS_PER_MINUTE',
      defaultValue: 100,
    );
  }

  static int get maxImageSizeMB {
    return const int.fromEnvironment(
      'MAX_IMAGE_SIZE_MB',
      defaultValue: 10,
    );
  }

  static List<String> get allowedImageFormats {
    const formats = String.fromEnvironment(
      'ALLOWED_IMAGE_FORMATS',
      defaultValue: 'jpg,jpeg,png,webp',
    );
    return formats.split(',');
  }

  // ==========================================================================
  // 🌍 CONFIGURATION RÉGIONALE
  // ==========================================================================

  static String get defaultLocale {
    return const String.fromEnvironment(
      'DEFAULT_LOCALE',
      defaultValue: 'fr_FR',
    );
  }

  static List<String> get supportedLocales {
    const locales = String.fromEnvironment(
      'SUPPORTED_LOCALES',
      defaultValue: 'fr_FR,en_US',
    );
    return locales.split(',');
  }

  // ==========================================================================
  // 🔗 DOMAINES & URLs
  // ==========================================================================

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return const String.fromEnvironment(
          'DOMAIN_PROD',
          defaultValue: 'piecesdoccasion.com',
        );
      case AppEnvironment.staging:
        return const String.fromEnvironment(
          'DOMAIN_STAGING',
          defaultValue: 'staging.piecesdoccasion.com',
        );
      case AppEnvironment.development:
        return const String.fromEnvironment(
          'DOMAIN_DEV',
          defaultValue: 'dev.piecesdoccasion.com',
        );
    }
  }

  static String get deepLinkScheme {
    return const String.fromEnvironment(
      'DEEP_LINK_SCHEME',
      defaultValue: 'piecesdoccasion',
    );
  }

  // ==========================================================================
  // 🚨 DEBUG & FEATURE FLAGS
  // ==========================================================================

  static bool get debugMode {
    return const bool.fromEnvironment(
      'DEBUG_MODE',
      defaultValue: true,
    );
  }

  static bool get featureChatVideo {
    return const bool.fromEnvironment(
      'FEATURE_CHAT_VIDEO',
      defaultValue: false,
    );
  }

  static bool get featurePaymentStripe {
    return const bool.fromEnvironment(
      'FEATURE_PAYMENT_STRIPE',
      defaultValue: false,
    );
  }

  static bool get featureGeolocation {
    return const bool.fromEnvironment(
      'FEATURE_GEOLOCATION',
      defaultValue: true,
    );
  }

  static bool get featurePushNotifications {
    return const bool.fromEnvironment(
      'FEATURE_PUSH_NOTIFICATIONS',
      defaultValue: true,
    );
  }

  // ==========================================================================
  // 📱 CONFIGURATION MOBILE
  // ==========================================================================

  static String get bundleId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment(
        'BUNDLE_ID_IOS',
        defaultValue: 'com.piecesdoccasion.app',
      );
    } else {
      return const String.fromEnvironment(
        'BUNDLE_ID_ANDROID',
        defaultValue: 'com.piecesdoccasion.app',
      );
    }
  }

  static String get appVersion {
    return const String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    );
  }

  // ==========================================================================
  // 🔍 MÉTHODES UTILITAIRES
  // ==========================================================================

  /// Affiche la configuration actuelle (pour debug)
  static void printCurrentConfig() {
    if (debugMode && kDebugMode) {
      debugPrint('🔧 Configuration Environment:');
      debugPrint('  Environment: $environment');
      debugPrint('  Supabase URL: $supabaseUrl');
      debugPrint('  Firebase Project: $firebaseProjectId');
      debugPrint('  Base URL: $baseUrl');
      debugPrint('  Debug Mode: $debugMode');
      debugPrint('  Bundle ID: $bundleId');
      debugPrint('  Version: $appVersion');
    }
  }

  /// Valide que toutes les variables critiques sont définies
  static bool validateConfiguration() {
    final criticalVars = [
      supabaseUrl,
      supabaseAnonKey,
      tecallianceApiKey,
      firebaseApiKey,
      firebaseAppId,
    ];

    for (final variable in criticalVars) {
      if (variable.isEmpty || variable.startsWith('your-')) {
        if (kDebugMode) {
          debugPrint('❌ Variable de configuration manquante ou non configurée');
        }
        return false;
      }
    }

    return true;
  }
}

/// Types d'environnement
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Extension pour faciliter l'utilisation
extension AppEnvironmentExtension on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  String get displayName {
    switch (this) {
      case AppEnvironment.development:
        return '🔧 Dev';
      case AppEnvironment.staging:
        return '🚧 Staging';
      case AppEnvironment.production:
        return '🚀 Production';
    }
  }
}
