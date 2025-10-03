import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cente_pice/src/core/services/rate_limiter_service.dart';

void main() {
  group('RateLimiterService', () {
    late SharedPreferences prefs;
    late RateLimiterService rateLimiter;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      rateLimiter = RateLimiterService(prefs);
      await rateLimiter.resetForTesting();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('devrait autoriser la première recherche', () async {
      final canMakeSearch = await rateLimiter.canMakeSearch();

      expect(canMakeSearch, isTrue);
    });

    test('devrait autoriser jusqu\'à 3 recherches', () async {
      expect(await rateLimiter.canMakeSearch(), isTrue);
      await rateLimiter.recordAttempt();

      expect(await rateLimiter.canMakeSearch(), isTrue);
      await rateLimiter.recordAttempt();

      expect(await rateLimiter.canMakeSearch(), isTrue);
      await rateLimiter.recordAttempt();

      // La 4ème recherche devrait être refusée
      expect(await rateLimiter.canMakeSearch(), isFalse);
    });

    test('devrait refuser après 3 tentatives', () async {
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();

      final canMakeSearch = await rateLimiter.canMakeSearch();

      expect(canMakeSearch, isFalse);
    });

    test('getRemainingAttempts devrait retourner 3 au début', () async {
      final remaining = await rateLimiter.getRemainingAttempts();

      expect(remaining, 3);
    });

    test('getRemainingAttempts devrait décrémenter après chaque tentative', () async {
      expect(await rateLimiter.getRemainingAttempts(), 3);

      await rateLimiter.recordAttempt();
      expect(await rateLimiter.getRemainingAttempts(), 2);

      await rateLimiter.recordAttempt();
      expect(await rateLimiter.getRemainingAttempts(), 1);

      await rateLimiter.recordAttempt();
      expect(await rateLimiter.getRemainingAttempts(), 0);
    });

    test('getRemainingAttempts ne devrait jamais être négatif', () async {
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt(); // Une de plus que la limite

      final remaining = await rateLimiter.getRemainingAttempts();

      expect(remaining, 0);
      expect(remaining, greaterThanOrEqualTo(0));
    });

    test('getTimeUntilReset devrait retourner un temps entre 0 et 5', () async {
      await rateLimiter.recordAttempt();

      final timeUntilReset = await rateLimiter.getTimeUntilReset();

      expect(timeUntilReset, greaterThanOrEqualTo(0));
      expect(timeUntilReset, lessThanOrEqualTo(5));
    });

    test('getTimeUntilReset devrait retourner environ 5 minutes après une tentative', () async {
      await rateLimiter.recordAttempt();

      final timeUntilReset = await rateLimiter.getTimeUntilReset();

      expect(timeUntilReset, greaterThan(0));
      expect(timeUntilReset, lessThanOrEqualTo(5));
    });

    test('devrait persister les tentatives dans SharedPreferences', () async {
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();

      // Créer une nouvelle instance pour vérifier la persistance
      final newRateLimiter = RateLimiterService(prefs);
      final remaining = await newRateLimiter.getRemainingAttempts();

      expect(remaining, 1); // 3 - 2 tentatives
    });

    test('resetForTesting devrait réinitialiser le compteur', () async {
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();

      expect(await rateLimiter.canMakeSearch(), isFalse);

      await rateLimiter.resetForTesting();

      expect(await rateLimiter.canMakeSearch(), isTrue);
      expect(await rateLimiter.getRemainingAttempts(), 3);
    });

    test('devrait stocker le lastReset timestamp', () async {
      await rateLimiter.recordAttempt();

      final lastReset = prefs.getInt('plate_search_last_reset');

      expect(lastReset, isNotNull);
      expect(lastReset, greaterThan(0));
    });

    test('devrait gérer des appels concurrents correctement', () async {
      final futures = <Future<void>>[];

      for (int i = 0; i < 5; i++) {
        futures.add(rateLimiter.recordAttempt());
      }

      await Future.wait(futures);

      // Le compteur ne devrait pas dépasser la limite
      final remaining = await rateLimiter.getRemainingAttempts();
      expect(remaining, greaterThanOrEqualTo(0));
    });

    test('canMakeSearch devrait vérifier et réinitialiser si nécessaire', () async {
      // Enregistrer 3 tentatives
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();

      // Devrait être bloqué
      expect(await rateLimiter.canMakeSearch(), isFalse);

      // Simuler un ancien reset (il y a plus de 5 minutes)
      final oldTimestamp = DateTime.now().millisecondsSinceEpoch - (6 * 60 * 1000);
      await prefs.setInt('plate_search_last_reset', oldTimestamp);

      // Devrait autoriser car la fenêtre de temps est écoulée
      final canMakeSearch = await rateLimiter.canMakeSearch();

      expect(canMakeSearch, isTrue);
      expect(await rateLimiter.getRemainingAttempts(), 3);
    });

    test('recordAttempt devrait réinitialiser automatiquement si nécessaire', () async {
      // Simuler un ancien reset
      final oldTimestamp = DateTime.now().millisecondsSinceEpoch - (6 * 60 * 1000);
      await prefs.setInt('plate_search_last_reset', oldTimestamp);

      // Créer une clé d'attempts pour simuler 3 tentatives existantes
      final today = DateTime.now();
      final dateKey = '${today.year}_${today.month}_${today.day}_${today.hour ~/ (5 / 60).ceil()}';
      await prefs.setInt('plate_search_attempts_$dateKey', 3);

      // Enregistrer une nouvelle tentative
      await rateLimiter.recordAttempt();

      // Devrait avoir été réinitialisé à 1 tentative
      final remaining = await rateLimiter.getRemainingAttempts();
      expect(remaining, 2); // 3 - 1
    });

    test('getRemainingAttempts devrait réinitialiser automatiquement si nécessaire', () async {
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();
      await rateLimiter.recordAttempt();

      // Simuler l'expiration de la fenêtre de temps
      final oldTimestamp = DateTime.now().millisecondsSinceEpoch - (6 * 60 * 1000);
      await prefs.setInt('plate_search_last_reset', oldTimestamp);

      final remaining = await rateLimiter.getRemainingAttempts();

      expect(remaining, 3);
    });

    test('devrait générer une clé unique par fenêtre de temps', () async {
      await rateLimiter.recordAttempt();

      // Récupérer toutes les clés
      final keys = prefs.getKeys();
      final attemptKeys = keys.where((k) => k.startsWith('plate_search_attempts_')).toList();

      expect(attemptKeys.length, 1);
    });

    test('getTimeUntilReset devrait décrémenter avec le temps', () async {
      await rateLimiter.recordAttempt();

      final time1 = await rateLimiter.getTimeUntilReset();

      await Future.delayed(const Duration(seconds: 1));

      final time2 = await rateLimiter.getTimeUntilReset();

      expect(time2, lessThanOrEqualTo(time1));
    });

    test('devrait maintenir l\'intégrité des données entre plusieurs instances', () async {
      final service1 = RateLimiterService(prefs);
      await service1.recordAttempt();

      final service2 = RateLimiterService(prefs);
      await service2.recordAttempt();

      final service3 = RateLimiterService(prefs);
      final remaining = await service3.getRemainingAttempts();

      expect(remaining, 1); // 3 - 2 tentatives
    });
  });
}
