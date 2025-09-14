# Guide de Test - Compteur Messages Non Lus

## 🎯 Étapes de Test

### 1. Lancer l'Application
```bash
flutter run -d emulator-5554
```

### 2. Navigation vers le Test
1. Se connecter comme particulier
2. Aller dans "Mes conversations"
3. Cliquer sur l'icône 🐛 (bug_report) dans l'AppBar
4. Vous arrivez sur `/test-unread`

### 3. Vérifications Visuelles

#### Page de Test
- ✅ Badge visible sur chaque conversation
- ✅ Couleur rouge si messages non lus, gris sinon
- ✅ Compteur affiché (ex: "0", "1", "2")
- ✅ Section debug en bas avec info détaillée

#### Animation & Effets
- ✅ Animation pulse (conversation grandit/rapetisse)
- ✅ Bordure rouge autour des conversations non lues
- ✅ Gradient rouge léger en arrière-plan
- ✅ Ombre plus prononcée

### 4. Test en Temps Réel

#### Option A: Insérer via SQL (Supabase Dashboard)
```sql
-- Copier le contenu du fichier CREATE_TEST_MESSAGES.sql
-- Exécuter dans Supabase → SQL Editor
```

#### Option B: Simuler avec un autre utilisateur
1. Ouvrir un deuxième émulateur ou navigateur
2. Se connecter comme vendeur
3. Envoyer un message dans une conversation
4. Observer les effets côté particulier immédiatement

### 5. Test du Reset
1. Cliquer sur une conversation avec messages non lus
2. Vérifier que le compteur passe à 0
3. Vérifier que les effets visuels disparaissent
4. Logs console : "👀 [ConversationItemSimple] Conversation XXX marquée comme lue"

## 🔍 Logs à Surveiller

### Console Debug (Flutter)
```
📌 [UnreadCounter] Abonnement à la conversation 63175f1f-a4dc-4101-911d-0ba540fd06d1
📊 [UnreadCounter] Chargé 1 messages non lus pour 63175f1f-a4dc-4101-911d-0ba540fd06d1
📨 [UnreadCounter] Nouveau message non lu dans 63175f1f-a4dc-4101-911d-0ba540fd06d1
🔢 [UnreadCounter] Conversation 63175f1f-a4dc-4101-911d-0ba540fd06d1: 2 non lus
👀 [ConversationItemSimple] Conversation 63175f1f-a4dc-4101-911d-0ba540fd06d1 marquée comme lue
```

### Supabase Realtime Dashboard
- Events PostgresChangeEvent.INSERT sur table `messages`
- Payload avec `sender_type`, `is_read`, `conversation_id`

## ✅ Checklist de Validation

### Fonctionnalités
- [ ] Compteur s'incrémente à la réception de messages
- [ ] Effets visuels activés automatiquement
- [ ] Compteur se remet à 0 au clic
- [ ] Effets visuels disparaissent au reset
- [ ] Messages marqués `is_read=true` en DB
- [ ] Temps réel fonctionne (nouveau message visible instantanément)

### Performance
- [ ] Pas de lag lors des animations
- [ ] Scrolling fluide
- [ ] Pas de memory leaks (dispose appelé)
- [ ] Subscriptions correctement fermées

### UI/UX
- [ ] Animation pulse visible et fluide
- [ ] Bordure rouge bien visible
- [ ] Badge lisible et bien positionné
- [ ] Gradient subtil mais perceptible
- [ ] Responsive sur différentes tailles

## 🚨 Problèmes Possibles

### Si pas d'effets visuels
1. Vérifier les IDs de conversation dans la DB
2. Vérifier `sender_type` dans les messages ('seller' vs 'user')
3. Vérifier `is_read=false`
4. Vérifier les logs console

### Si compteur incorrect
1. Vérifier la logique dans `_loadInitialUnreadCount()`
2. Vérifier le mapping vendeur/particulier
3. Vérifier les filtres dans `_handleNewMessage()`

### Si pas de temps réel
1. Vérifier la connection Supabase
2. Vérifier les channels realtime actifs
3. Vérifier les subscriptions dans RealtimeService

## 🔧 Debug Avancé

### Variables d'environnement
```dart
// Dans main.dart pour plus de logs
import 'dart:developer' as developer;

// Activer tous les logs
developer.log('Debug mode activé');
```

### Supabase Debug
```sql
-- Vérifier l'état des messages
SELECT * FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
ORDER BY created_at DESC
LIMIT 5;

-- Vérifier les subscriptions actives
-- (dans Supabase Dashboard → Realtime)
```

---

*🧪 Guide de test créé le 14 janvier 2025*
*🎯 Focus: Validation complète de la solution compteur local*