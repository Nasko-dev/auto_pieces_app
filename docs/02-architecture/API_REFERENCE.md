# API Reference - Pièces d'Occasion

## 📋 Vue d'Ensemble

Cette référence documente toutes les API utilisées dans l'application : **Supabase API**, **Services Core**, et **API externes** (TecAlliance).

## 🗄️ Supabase Database API

### Base URL
```
https://[PROJECT_REF].supabase.co
```

### Authentication
Tous les appels utilisent le JWT token Supabase :
```dart
final headers = {
  'Authorization': 'Bearer ${supabaseClient.auth.currentSession?.accessToken}',
  'apikey': SUPABASE_ANON_KEY,
};
```

---

## 👤 Authentication API

### POST `/auth/v1/signup`
Créer un nouveau compte utilisateur.

**Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "data": {
    "first_name": "John",
    "last_name": "Doe",
    "role": "particulier"
  }
}
```

**Response 200**:
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.Mr...",
  "user": {
    "id": "uuid-123",
    "email": "user@example.com",
    "user_metadata": {
      "first_name": "John",
      "last_name": "Doe"
    }
  }
}
```

**Errors**:
- `400` - Email déjà utilisé
- `422` - Validation échouée (password trop court, etc.)

---

### POST `/auth/v1/token?grant_type=password`
Connexion avec email/password.

**Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response 200**:
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.Mr..."
}
```

**Errors**:
- `400` - Identifiants invalides
- `422` - Email non vérifié

---

### POST `/auth/v1/logout`
Déconnexion de l'utilisateur.

**Headers**:
```
Authorization: Bearer {access_token}
```

**Response 204**: No Content

---

### POST `/auth/v1/recover`
Récupération de mot de passe.

**Body**:
```json
{
  "email": "user@example.com"
}
```

**Response 200**:
```json
{
  "message": "Check your email for the password reset link"
}
```

---

## 💬 Conversations API

### GET `/rest/v1/conversations`
Récupérer les conversations d'un utilisateur.

**Query Parameters**:
```
?particulier_id=eq.{user_id}
&order=updated_at.desc
&limit=20
&offset=0
```

**Response 200**:
```json
[
  {
    "id": "conv-123",
    "particulier_id": "user-123",
    "seller_id": "seller-456",
    "part_advertisement_id": "ad-789",
    "status": "active",
    "unread_count_particulier": 2,
    "unread_count_seller": 0,
    "last_message": "Bonjour, est-ce disponible ?",
    "last_message_at": "2025-09-30T10:30:00Z",
    "created_at": "2025-09-29T14:20:00Z",
    "updated_at": "2025-09-30T10:30:00Z"
  }
]
```

**Headers**:
```
Content-Range: 0-19/150
```

---

### POST `/rest/v1/conversations`
Créer une nouvelle conversation.

**Body**:
```json
{
  "particulier_id": "user-123",
  "seller_id": "seller-456",
  "part_advertisement_id": "ad-789",
  "status": "active"
}
```

**Response 201**:
```json
{
  "id": "conv-new-123",
  "particulier_id": "user-123",
  "seller_id": "seller-456",
  "part_advertisement_id": "ad-789",
  "status": "active",
  "created_at": "2025-09-30T11:00:00Z"
}
```

---

### PATCH `/rest/v1/conversations?id=eq.{conv_id}`
Mettre à jour une conversation (ex: marquer comme lue).

**Body**:
```json
{
  "unread_count_particulier": 0
}
```

**Response 200**:
```json
{
  "id": "conv-123",
  "unread_count_particulier": 0,
  "updated_at": "2025-09-30T11:05:00Z"
}
```

---

## 💬 Messages API

### GET `/rest/v1/messages`
Récupérer les messages d'une conversation.

**Query Parameters**:
```
?conversation_id=eq.{conv_id}
&order=created_at.desc
&limit=50
&offset=0
```

**Response 200**:
```json
[
  {
    "id": "msg-123",
    "conversation_id": "conv-123",
    "sender_id": "user-123",
    "sender_type": "particulier",
    "content": "Bonjour, est-ce disponible ?",
    "image_url": null,
    "is_read": true,
    "created_at": "2025-09-30T10:30:00Z"
  },
  {
    "id": "msg-124",
    "conversation_id": "conv-123",
    "sender_id": "seller-456",
    "sender_type": "seller",
    "content": "Oui, toujours disponible !",
    "image_url": "https://storage.supabase.co/...",
    "is_read": false,
    "created_at": "2025-09-30T10:35:00Z"
  }
]
```

---

### POST `/rest/v1/messages`
Envoyer un nouveau message.

**Body**:
```json
{
  "conversation_id": "conv-123",
  "sender_id": "user-123",
  "sender_type": "particulier",
  "content": "Quel est le prix final ?",
  "image_url": null
}
```

**Response 201**:
```json
{
  "id": "msg-new-125",
  "conversation_id": "conv-123",
  "sender_id": "user-123",
  "sender_type": "particulier",
  "content": "Quel est le prix final ?",
  "is_read": false,
  "created_at": "2025-09-30T11:00:00Z"
}
```

---

## 🚗 Part Advertisements API

### GET `/rest/v1/part_advertisements`
Récupérer les annonces de pièces.

**Query Parameters**:
```
?seller_id=eq.{seller_id}
&status=eq.active
&order=created_at.desc
&limit=20
```

**Response 200**:
```json
[
  {
    "id": "ad-789",
    "seller_id": "seller-456",
    "part_name": "Pare-choc avant",
    "vehicle_brand": "Renault",
    "vehicle_model": "Clio 4",
    "vehicle_year": 2018,
    "price": 150.00,
    "condition": "good",
    "images": [
      "https://storage.supabase.co/image1.jpg",
      "https://storage.supabase.co/image2.jpg"
    ],
    "description": "Pare-choc en excellent état, peu de rayures.",
    "location": "Paris 75001",
    "status": "active",
    "views_count": 245,
    "created_at": "2025-09-25T09:00:00Z",
    "updated_at": "2025-09-30T08:00:00Z"
  }
]
```

---

### POST `/rest/v1/part_advertisements`
Créer une nouvelle annonce.

**Body**:
```json
{
  "seller_id": "seller-456",
  "part_name": "Rétroviseur droit",
  "vehicle_brand": "Peugeot",
  "vehicle_model": "208",
  "vehicle_year": 2020,
  "price": 80.00,
  "condition": "like_new",
  "images": ["https://storage.supabase.co/image1.jpg"],
  "description": "Rétroviseur comme neuf.",
  "location": "Lyon 69001",
  "status": "active"
}
```

**Response 201**:
```json
{
  "id": "ad-new-790",
  "seller_id": "seller-456",
  "part_name": "Rétroviseur droit",
  "price": 80.00,
  "status": "active",
  "created_at": "2025-09-30T11:10:00Z"
}
```

---

### PATCH `/rest/v1/part_advertisements?id=eq.{ad_id}`
Mettre à jour une annonce.

**Body**:
```json
{
  "price": 75.00,
  "status": "sold"
}
```

**Response 200**:
```json
{
  "id": "ad-789",
  "price": 75.00,
  "status": "sold",
  "updated_at": "2025-09-30T11:15:00Z"
}
```

---

### DELETE `/rest/v1/part_advertisements?id=eq.{ad_id}`
Supprimer une annonce.

**Response 204**: No Content

---

## 🔔 Notifications API

### GET `/rest/v1/seller_notifications`
Récupérer les notifications d'un vendeur.

**Query Parameters**:
```
?seller_id=eq.{seller_id}
&order=created_at.desc
&limit=20
```

**Response 200**:
```json
[
  {
    "id": "notif-123",
    "seller_id": "seller-456",
    "type": "new_message",
    "title": "Nouveau message",
    "message": "Vous avez reçu un message pour votre annonce 'Pare-choc avant'",
    "data": {
      "conversation_id": "conv-123",
      "advertisement_id": "ad-789"
    },
    "is_read": false,
    "created_at": "2025-09-30T10:30:00Z"
  }
]
```

---

### PATCH `/rest/v1/seller_notifications?id=eq.{notif_id}`
Marquer notification comme lue.

**Body**:
```json
{
  "is_read": true
}
```

**Response 200**:
```json
{
  "id": "notif-123",
  "is_read": true,
  "updated_at": "2025-09-30T11:20:00Z"
}
```

---

## 📦 Storage API

### POST `/storage/v1/object/{bucket}/{path}`
Upload d'image.

**Bucket**: `conversation-images`, `advertisement-images`

**Headers**:
```
Authorization: Bearer {access_token}
Content-Type: image/jpeg
```

**Body**: Binary image data

**Response 200**:
```json
{
  "Key": "conversation-images/user-123/image-456.jpg",
  "path": "user-123/image-456.jpg"
}
```

**URL publique**:
```
https://[PROJECT_REF].supabase.co/storage/v1/object/public/conversation-images/user-123/image-456.jpg
```

---

### DELETE `/storage/v1/object/{bucket}/{path}`
Supprimer une image.

**Response 200**:
```json
{
  "message": "Successfully deleted"
}
```

---

## 🔄 Realtime API (WebSockets)

### Subscribe to Table Changes

```dart
// Écouter les nouveaux messages
supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('conversation_id', conversationId)
  .listen((data) {
    print('New message: $data');
  });
```

### Realtime Presence

```dart
// Indiquer présence utilisateur
final channel = supabase.channel('conversation-$conversationId');
channel.on(
  RealtimeListenTypes.presence,
  ChannelFilter(event: 'sync'),
  (payload, [ref]) {
    print('Users online: ${payload['presences']}');
  },
);
channel.subscribe();

// Envoyer présence
channel.track({'user_id': userId, 'online_at': DateTime.now().toIso8601String()});
```

---

## 🚀 Core Services API

### RateLimiterService

**Empêche le spam d'actions.**

```dart
final rateLimiter = RateLimiterService(
  maxRequests: 10,
  duration: Duration(minutes: 1),
);

if (rateLimiter.shouldAllow(userId)) {
  await sendMessage(message);
} else {
  throw TooManyRequestsException('Trop de messages envoyés');
}
```

**Methods**:
- `bool shouldAllow(String key)` - Vérifie si l'action est autorisée
- `void reset(String key)` - Réinitialise le compteur pour une clé
- `int getRequestCount(String key)` - Nombre de requêtes effectuées

---

### SessionService

**Gestion de session utilisateur.**

```dart
final sessionService = SessionService();

// Sauvegarder session
await sessionService.saveSession(user);

// Récupérer session
final user = await sessionService.getCurrentUser();

// Vérifier session valide
final isValid = await sessionService.isSessionValid();

// Déconnexion
await sessionService.clearSession();
```

**Methods**:
- `Future<void> saveSession(User user)` - Sauvegarde session locale
- `Future<User?> getCurrentUser()` - Récupère utilisateur courant
- `Future<bool> isSessionValid()` - Vérifie validité session
- `Future<void> clearSession()` - Supprime session
- `Future<void> refreshSession()` - Rafraîchit le token

---

### ImageUploadService

**Upload optimisé d'images.**

```dart
final imageService = ImageUploadService();

// Upload avec compression
final imageUrl = await imageService.uploadImage(
  file: imageFile,
  bucket: 'conversation-images',
  userId: userId,
  maxWidth: 1024,
  quality: 85,
);

// Upload multiple avec parallélisation
final imageUrls = await imageService.uploadMultipleImages(
  files: [image1, image2, image3],
  bucket: 'advertisement-images',
  userId: sellerId,
);
```

**Methods**:
- `Future<String> uploadImage({required File file, required String bucket, required String userId, int? maxWidth, int? quality})` - Upload une image
- `Future<List<String>> uploadMultipleImages({required List<File> files, required String bucket, required String userId})` - Upload multiple
- `Future<void> deleteImage({required String bucket, required String path})` - Supprime une image

---

### LocationService

**Géolocalisation et geocoding.**

```dart
final locationService = LocationService();

// Position actuelle
final position = await locationService.getCurrentPosition();
print('Lat: ${position.latitude}, Lng: ${position.longitude}');

// Adresse depuis coordonnées
final address = await locationService.getAddressFromCoordinates(
  latitude: 48.8566,
  longitude: 2.3522,
);
print('Adresse: $address'); // "Paris, France"

// Coordonnées depuis adresse
final coordinates = await locationService.getCoordinatesFromAddress(
  'Tour Eiffel, Paris',
);
```

**Methods**:
- `Future<Position> getCurrentPosition()` - Position GPS actuelle
- `Future<String> getAddressFromCoordinates({required double latitude, required double longitude})` - Geocoding inverse
- `Future<Position> getCoordinatesFromAddress(String address)` - Geocoding
- `Future<bool> hasLocationPermission()` - Vérifie permission
- `Future<bool> requestLocationPermission()` - Demande permission

---

### RealtimeService

**Gestion des connexions WebSocket Supabase.**

```dart
final realtimeService = RealtimeService();

// S'abonner à une conversation
realtimeService.subscribeToConversation(
  conversationId: 'conv-123',
  onMessage: (message) {
    print('New message: ${message.content}');
  },
);

// Désabonnement
realtimeService.unsubscribeFromConversation('conv-123');

// Reconnexion automatique
realtimeService.reconnect();
```

**Methods**:
- `void subscribeToConversation({required String conversationId, required Function(Message) onMessage})` - Écoute nouveaux messages
- `void unsubscribeFromConversation(String conversationId)` - Arrête l'écoute
- `void reconnect()` - Reconnexion manuelle
- `bool isConnected()` - État de la connexion

---

## 🌐 API Externes

### TecAlliance Vehicle Identification

**Base URL**: `https://vehicle-identification.tecalliance.services/`

**Authentication**: Bearer token

```dart
final dio = Dio();
dio.options.headers['Authorization'] = 'Bearer $tecAllianceApiKey';
```

**Endpoint**: `POST /vehicles/search`

**Body**:
```json
{
  "license_plate": "AB-123-CD",
  "country": "FR"
}
```

**Response 200**:
```json
{
  "brand": "Renault",
  "model": "Clio IV",
  "year": 2018,
  "engine": "1.5 dCi",
  "power": "90 ch",
  "fuel_type": "Diesel",
  "vin": "VF1RJ***********"
}
```

**Errors**:
- `404` - Véhicule non trouvé
- `429` - Rate limit atteint
- `500` - Erreur API

---

## 🛡️ Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email invalide",
    "details": {
      "field": "email",
      "constraint": "format"
    }
  }
}
```

### HTTP Status Codes

| Code | Signification | Action |
|------|---------------|--------|
| 200 | OK | Requête réussie |
| 201 | Created | Ressource créée |
| 204 | No Content | Suppression réussie |
| 400 | Bad Request | Vérifier paramètres |
| 401 | Unauthorized | Token invalide/expiré |
| 403 | Forbidden | Pas de permission |
| 404 | Not Found | Ressource inexistante |
| 422 | Unprocessable Entity | Validation échouée |
| 429 | Too Many Requests | Rate limit atteint |
| 500 | Internal Server Error | Erreur serveur |

### Exception Classes

```dart
// Exceptions personnalisées
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class NetworkException implements Exception {}

class CacheException implements Exception {}

class RateLimitException implements Exception {
  final int retryAfter; // secondes
  RateLimitException(this.retryAfter);
}
```

---

## 📊 Rate Limits

### Supabase API

| Endpoint | Limite | Fenêtre |
|----------|--------|---------|
| `/auth/*` | 50 req | 1 minute |
| `/rest/v1/*` | 1000 req | 1 minute |
| `/storage/*` | 100 uploads | 1 minute |
| Realtime connections | 100 | Concurrent |

### Application Limits (RateLimiterService)

| Action | Limite | Fenêtre |
|--------|--------|---------|
| Envoyer message | 20 | 1 minute |
| Créer annonce | 5 | 1 heure |
| Upload image | 10 | 5 minutes |
| Recherche | 30 | 1 minute |

---

## 🔗 Liens Utiles

### Documentation Supabase
- [Supabase API Reference](https://supabase.com/docs/reference)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

### Outils de Test
- **Postman Collection** : `docs/postman/api-collection.json`
- **Supabase Studio** : Console admin en ligne
- **Flutter DevTools** : Network inspector

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe Backend
**Version API** : v1.0.0