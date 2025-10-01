# Monitoring & Observabilité - Pièces d'Occasion

## 🎯 Objectifs

Assurer une **disponibilité de 99.9%** et détecter les problèmes **avant** qu'ils n'impactent les utilisateurs.

---

## 📊 Stack de Monitoring

| Outil | Usage | Coût |
|-------|-------|------|
| **Firebase Crashlytics** | Crash reporting | Gratuit |
| **Firebase Analytics** | Comportement utilisateurs | Gratuit |
| **Firebase Performance** | Performance app | Gratuit |
| **Supabase Dashboard** | Métriques backend | Inclus |
| **Sentry** (optionnel) | Error tracking avancé | $26/mois |

---

## 🔥 Firebase Crashlytics

### Configuration

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Erreurs asynchrones
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

### Custom Logs

```dart
// Ajouter contexte avant crash
FirebaseCrashlytics.instance.setUserIdentifier(userId);
FirebaseCrashlytics.instance.setCustomKey('subscription_tier', 'premium');
FirebaseCrashlytics.instance.log('User viewed product $productId');

// Enregistrer erreurs non-fatales
try {
  await riskyOperation();
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
}
```

### Alerts

**Firebase Console → Crashlytics → Alerts**

Configurer :
- Nouveau crash détecté
- Taux de crash > 1%
- Régression de stabilité

---

## 📈 Firebase Analytics

### Events Tracking

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Events métier
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logPurchase({
    required double value,
    required String currency,
    required List<AnalyticsEventItem> items,
  }) async {
    await _analytics.logPurchase(
      value: value,
      currency: currency,
      items: items,
    );
  }

  // Events custom
  Future<void> logConversationStarted(String sellerId) async {
    await _analytics.logEvent(
      name: 'conversation_started',
      parameters: {
        'seller_id': sellerId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPartRequest({
    required String partName,
    required String vehicleBrand,
  }) async {
    await _analytics.logEvent(
      name: 'part_request_created',
      parameters: {
        'part_name': partName,
        'vehicle_brand': vehicleBrand,
      },
    );
  }
}
```

### User Properties

```dart
// Segmentation utilisateurs
await FirebaseAnalytics.instance.setUserProperty(
  name: 'user_type',
  value: 'seller',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'registration_date',
  value: DateFormat('yyyy-MM').format(DateTime.now()),
);
```

### Funnel Analysis

```dart
// Funnel : Découverte → Conversation → Achat
class ConversionFunnel {
  final AnalyticsService _analytics;

  Future<void> trackFunnel() async {
    // Étape 1
    await _analytics.logEvent(name: 'funnel_part_viewed');

    // Étape 2
    await _analytics.logEvent(name: 'funnel_contact_seller');

    // Étape 3
    await _analytics.logEvent(name: 'funnel_negotiation_started');

    // Étape 4
    await _analytics.logEvent(name: 'funnel_purchase_completed');
  }
}
```

---

## ⚡ Firebase Performance

### Automatic Traces

Firebase suit automatiquement :
- App start time
- Screen rendering
- HTTP/HTTPS network requests

### Custom Traces

```dart
// Mesurer performance d'une opération
Future<void> fetchConversationsWithTrace() async {
  final trace = FirebasePerformance.instance.newTrace('fetch_conversations');
  await trace.start();

  try {
    final conversations = await conversationRepository.fetch();

    // Métriques custom
    trace.setMetric('conversation_count', conversations.length);
    trace.incrementMetric('api_calls', 1);

    return conversations;
  } finally {
    await trace.stop();
  }
}
```

### HTTP Request Monitoring

```dart
// Automatique avec Firebase Performance Plugin
final dio = Dio();
dio.interceptors.add(FirebasePerformanceInterceptor());

// Toutes les requêtes Dio seront monitorées
```

### Performance Metrics

**Firebase Console → Performance → Traces**

Surveiller :
- App start time < 2s
- Screen load time < 500ms
- API response time < 200ms
- Frame rendering < 16ms (60 FPS)

---

## 🗄️ Supabase Monitoring

### Database Performance

**Supabase Dashboard → Database → Query Performance**

```sql
-- Top 10 requêtes lentes
SELECT
  query,
  calls,
  total_time,
  mean_time,
  max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### API Usage

**Supabase Dashboard → API → Usage**

Surveiller :
- Requests/second
- Bandwidth usage
- Connections actives
- Database size

### Realtime Connections

**Supabase Dashboard → Realtime → Connections**

Métriques :
- Connexions simultanées
- Messages/second
- Latence moyenne

### Alerts Supabase

Configurer via Dashboard :
- Database > 80% capacity
- API requests > rate limit
- Slow queries detected

---

## 📝 Application Logging

### Structured Logging

```dart
class AppLogger {
  static void info(String message, {Map<String, dynamic>? metadata}) {
    final log = {
      'level': 'INFO',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    print(jsonEncode(log));

    // Envoyer à service externe si nécessaire
    _sendToLoggingService(log);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final log = {
      'level': 'ERROR',
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    print(jsonEncode(log));

    // Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
  }

  static void warning(String message, {Map<String, dynamic>? metadata}) {
    final log = {
      'level': 'WARNING',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    print(jsonEncode(log));
  }
}

// Usage
AppLogger.info('User logged in', metadata: {'userId': user.id, 'method': 'email'});
AppLogger.error('Failed to fetch conversations', error: e, stackTrace: st);
```

### Log Levels

| Level | Usage | Environnement |
|-------|-------|---------------|
| DEBUG | Détails développement | Dev uniquement |
| INFO | Événements métier | Tous |
| WARNING | Comportements anormaux non-bloquants | Tous |
| ERROR | Erreurs récupérables | Tous |
| FATAL | Crashes app | Tous |

---

## 📊 KPIs & Métriques

### Métriques Techniques

| Métrique | Target | Alerte si |
|----------|--------|-----------|
| **Crash-free rate** | > 99.5% | < 99% |
| **App start time** | < 2s | > 3s |
| **API response time** | < 200ms | > 500ms |
| **Database query time** | < 100ms | > 300ms |
| **Frame rendering** | 60 FPS | < 30 FPS |

### Métriques Business

```dart
// DAU (Daily Active Users)
FirebaseAnalytics.instance.logEvent(name: 'session_start');

// Retention (J+1, J+7, J+30)
FirebaseAnalytics.instance.logEvent(name: 'app_opened');

// Conversion Rate
final conversionRate = (purchaseCount / visitCount) * 100;
```

### Custom Dashboards

**Firebase Console → Analytics → Dashboards**

Créer dashboard avec :
- Utilisateurs actifs (DAU/MAU)
- Taux de conversion funnel
- Top 10 pièces recherchées
- Temps moyen de réponse vendeurs

---

## 🚨 Alerting Strategy

### Niveaux de Sévérité

**P0 - Critical** (réponse immédiate)
- App crashes > 5%
- API down > 5 minutes
- Database down
- Fuite de données

**P1 - High** (réponse < 1h)
- Crash rate > 2%
- API latency > 1s
- Feature critique cassée

**P2 - Medium** (réponse < 4h)
- Performance dégradée
- Bug affectant une feature

**P3 - Low** (réponse < 24h)
- Bug mineur
- Amélioration UX

### Channels d'Alertes

```yaml
# Alert routing
Critical (P0):
  - PagerDuty → On-call engineer
  - Slack → #incidents
  - Email → tech-leads

High (P1):
  - Slack → #alerts
  - Email → dev-team

Medium/Low (P2/P3):
  - Slack → #monitoring
  - GitHub Issue auto-created
```

---

## 🔍 Debugging Production

### Remote Debugging

```dart
// Activer logs détaillés pour un user spécifique
if (userId == 'debug-user-123') {
  Logger.level = Level.DEBUG;
}

// Feature flags pour debugging
if (RemoteConfig.getBool('enable_detailed_logs')) {
  AppLogger.info('Detailed logging enabled');
}
```

### User Session Recording

```dart
class SessionRecorder {
  final List<Map<String, dynamic>> _events = [];

  void recordEvent(String name, Map<String, dynamic> data) {
    _events.add({
      'event': name,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Limite à 100 events
    if (_events.length > 100) _events.removeAt(0);
  }

  Future<void> uploadSessionOnCrash() async {
    // Upload events à Crashlytics
    FirebaseCrashlytics.instance.log(jsonEncode(_events));
  }
}
```

---

## 📈 Health Checks

### Backend Health Endpoint

```dart
// Vérifier santé du backend régulièrement
Future<bool> checkBackendHealth() async {
  try {
    final response = await dio.get('/health');
    return response.statusCode == 200;
  } catch (e) {
    AppLogger.error('Backend health check failed', error: e);
    return false;
  }
}

// Schedule toutes les 5 minutes
Timer.periodic(Duration(minutes: 5), (_) async {
  final isHealthy = await checkBackendHealth();
  if (!isHealthy) {
    // Alert équipe
    sendAlert('Backend unhealthy');
  }
});
```

### App Health Score

```dart
class AppHealthMonitor {
  double calculateHealthScore() {
    final crashFreeRate = FirebaseCrashlytics.instance.getCrashFreeRate();
    final avgResponseTime = PerformanceMonitor.getAvgResponseTime();
    final errorRate = ErrorTracker.getErrorRate();

    // Score sur 100
    double score = 100;
    score -= (1 - crashFreeRate) * 50; // Poids: 50%
    score -= (avgResponseTime > 500 ? 20 : 0); // Poids: 20%
    score -= errorRate * 30; // Poids: 30%

    return score.clamp(0, 100);
  }
}
```

---

## 🔗 Ressources

### Documentation
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)
- [Supabase Monitoring](https://supabase.com/docs/guides/platform/metrics)

### Tools
- [Firebase Console](https://console.firebase.google.com)
- [Supabase Dashboard](https://app.supabase.com)
- [Sentry](https://sentry.io) (optionnel)

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe DevOps
**Version** : 1.0.0