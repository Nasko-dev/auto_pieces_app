# Schéma Base de Données - Pièces d'Occasion

## 🗄️ Vue d'Ensemble

Base de données PostgreSQL hébergée sur **Supabase** avec **Row Level Security (RLS)** pour sécurité maximale.

**Capacité** : Optimisé pour 100 000+ utilisateurs

---

## 📊 Diagramme ER (Entity-Relationship)

```mermaid
erDiagram
    auth_users ||--o{ particuliers : "has profile"
    auth_users ||--o{ sellers : "has profile"

    sellers ||--o{ part_advertisements : "creates"
    sellers ||--o{ seller_settings : "has"
    sellers ||--o{ seller_notifications : "receives"

    particuliers ||--o{ user_settings : "has"
    particuliers ||--o{ part_requests : "creates"
    particuliers ||--o{ conversations : "participates"

    part_advertisements ||--o{ conversations : "related to"
    part_advertisements ||--o{ seller_responses : "receives"

    conversations ||--o{ messages : "contains"
    conversations ||--|| seller_responses : "may have"
    conversations ||--o{ seller_rejections : "may have"

    part_requests ||--o{ seller_responses : "receives"

    auth_users {
        uuid id PK
        string email UK
        string encrypted_password
        timestamp created_at
        timestamp updated_at
        jsonb user_metadata
    }

    particuliers {
        uuid id PK "FK auth_users.id"
        string first_name
        string last_name
        string phone
        string email UK
        timestamp created_at
        timestamp updated_at
    }

    sellers {
        uuid id PK "FK auth_users.id"
        string business_name
        string siret UK
        string email UK
        string phone
        string address
        string city
        string postal_code
        float latitude
        float longitude
        string profile_image_url
        string business_type
        timestamp created_at
        timestamp updated_at
    }

    part_advertisements {
        uuid id PK
        uuid seller_id FK
        string part_name
        string vehicle_brand
        string vehicle_model
        int vehicle_year
        decimal price
        string condition
        text description
        jsonb images
        string location
        string status
        int views_count
        timestamp created_at
        timestamp updated_at
    }

    part_requests {
        uuid id PK
        uuid particulier_id FK
        string part_name
        string vehicle_brand
        string vehicle_model
        int vehicle_year
        text description
        string status
        timestamp created_at
        timestamp updated_at
    }

    conversations {
        uuid id PK
        uuid particulier_id FK
        uuid seller_id FK
        uuid part_advertisement_id FK
        string status
        int unread_count_particulier
        int unread_count_seller
        text last_message
        timestamp last_message_at
        timestamp created_at
        timestamp updated_at
    }

    messages {
        uuid id PK
        uuid conversation_id FK
        uuid sender_id FK
        string sender_type
        text content
        string image_url
        boolean is_read
        timestamp created_at
    }

    seller_responses {
        uuid id PK
        uuid conversation_id FK
        uuid part_request_id FK
        uuid seller_id FK
        decimal proposed_price
        text message
        string status
        timestamp created_at
        timestamp updated_at
    }

    seller_rejections {
        uuid id PK
        uuid conversation_id FK
        uuid seller_id FK
        text reason
        timestamp created_at
    }

    seller_settings {
        uuid id PK
        uuid seller_id FK UK
        boolean notifications_enabled
        boolean email_notifications
        boolean push_notifications
        string preferred_language
        jsonb notification_preferences
        timestamp created_at
        timestamp updated_at
    }

    user_settings {
        uuid id PK
        uuid particulier_id FK UK
        boolean notifications_enabled
        boolean email_notifications
        boolean push_notifications
        string preferred_language
        jsonb notification_preferences
        timestamp created_at
        timestamp updated_at
    }

    seller_notifications {
        uuid id PK
        uuid seller_id FK
        string type
        string title
        text message
        jsonb data
        boolean is_read
        timestamp created_at
        timestamp read_at
    }
```

---

## 📋 Tables Détaillées

### 1. `auth.users` (Supabase Auth)

Table gérée automatiquement par Supabase Auth.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK | Identifiant unique utilisateur |
| `email` | varchar | UNIQUE, NOT NULL | Email de connexion |
| `encrypted_password` | varchar | NOT NULL | Password hashé (bcrypt) |
| `email_confirmed_at` | timestamp | | Date confirmation email |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |
| `user_metadata` | jsonb | | Métadonnées custom (role, first_name, etc.) |

**Indexes**:
```sql
CREATE UNIQUE INDEX users_email_idx ON auth.users(email);
CREATE INDEX users_created_at_idx ON auth.users(created_at);
```

**RLS** : Géré automatiquement par Supabase Auth.

---

### 2. `public.particuliers`

Profils des utilisateurs particuliers (acheteurs).

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, FK → auth.users.id | Identifiant (même que auth.users) |
| `first_name` | varchar(100) | NOT NULL | Prénom |
| `last_name` | varchar(100) | NOT NULL | Nom |
| `phone` | varchar(20) | | Téléphone |
| `email` | varchar(255) | UNIQUE, NOT NULL | Email |
| `profile_image_url` | text | | URL photo de profil |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

**Indexes**:
```sql
CREATE UNIQUE INDEX particuliers_email_idx ON public.particuliers(email);
CREATE INDEX particuliers_created_at_idx ON public.particuliers(created_at);
```

**RLS Policies**:
```sql
-- Utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile"
ON public.particuliers FOR SELECT
USING (auth.uid() = id);

-- Utilisateurs peuvent mettre à jour leur profil
CREATE POLICY "Users can update own profile"
ON public.particuliers FOR UPDATE
USING (auth.uid() = id);

-- Vendeurs peuvent voir profils des particuliers avec qui ils conversent
CREATE POLICY "Sellers can view particuliers they converse with"
ON public.particuliers FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.particulier_id = particuliers.id
    AND conversations.seller_id = auth.uid()
  )
);
```

---

### 3. `public.sellers`

Profils des vendeurs professionnels.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, FK → auth.users.id | Identifiant (même que auth.users) |
| `business_name` | varchar(255) | NOT NULL | Nom de l'entreprise |
| `siret` | varchar(14) | UNIQUE, NOT NULL | Numéro SIRET |
| `email` | varchar(255) | UNIQUE, NOT NULL | Email professionnel |
| `phone` | varchar(20) | NOT NULL | Téléphone |
| `address` | text | NOT NULL | Adresse complète |
| `city` | varchar(100) | NOT NULL | Ville |
| `postal_code` | varchar(10) | NOT NULL | Code postal |
| `latitude` | decimal(10,8) | | Latitude (géolocalisation) |
| `longitude` | decimal(11,8) | | Longitude (géolocalisation) |
| `profile_image_url` | text | | Logo entreprise |
| `business_type` | varchar(50) | | Type (casse_auto, vendeur_pieces) |
| `description` | text | | Description entreprise |
| `website_url` | text | | Site web |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

**Indexes**:
```sql
CREATE UNIQUE INDEX sellers_email_idx ON public.sellers(email);
CREATE UNIQUE INDEX sellers_siret_idx ON public.sellers(siret);
CREATE INDEX sellers_city_idx ON public.sellers(city);
CREATE INDEX sellers_created_at_idx ON public.sellers(created_at);
-- Index spatial pour recherche géographique
CREATE INDEX sellers_location_idx ON public.sellers USING gist (
  ll_to_earth(latitude, longitude)
);
```

**RLS Policies**:
```sql
-- Vendeurs peuvent voir leur propre profil
CREATE POLICY "Sellers can view own profile"
ON public.sellers FOR SELECT
USING (auth.uid() = id);

-- Vendeurs peuvent mettre à jour leur profil
CREATE POLICY "Sellers can update own profile"
ON public.sellers FOR UPDATE
USING (auth.uid() = id);

-- Particuliers peuvent voir profils publics des vendeurs
CREATE POLICY "Particuliers can view public seller profiles"
ON public.sellers FOR SELECT
USING (true);
```

---

### 4. `public.part_advertisements`

Annonces de pièces publiées par les vendeurs.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `seller_id` | uuid | FK → sellers.id, NOT NULL | Vendeur propriétaire |
| `part_name` | varchar(255) | NOT NULL | Nom de la pièce |
| `vehicle_brand` | varchar(100) | NOT NULL | Marque du véhicule |
| `vehicle_model` | varchar(100) | NOT NULL | Modèle du véhicule |
| `vehicle_year` | int | NOT NULL, CHECK (vehicle_year >= 1950) | Année |
| `price` | decimal(10,2) | NOT NULL, CHECK (price >= 0) | Prix en euros |
| `condition` | varchar(50) | CHECK (condition IN ('new', 'like_new', 'good', 'fair', 'poor')) | État |
| `description` | text | | Description détaillée |
| `images` | jsonb | DEFAULT '[]'::jsonb | URLs des images |
| `location` | varchar(255) | | Localisation |
| `status` | varchar(20) | DEFAULT 'active', CHECK (status IN ('active', 'sold', 'reserved', 'deleted')) | Statut |
| `views_count` | int | DEFAULT 0 | Nombre de vues |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

**Indexes**:
```sql
CREATE INDEX part_ads_seller_idx ON public.part_advertisements(seller_id);
CREATE INDEX part_ads_status_idx ON public.part_advertisements(status);
CREATE INDEX part_ads_vehicle_idx ON public.part_advertisements(vehicle_brand, vehicle_model, vehicle_year);
CREATE INDEX part_ads_part_name_idx ON public.part_advertisements(part_name);
CREATE INDEX part_ads_created_at_idx ON public.part_advertisements(created_at DESC);
-- Index full-text search
CREATE INDEX part_ads_search_idx ON public.part_advertisements
USING gin(to_tsvector('french', part_name || ' ' || description));
```

**RLS Policies**:
```sql
-- Tout le monde peut voir annonces actives
CREATE POLICY "Anyone can view active advertisements"
ON public.part_advertisements FOR SELECT
USING (status = 'active');

-- Vendeurs peuvent voir toutes leurs annonces
CREATE POLICY "Sellers can view own advertisements"
ON public.part_advertisements FOR SELECT
USING (auth.uid() = seller_id);

-- Vendeurs peuvent créer annonces
CREATE POLICY "Sellers can create advertisements"
ON public.part_advertisements FOR INSERT
WITH CHECK (auth.uid() = seller_id);

-- Vendeurs peuvent mettre à jour leurs annonces
CREATE POLICY "Sellers can update own advertisements"
ON public.part_advertisements FOR UPDATE
USING (auth.uid() = seller_id);

-- Vendeurs peuvent supprimer leurs annonces
CREATE POLICY "Sellers can delete own advertisements"
ON public.part_advertisements FOR DELETE
USING (auth.uid() = seller_id);
```

---

### 5. `public.part_requests`

Demandes de pièces publiées par les particuliers.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `particulier_id` | uuid | FK → particuliers.id, NOT NULL | Particulier demandeur |
| `part_name` | varchar(255) | NOT NULL | Pièce recherchée |
| `vehicle_brand` | varchar(100) | NOT NULL | Marque du véhicule |
| `vehicle_model` | varchar(100) | NOT NULL | Modèle du véhicule |
| `vehicle_year` | int | CHECK (vehicle_year >= 1950) | Année |
| `description` | text | | Description des besoins |
| `max_price` | decimal(10,2) | CHECK (max_price >= 0) | Budget maximum |
| `urgency` | varchar(20) | CHECK (urgency IN ('low', 'medium', 'high')) | Urgence |
| `status` | varchar(20) | DEFAULT 'active', CHECK (status IN ('active', 'fulfilled', 'cancelled')) | Statut |
| `images` | jsonb | DEFAULT '[]'::jsonb | Photos de référence |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |
| `expires_at` | timestamp | | Date d'expiration |

**Indexes**:
```sql
CREATE INDEX part_requests_particulier_idx ON public.part_requests(particulier_id);
CREATE INDEX part_requests_status_idx ON public.part_requests(status);
CREATE INDEX part_requests_vehicle_idx ON public.part_requests(vehicle_brand, vehicle_model);
CREATE INDEX part_requests_created_at_idx ON public.part_requests(created_at DESC);
```

**RLS Policies**:
```sql
-- Particuliers peuvent voir leurs propres demandes
CREATE POLICY "Particuliers can view own requests"
ON public.part_requests FOR SELECT
USING (auth.uid() = particulier_id);

-- Vendeurs peuvent voir demandes actives
CREATE POLICY "Sellers can view active requests"
ON public.part_requests FOR SELECT
USING (
  status = 'active'
  AND EXISTS (SELECT 1 FROM sellers WHERE id = auth.uid())
);

-- Particuliers peuvent créer demandes
CREATE POLICY "Particuliers can create requests"
ON public.part_requests FOR INSERT
WITH CHECK (auth.uid() = particulier_id);

-- Particuliers peuvent mettre à jour leurs demandes
CREATE POLICY "Particuliers can update own requests"
ON public.part_requests FOR UPDATE
USING (auth.uid() = particulier_id);
```

---

### 6. `public.conversations`

Conversations entre particuliers et vendeurs.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `particulier_id` | uuid | FK → particuliers.id, NOT NULL | Particulier participant |
| `seller_id` | uuid | FK → sellers.id, NOT NULL | Vendeur participant |
| `part_advertisement_id` | uuid | FK → part_advertisements.id | Annonce liée (optionnel) |
| `part_request_id` | uuid | FK → part_requests.id | Demande liée (optionnel) |
| `status` | varchar(20) | DEFAULT 'active', CHECK (status IN ('active', 'archived', 'closed')) | Statut |
| `unread_count_particulier` | int | DEFAULT 0 | Messages non lus (particulier) |
| `unread_count_seller` | int | DEFAULT 0 | Messages non lus (vendeur) |
| `last_message` | text | | Dernier message (cache) |
| `last_message_at` | timestamp | | Date dernier message |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

**Indexes**:
```sql
CREATE INDEX conversations_particulier_idx ON public.conversations(particulier_id);
CREATE INDEX conversations_seller_idx ON public.conversations(seller_id);
CREATE INDEX conversations_updated_at_idx ON public.conversations(updated_at DESC);
CREATE INDEX conversations_status_idx ON public.conversations(status);
CREATE UNIQUE INDEX conversations_unique_idx ON public.conversations(
  particulier_id, seller_id, part_advertisement_id
) WHERE part_advertisement_id IS NOT NULL;
```

**RLS Policies**:
```sql
-- Participants peuvent voir leurs conversations
CREATE POLICY "Participants can view their conversations"
ON public.conversations FOR SELECT
USING (auth.uid() = particulier_id OR auth.uid() = seller_id);

-- Particuliers peuvent créer conversations
CREATE POLICY "Particuliers can create conversations"
ON public.conversations FOR INSERT
WITH CHECK (auth.uid() = particulier_id);

-- Participants peuvent mettre à jour leurs conversations
CREATE POLICY "Participants can update their conversations"
ON public.conversations FOR UPDATE
USING (auth.uid() = particulier_id OR auth.uid() = seller_id);
```

**Triggers**:
```sql
-- Mise à jour automatique de updated_at
CREATE TRIGGER update_conversations_updated_at
BEFORE UPDATE ON public.conversations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

---

### 7. `public.messages`

Messages échangés dans les conversations.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `conversation_id` | uuid | FK → conversations.id, NOT NULL | Conversation parente |
| `sender_id` | uuid | NOT NULL | Expéditeur (particulier ou seller) |
| `sender_type` | varchar(20) | NOT NULL, CHECK (sender_type IN ('particulier', 'seller')) | Type d'expéditeur |
| `content` | text | | Contenu textuel |
| `image_url` | text | | URL image attachée |
| `is_read` | boolean | DEFAULT false | Lu ou non |
| `created_at` | timestamp | DEFAULT now() | Date d'envoi |
| `read_at` | timestamp | | Date de lecture |

**Indexes**:
```sql
CREATE INDEX messages_conversation_idx ON public.messages(conversation_id, created_at DESC);
CREATE INDEX messages_sender_idx ON public.messages(sender_id);
CREATE INDEX messages_is_read_idx ON public.messages(is_read) WHERE is_read = false;
```

**RLS Policies**:
```sql
-- Participants peuvent voir messages de leurs conversations
CREATE POLICY "Participants can view conversation messages"
ON public.messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = messages.conversation_id
    AND (conversations.particulier_id = auth.uid() OR conversations.seller_id = auth.uid())
  )
);

-- Participants peuvent envoyer messages
CREATE POLICY "Participants can send messages"
ON public.messages FOR INSERT
WITH CHECK (
  auth.uid() = sender_id
  AND EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = conversation_id
    AND (conversations.particulier_id = auth.uid() OR conversations.seller_id = auth.uid())
  )
);

-- Participants peuvent marquer messages comme lus
CREATE POLICY "Participants can mark messages as read"
ON public.messages FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = messages.conversation_id
    AND (conversations.particulier_id = auth.uid() OR conversations.seller_id = auth.uid())
  )
);
```

**Triggers**:
```sql
-- Mise à jour de last_message dans conversations
CREATE TRIGGER update_conversation_last_message
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_last_message();

-- Incrémentation unread_count
CREATE TRIGGER increment_unread_count
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION increment_conversation_unread_count();
```

---

### 8. `public.seller_responses`

Réponses des vendeurs aux demandes de pièces.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `conversation_id` | uuid | FK → conversations.id, NOT NULL | Conversation associée |
| `part_request_id` | uuid | FK → part_requests.id | Demande liée |
| `seller_id` | uuid | FK → sellers.id, NOT NULL | Vendeur répondant |
| `proposed_price` | decimal(10,2) | CHECK (proposed_price >= 0) | Prix proposé |
| `message` | text | | Message accompagnant |
| `status` | varchar(20) | DEFAULT 'pending', CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')) | Statut |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

**Indexes**:
```sql
CREATE INDEX seller_responses_conversation_idx ON public.seller_responses(conversation_id);
CREATE INDEX seller_responses_seller_idx ON public.seller_responses(seller_id);
CREATE INDEX seller_responses_status_idx ON public.seller_responses(status);
```

---

### 9. `public.seller_rejections`

Rejets de conversations par les vendeurs.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `conversation_id` | uuid | FK → conversations.id, NOT NULL | Conversation rejetée |
| `seller_id` | uuid | FK → sellers.id, NOT NULL | Vendeur qui rejette |
| `reason` | text | | Raison du rejet |
| `created_at` | timestamp | DEFAULT now() | Date du rejet |

---

### 10. `public.seller_settings`

Paramètres des vendeurs.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `seller_id` | uuid | FK → sellers.id, UNIQUE, NOT NULL | Vendeur |
| `notifications_enabled` | boolean | DEFAULT true | Notifications activées |
| `email_notifications` | boolean | DEFAULT true | Notifications email |
| `push_notifications` | boolean | DEFAULT true | Notifications push |
| `preferred_language` | varchar(5) | DEFAULT 'fr' | Langue préférée |
| `notification_preferences` | jsonb | DEFAULT '{}'::jsonb | Préférences détaillées |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `updated_at` | timestamp | DEFAULT now() | Dernière mise à jour |

---

### 11. `public.user_settings`

Paramètres des particuliers.

**Structure identique à `seller_settings`**, avec `particulier_id` au lieu de `seller_id`.

---

### 12. `public.seller_notifications`

Notifications pour les vendeurs.

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| `id` | uuid | PK, DEFAULT gen_random_uuid() | Identifiant unique |
| `seller_id` | uuid | FK → sellers.id, NOT NULL | Vendeur destinataire |
| `type` | varchar(50) | NOT NULL | Type (new_message, new_request, etc.) |
| `title` | varchar(255) | NOT NULL | Titre de la notification |
| `message` | text | NOT NULL | Contenu |
| `data` | jsonb | DEFAULT '{}'::jsonb | Données supplémentaires |
| `is_read` | boolean | DEFAULT false | Lue ou non |
| `created_at` | timestamp | DEFAULT now() | Date de création |
| `read_at` | timestamp | | Date de lecture |

**Indexes**:
```sql
CREATE INDEX seller_notifs_seller_idx ON public.seller_notifications(seller_id, created_at DESC);
CREATE INDEX seller_notifs_is_read_idx ON public.seller_notifications(is_read) WHERE is_read = false;
```

---

## 🔒 Row Level Security (RLS)

**Toutes les tables ont RLS activé** :

```sql
ALTER TABLE public.particuliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.part_advertisements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
-- etc.
```

### Principe de Sécurité

1. **Isolation complète** : Chaque utilisateur voit uniquement ses données
2. **Pas de bypass** : Même le code client ne peut pas contourner RLS
3. **Policies déclaratives** : Sécurité définie au niveau base de données
4. **Performance** : PostgreSQL optimise les requêtes avec RLS

---

## ⚡ Optimisations Performance

### 1. Indexes Critiques

```sql
-- Index composites pour requêtes fréquentes
CREATE INDEX conversations_active_updated_idx
ON conversations(status, updated_at DESC)
WHERE status = 'active';

CREATE INDEX messages_unread_conv_idx
ON messages(conversation_id, is_read, created_at DESC)
WHERE is_read = false;
```

### 2. Partitioning (futur)

Pour scalabilité extrême, partitionner la table `messages` par date :

```sql
CREATE TABLE messages_2025_01 PARTITION OF messages
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### 3. Materialized Views

Pour tableaux de bord vendeurs :

```sql
CREATE MATERIALIZED VIEW seller_dashboard_stats AS
SELECT
  seller_id,
  COUNT(DISTINCT conversations.id) as total_conversations,
  COUNT(DISTINCT messages.id) as total_messages,
  SUM(CASE WHEN conversations.unread_count_seller > 0 THEN 1 ELSE 0 END) as unread_conversations
FROM sellers
LEFT JOIN conversations ON conversations.seller_id = sellers.id
LEFT JOIN messages ON messages.conversation_id = conversations.id
GROUP BY seller_id;

-- Refresh toutes les 5 minutes
CREATE INDEX ON seller_dashboard_stats(seller_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY seller_dashboard_stats;
```

---

## 🔄 Migrations

### Migration Tool: Supabase CLI

```bash
# Créer une migration
supabase migration new add_new_column

# Appliquer migrations
supabase db push

# Rollback
supabase db reset
```

### Exemple Migration

```sql
-- Migration: 20250930_add_vehicle_vin.sql
ALTER TABLE part_advertisements
ADD COLUMN vehicle_vin VARCHAR(17);

CREATE INDEX part_ads_vin_idx
ON part_advertisements(vehicle_vin)
WHERE vehicle_vin IS NOT NULL;
```

---

## 📊 Monitoring & Maintenance

### Queries de Monitoring

```sql
-- Taille des tables
SELECT
  relname as table_name,
  pg_size_pretty(pg_total_relation_size(relid)) as total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Index non utilisés
SELECT
  schemaname, tablename, indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexrelname NOT LIKE 'pg_toast_%';

-- Requêtes lentes
SELECT
  query,
  calls,
  total_time,
  mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### Maintenance Automatique

```sql
-- VACUUM automatique configuré
ALTER TABLE messages
SET (autovacuum_vacuum_scale_factor = 0.1);

-- Analyze statistiques régulier
ANALYZE messages;
ANALYZE conversations;
```

---

## 🔗 Ressources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase Database Guide](https://supabase.com/docs/guides/database)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)

---

**Dernière mise à jour** : 30/09/2025
**Mainteneur** : Équipe Database
**Version Schema** : 1.2.0