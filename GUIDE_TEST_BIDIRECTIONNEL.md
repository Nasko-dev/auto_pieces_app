# Guide de Test - Messages Non Lus Bidirectionnels

## 🎯 Objectif
Tester que les effets visuels fonctionnent dans les deux sens :
1. **Vendeur → Particulier** (déjà testé)
2. **Particulier → Vendeur** (nouveau)
3. **Isolation des marquages** (bug corrigé)

## 🚀 Étapes de Test

### 1. Préparer l'Environnement
```bash
# L'app doit être lancée avec flutter run
```

```sql
-- Exécuter dans Supabase SQL Editor pour remettre à zéro :
-- (Copier le contenu de RESET_MESSAGES_TEST.sql)
```

### 2. Test Vendeur → Particulier

#### Créer un message non lu côté particulier
```sql
-- Exécuter la commande SQL du fichier INSERT_MESSAGE_TEST.sql
```

#### Vérifications Particulier
- ✅ Aller dans "Mes conversations"
- ✅ Voir animation pulse + bordure rouge + gradient + badge "1"
- ✅ Cliquer sur la conversation → effets disparaissent
- ✅ Compteur passe à "0"

#### Vérification Vendeur
- ✅ Ouvrir la conversation côté vendeur
- ✅ Vérifier que les effets visuels RESTENT côté particulier
- ⚠️ **BUG CORRIGÉ** : Avant, ouvrir côté vendeur supprimait les effets particulier

### 3. Test Particulier → Vendeur

#### Créer un message non lu côté vendeur
```sql
-- Exécuter la commande SQL du fichier INSERT_MESSAGE_PARTICULIER_TO_VENDEUR.sql
```

#### Vérifications Vendeur
- ✅ Aller dans "Messages clients"
- ✅ Voir animation pulse + bordure rouge + gradient + badge "1"
- ✅ Badge rouge dans l'AppBar avec compteur global
- ✅ Cliquer sur la conversation → effets disparaissent
- ✅ Compteur passe à "0"

#### Vérification Particulier
- ✅ Ouvrir la conversation côté particulier
- ✅ Vérifier que les effets visuels RESTENT côté vendeur
- ⚠️ **BUG CORRIGÉ** : Avant, ouvrir côté particulier supprimait les effets vendeur

### 4. Test Isolation Complète

#### Créer des messages non lus des deux côtés
```sql
-- 1. Message vendeur → particulier
INSERT INTO messages (
    id, conversation_id, sender_id, sender_type, sender_name, content,
    message_type, is_read, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- Vendeur
    'seller',
    'Edern Ferlicot',
    '🔴 Test isolation - Message du vendeur',
    'text', false, NOW(), NOW()
);

-- 2. Message particulier → vendeur
INSERT INTO messages (
    id, conversation_id, sender_id, sender_type, sender_name, content,
    message_type, is_read, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',
    '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0',  -- Particulier
    'user',
    'Client Particulier',
    '💙 Test isolation - Message du particulier',
    'text', false, NOW(), NOW()
);

-- Mettre à jour la conversation
UPDATE conversations
SET last_message_created_at = NOW(), updated_at = NOW()
WHERE id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';
```

#### Vérifications Simultanées
- ✅ **Côté Particulier** : Badge "1" (message du vendeur)
- ✅ **Côté Vendeur** : Badge "1" (message du particulier)
- ✅ Ouvrir côté particulier → seuls SES messages reçus se marquent lus
- ✅ Ouvrir côté vendeur → seuls SES messages reçus se marquent lus
- ✅ Chaque côté garde ses propres effets visuels

## 🔍 Indicateurs de Succès

### Animation & Effets Visuels
- 🟢 Animation pulse fluide (1.0 → 1.05)
- 🔴 Bordure rouge (2px)
- 🎨 Gradient rouge subtil (opacity: 0.08)
- 🌟 Ombre accentuée (elevation: 6)
- 🏷️ Badge rouge avec compteur

### Logique Métier
- 📊 Compteurs indépendants par utilisateur
- 🔒 Isolation des marquages "lu"
- ⚡ Temps réel fonctionnel
- 🔄 Refresh automatique

### Logs Console (Flutter)
```
✅ [VendeurController] Messages reçus marqués comme lus pour: [conversation_id]
💬 [VendeurController] Conversation [id]: X non lus
🔔 [VendeurController] Total messages non lus calculé: X
```

## ⚠️ Problèmes Résolus

1. **Bug Marquage Croisé** ✅
   - **Avant** : Ouvrir une conversation marquait tous les messages comme lus
   - **Après** : Chaque utilisateur ne marque que ses messages reçus

2. **Isolation des Effets** ✅
   - **Avant** : Les effets visuels disparaissaient pour les deux utilisateurs
   - **Après** : Chaque utilisateur garde ses propres indicateurs

3. **Compteurs Incorrects** ✅
   - **Avant** : Compteurs non synchronisés
   - **Après** : Calcul précis basé sur `senderId != currentUserId && !isRead`

## 🧪 Commandes Utiles

```sql
-- Voir l'état des messages
SELECT sender_type, is_read, content, created_at
FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
ORDER BY created_at DESC LIMIT 10;

-- Compter les non lus par type
SELECT
    sender_type,
    COUNT(CASE WHEN is_read = false THEN 1 END) as unread_count
FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
GROUP BY sender_type;
```

---

*🔄 Test bidirectionnel - Messages non lus isolés*
*✅ Bug marquage croisé corrigé*