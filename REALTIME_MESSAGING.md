# Messagerie Temps Réel - Documentation

## 📡 Vue d'ensemble

La messagerie temps réel est implémentée avec Supabase Realtime pour permettre une communication instantanée entre particuliers et vendeurs.

## 🏗 Architecture

### Services principaux

1. **RealtimeService** (`lib/src/core/services/realtime_service.dart`)
   - Gère les abonnements Supabase Realtime
   - Filtre par conversation et utilisateur
   - Diffuse les événements via des streams

2. **ConversationsController** (`lib/src/features/parts/presentation/controllers/conversations_controller.dart`)
   - État centralisé des conversations et messages
   - Méthode `addRealtimeMessage()` pour intégrer les messages temps réel
   - Gestion du marquage automatique comme lu

3. **ChatPage** (`lib/src/features/parts/presentation/pages/particulier/chat_page.dart`)
   - S'abonne aux messages de la conversation active
   - Mise à jour automatique de l'UI
   - Auto-scroll vers les nouveaux messages

## 🔧 Configuration Supabase

### Tables requises

#### Table `conversations`
```sql
- id (uuid, primary key)
- request_id (uuid)
- user_id (uuid)
- seller_id (uuid)
- status (text)
- last_message_at (timestamp)
- last_message_content (text)
- unread_count (integer)
```

#### Table `messages`
```sql
- id (uuid, primary key)
- conversation_id (uuid, foreign key)
- sender_id (uuid)
- sender_type (text: 'user' | 'seller')
- content (text)
- message_type (text: 'text' | 'offer' | 'system')
- is_read (boolean)
- created_at (timestamp)
```

### Activation Realtime

Dans Supabase Dashboard :
1. Aller dans Database > Replication
2. Activer Realtime pour les tables `messages` et `conversations`
3. Configurer les politiques RLS appropriées

## 🚀 Utilisation

### Initialisation (main.dart)
```dart
// Service démarré automatiquement au lancement
final realtimeService = RealtimeService();
await realtimeService.startRealtimeSubscriptions();
```

### Dans ChatPage
```dart
// Abonnement automatique à l'ouverture
void _subscribeToRealtimeMessages() {
  final realtimeService = ref.read(realtimeServiceProvider);
  realtimeService.subscribeToMessages(widget.conversationId);
  
  // Écoute des nouveaux messages
  _messageSubscription = realtimeService.messageStream.listen((event) {
    // Traitement automatique des nouveaux messages
  });
}
```

## 📝 Flux de données

1. **Envoi de message**
   - Utilisateur tape et envoie un message
   - Message sauvegardé dans Supabase
   - Trigger Realtime déclenché

2. **Réception temps réel**
   - RealtimeService reçoit l'événement
   - Événement filtré par conversation_id
   - Message ajouté au ConversationsController
   - UI mise à jour automatiquement

3. **Marquage comme lu**
   - Messages automatiquement marqués comme lus si conversation active
   - Compteur de messages non lus mis à jour

## 🔍 Debug et Tests

### Logs importants
- `🔔 [Realtime]` : Abonnements et connexions
- `🎉 [Realtime]` : Messages reçus
- `💬 [ChatPage]` : Événements UI
- `📡 [Controller]` : Gestion d'état

### Vérifications
1. Vérifier que Realtime est activé dans Supabase
2. Vérifier les politiques RLS
3. Tester avec deux sessions différentes
4. Observer les logs dans la console

## 🔮 Améliorations futures

- [ ] Indicateur de frappe (typing indicator)
- [ ] Notifications push
- [ ] Support des médias (images, fichiers)
- [ ] Messages vocaux
- [ ] Réactions aux messages
- [ ] Historique de lecture
- [ ] Mode hors ligne avec synchronisation

## ⚠️ Points d'attention

1. **Performance** : Les abonnements sont créés par conversation pour éviter la surcharge
2. **Sécurité** : Les filtres utilisateur empêchent la réception de messages non autorisés
3. **Cleanup** : Les abonnements sont correctement fermés dans `dispose()`
4. **Duplication** : Vérification d'unicité des messages par ID

## 📚 Références

- [Supabase Realtime Documentation](https://supabase.com/docs/guides/realtime)
- [Flutter Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)