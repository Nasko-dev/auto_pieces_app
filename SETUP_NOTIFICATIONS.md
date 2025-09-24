# Configuration des Notifications Push - Guide Complet

## 🚀 Étapes de configuration

### 1. Déployer l'Edge Function

```bash
npx supabase functions deploy send-push-notification
```

### 2. Configurer les variables d'environnement Supabase

Dans votre dashboard Supabase → Settings → Edge Functions → Environment variables, ajoutez :

- `ONESIGNAL_REST_API_KEY` = Votre clé REST API OneSignal

**Comment récupérer votre clé OneSignal :**
1. Allez sur https://app.onesignal.com/
2. Sélectionnez votre app
3. Settings → Keys & IDs
4. Copiez "REST API Key"

### 3. Tester les notifications

1. Lancez votre app Flutter
2. Allez dans Paramètres
3. Cliquez sur "Lancer le diagnostic complet" → Vérifiez que tout est OK
4. Cliquez sur "Tester l'envoi de notification" → Une vraie notification devrait arriver !

### 4. Intégrer dans votre app

Utilisez `SendNotificationService` pour envoyer des notifications :

```dart
// Notification de message
final sendService = SendNotificationService.instance;
await sendService.sendMessageNotification(
  toUserId: 'uuid-destinataire',
  fromUserName: 'Alice',
  messagePreview: 'Salut ! J\'ai trouvé la pièce...',
  conversationId: 'conv-123',
);

// Notification de demande de pièce
await sendService.sendPartRequestNotification(
  sellerId: 'uuid-vendeur',
  buyerName: 'Bob',
  partName: 'Phare avant BMW X3',
  requestId: 'req-456',
);
```

## ✅ État actuel

- [x] OneSignal configuré et fonctionnel
- [x] Player IDs sauvegardés dans `push_tokens`
- [x] Edge Function créée pour envoyer les notifications
- [x] Service Dart pour appeler facilement les notifications
- [x] Interface de test dans les paramètres

## 🎯 Prochaines étapes

1. **Déployer l'Edge Function et configurer la clé OneSignal**
2. **Tester l'envoi réel de notifications**
3. **Intégrer dans les conversations et demandes de pièces**
4. **Personnaliser les notifications (sons, icônes, etc.)**

Vos notifications push sont maintenant prêtes ! 🎉