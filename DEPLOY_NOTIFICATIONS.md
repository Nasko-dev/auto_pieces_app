# 🚀 Déploiement des notifications automatiques

## 📋 Étapes de déploiement

### 1. **Récupérer la clé API OneSignal**

Dans OneSignal Dashboard :
- **Settings** → **Keys & IDs**
- Copiez la **REST API Key** (commence par `Basic `)

### 2. **Déployer la Edge Function**

```bash
# Installer Supabase CLI si pas fait
npm install -g @supabase/cli

# Login Supabase
supabase login

# Lier votre projet
supabase link --project-ref VOTRE_PROJECT_REF

# Déployer la fonction
supabase functions deploy send-message-notification
```

### 3. **Configurer les secrets**

```bash
# Ajouter la clé API OneSignal
supabase secrets set ONESIGNAL_API_KEY="VOTRE_REST_API_KEY_ICI"

# Vérifier que les autres variables existent
supabase secrets list
```

### 4. **Exécuter le trigger SQL**

Dans Supabase Dashboard → **SQL Editor** :
```sql
-- Coller le contenu de create_trigger.sql
-- Et exécuter
```

### 5. **Tester**

- Envoyer un message dans l'app
- Vérifier les logs dans Supabase → Functions → Logs
- Confirmer la réception de notification

## ⚙️ Configuration des settings Supabase

Dans Supabase Dashboard → **Settings** → **API** :

Ajouter ces variables dans **Database Settings** :
```sql
-- Configurer les variables pour le trigger
ALTER DATABASE postgres SET app.settings.supabase_url = 'https://VOTRE_PROJECT_REF.supabase.co';
ALTER DATABASE postgres SET app.settings.service_role_key = 'VOTRE_SERVICE_ROLE_KEY';
```

## 🔧 Structure des notifications

**Quand un message est envoyé :**
```
Particulier → Vendeur : "💬 [Nom du particulier]"
Vendeur → Particulier : "💬 [Nom de l'entreprise]"
```

**Données transmises :**
- `type`: "new_message"
- `message_id`: ID du message
- `sender_id`: ID de l'expéditeur
- `conversation_group_id`: ID de la conversation
- `click_action`: "OPEN_CONVERSATION"

## 🎯 Test rapide

1. **Connectez 2 appareils** (ou 2 comptes)
2. **Démarrez une conversation**
3. **Envoyez un message**
4. **Vérifiez la notification** sur l'autre appareil

## 🐛 Debug

**Logs à vérifier :**
- Supabase → Functions → send-message-notification → Logs
- OneSignal Dashboard → Delivery → All Messages
- App Flutter : `flutter logs`

**Vérifications :**
- [ ] Player ID sauvegardé dans `user_settings`
- [ ] Trigger SQL activé sur table `messages`
- [ ] Edge Function déployée
- [ ] Secrets OneSignal configurés
- [ ] Permissions notifications accordées