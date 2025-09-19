import 'package:cente_pice/src/core/services/rate_limiter_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rate_limiter_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferences>()])
void main() {
  late RateLimiterService rateLimiterService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    rateLimiterService = RateLimiterService(mockPrefs);
  });

  group('RateLimiterService', () {
    group('canMakeSearch', () {
      test(
        'doit permettre la recherche quand aucune tentative précédente',
        () async {
          // arrange
          when(
            mockPrefs.getInt(any),
          ).thenReturn(null); // Pas de données existantes

          // act
          final canSearch = await rateLimiterService.canMakeSearch();

          // assert
          expect(canSearch, true);
        },
      );

      test('doit permettre la recherche avec moins de 3 tentatives', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(2);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();

        // assert
        expect(canSearch, true);
      });

      test('doit refuser la recherche avec 3 tentatives ou plus', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(3);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();

        // assert
        expect(canSearch, false);
      });

      test('doit permettre la recherche après reset automatique', () async {
        // arrange - pas de reset précédent (considéré comme reset)
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(null);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(null);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();

        // assert
        expect(canSearch, true);
      });
    });

    group('recordAttempt', () {
      test('doit enregistrer la première tentative', () async {
        // arrange
        when(mockPrefs.getInt(any)).thenReturn(null);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        await rateLimiterService.recordAttempt();

        // assert
        verify(
          mockPrefs.setInt(argThat(startsWith('plate_search_attempts_')), 1),
        ).called(1);
      });

      test('doit incrémenter le nombre de tentatives', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(1);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        await rateLimiterService.recordAttempt();

        // assert
        verify(
          mockPrefs.setInt(argThat(startsWith('plate_search_attempts_')), 2),
        ).called(1);
      });

      test('doit reset avant d\'enregistrer si nécessaire', () async {
        // arrange - premier appel
        when(mockPrefs.getInt(any)).thenReturn(null);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        await rateLimiterService.recordAttempt();

        // assert
        verify(
          mockPrefs.setInt(argThat(startsWith('plate_search_attempts_')), 1),
        ).called(1);
      });
    });

    group('getRemainingAttempts', () {
      test('doit retourner 3 tentatives restantes initialement', () async {
        // arrange
        when(mockPrefs.getInt(any)).thenReturn(null);

        // act
        final remaining = await rateLimiterService.getRemainingAttempts();

        // assert
        expect(remaining, 3);
      });

      test('doit calculer correctement les tentatives restantes', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(1);

        // act
        final remaining = await rateLimiterService.getRemainingAttempts();

        // assert
        expect(remaining, 2);
      });

      test(
        'doit retourner 0 tentatives restantes quand limite atteinte',
        () async {
          // arrange
          final now = DateTime.now().millisecondsSinceEpoch;
          when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
          when(
            mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
          ).thenReturn(3);

          // act
          final remaining = await rateLimiterService.getRemainingAttempts();

          // assert
          expect(remaining, 0);
        },
      );

      test('doit retourner 3 après reset automatique', () async {
        // arrange - pas de données (équivaut à reset)
        when(mockPrefs.getInt(any)).thenReturn(null);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        final remaining = await rateLimiterService.getRemainingAttempts();

        // assert
        expect(remaining, 3);
      });
    });

    group('getTimeUntilReset', () {
      test('doit retourner 0 si aucun reset précédent', () async {
        // arrange
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(null);

        // act
        final timeUntilReset = await rateLimiterService.getTimeUntilReset();

        // assert
        expect(timeUntilReset, 0);
      });

      test('doit retourner 0 si plus de 5 minutes écoulées', () async {
        // arrange - il y a 6 minutes
        final oldTime = DateTime.now().millisecondsSinceEpoch - (6 * 60 * 1000);
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(oldTime);

        // act
        final timeUntilReset = await rateLimiterService.getTimeUntilReset();

        // assert
        expect(timeUntilReset, 0);
      });

      test('doit calculer correctement le temps restant', () async {
        // arrange - il y a 2 minutes
        final recentTime =
            DateTime.now().millisecondsSinceEpoch - (2 * 60 * 1000);
        when(
          mockPrefs.getInt('plate_search_last_reset'),
        ).thenReturn(recentTime);

        // act
        final timeUntilReset = await rateLimiterService.getTimeUntilReset();

        // assert
        expect(timeUntilReset, 3); // 5 - 2 = 3 minutes restantes
      });

      test('doit arrondir au supérieur le temps restant', () async {
        // arrange - il y a 2.1 minutes
        final recentTime =
            DateTime.now().millisecondsSinceEpoch - (126 * 1000); // 2.1 minutes
        when(
          mockPrefs.getInt('plate_search_last_reset'),
        ).thenReturn(recentTime);

        // act
        final timeUntilReset = await rateLimiterService.getTimeUntilReset();

        // assert
        expect(timeUntilReset, 3); // ceil(5 - 2.1) = 3
      });
    });

    group('resetForTesting', () {
      test('doit reset les tentatives et le timestamp', () async {
        // arrange
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        await rateLimiterService.resetForTesting();

        // assert
        verify(mockPrefs.setInt('plate_search_last_reset', any)).called(1);
        verify(
          mockPrefs.setInt(argThat(startsWith('plate_search_attempts_')), 0),
        ).called(1);
      });
    });

    group('Key Generation', () {
      test(
        'doit générer des clés différentes pour différentes heures',
        () async {
          // arrange
          when(mockPrefs.getInt(any)).thenReturn(null);
          when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

          // act - enregistrer une tentative maintenant
          await rateLimiterService.recordAttempt();

          // assert - vérifier que la clé contient la date et l'heure
          final capturedKey =
              verify(mockPrefs.setInt(captureAny, 1)).captured.first as String;
          expect(capturedKey, startsWith('plate_search_attempts_'));
          expect(capturedKey, contains('${DateTime.now().year}'));
          expect(capturedKey, contains('${DateTime.now().month}'));
          expect(capturedKey, contains('${DateTime.now().day}'));
        },
      );
    });

    group('Edge Cases', () {
      test('doit gérer les valeurs négatives dans les préférences', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(-1);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();
        final remaining = await rateLimiterService.getRemainingAttempts();

        // assert
        expect(canSearch, true); // -1 < 3
        expect(remaining, 3); // clamp empêche les valeurs négatives
      });

      test(
        'doit gérer les valeurs très élevées dans les préférences',
        () async {
          // arrange
          final now = DateTime.now().millisecondsSinceEpoch;
          when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
          when(
            mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
          ).thenReturn(100);

          // act
          final canSearch = await rateLimiterService.canMakeSearch();
          final remaining = await rateLimiterService.getRemainingAttempts();

          // assert
          expect(canSearch, false);
          expect(remaining, 0); // clamp limite à la valeur max
        },
      );

      test('doit gérer les timestamps futurs', () async {
        // arrange - timestamp dans le futur
        final futureTime = DateTime.now().millisecondsSinceEpoch + (60 * 1000);
        when(
          mockPrefs.getInt('plate_search_last_reset'),
        ).thenReturn(futureTime);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(3);

        // act
        final timeUntilReset = await rateLimiterService.getTimeUntilReset();

        // assert
        expect(timeUntilReset, greaterThan(5)); // Temps dans le futur
      });
    });

    group('Reset Logic', () {
      test('doit reset exactement après 5 minutes', () async {
        // arrange - simulation d'un état initial propre
        when(mockPrefs.getInt(any)).thenReturn(null);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();

        // assert
        expect(canSearch, true);
      });

      test('doit ne pas reset avant 5 minutes', () async {
        // arrange - 4 minutes et 59 secondes
        final recentTime =
            DateTime.now().millisecondsSinceEpoch - (4 * 60 * 1000 + 59 * 1000);
        when(
          mockPrefs.getInt('plate_search_last_reset'),
        ).thenReturn(recentTime);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(3);

        // act
        final canSearch = await rateLimiterService.canMakeSearch();

        // assert
        expect(canSearch, false);
        verifyNever(mockPrefs.setInt('plate_search_last_reset', any));
      });
    });

    group('Concurrent Access', () {
      test('doit gérer les appels simultanés correctement', () async {
        // arrange
        final now = DateTime.now().millisecondsSinceEpoch;
        when(mockPrefs.getInt('plate_search_last_reset')).thenReturn(now);
        when(
          mockPrefs.getInt(argThat(startsWith('plate_search_attempts_'))),
        ).thenReturn(2);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        // act - appels simultanés
        final futures = [
          rateLimiterService.canMakeSearch(),
          rateLimiterService.getRemainingAttempts(),
          rateLimiterService.getTimeUntilReset(),
        ];

        final results = await Future.wait(futures);

        // assert
        expect(results[0], true); // canMakeSearch
        expect(results[1], 1); // getRemainingAttempts
        expect(results[2], greaterThanOrEqualTo(0)); // getTimeUntilReset
      });
    });
  });
}
