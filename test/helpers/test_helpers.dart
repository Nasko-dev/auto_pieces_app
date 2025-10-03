import 'package:flutter_test/flutter_test.dart';

/// Helper pour initialiser l'environnement de test
/// Cela évite les erreurs liées à Supabase non initialisé dans les tests
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Désactiver les logs de debug pendant les tests
  // (pour éviter les messages "Erreur sync Player ID")
  // Les erreurs sont déjà catchées dans le code de production
}

/// Helper pour mocker NotificationManager si besoin
/// Pour l'instant, on laisse le NotificationManager gérer ses propres erreurs
/// car il a déjà un try-catch dans le code
void setupNotificationManagerMock() {
  // Le NotificationManager gère déjà les erreurs avec try-catch
  // et affiche juste un debugPrint, donc on n'a pas besoin de le mocker
  //
  // Si on voulait vraiment supprimer les messages, on pourrait:
  // - Créer une version mockée de NotificationManager
  // - Utiliser un package comme mockito pour mocker la classe
  // - Mais ce n'est pas nécessaire car les tests passent malgré les messages
}
