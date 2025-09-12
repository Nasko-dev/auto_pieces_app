# Base de Données - Pièces d'Occasion

## Vue d'ensemble

Cette documentation décrit le schéma de base de données Supabase pour l'application "Pièces d'Occasion". La base est optimisée pour supporter 100 000+ utilisateurs avec de bonnes performances.

## Tables Principales

### 1. `particuliers`
Utilisateurs particuliers (acheteurs de pièces)

```sql
CREATE TABLE public.particuliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  first_name text,
  last_name text,
  phone text,
  address text,
  city text,
  zip_code text,
  is_verified boolean DEFAULT false,
  is_active boolean DEFAULT true,
  is_anonymous boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  email_verified_at timestamptz
);
```

**Champs principaux:**
- `id`: UUID unique (référence avec auth.users)
- `is_anonymous`: Indique si l'utilisateur est anonyme
- `is_verified`: Profil vérifié avec documents
- Informations personnelles optionnelles

### 2. `sellers`
Vendeurs de pièces auto

```sql
CREATE TABLE public.sellers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  first_name text,
  last_name text,
  company_name text,
  phone text,
  address text,
  city text,
  zip_code text,
  siret text,
  is_active boolean DEFAULT true,
  is_verified boolean DEFAULT false,
  email_verified_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

**Champs principaux:**
- `company_name`: Nom de l'entreprise
- `siret`: Numéro SIRET pour la vérification
- `is_verified`: Vendeur vérifié par l'admin

### 3. `part_requests`
Demandes de pièces des utilisateurs

```sql
CREATE TABLE public.part_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id),
  
  -- Informations véhicule
  vehicle_plate text,
  vehicle_brand text,
  vehicle_model text,
  vehicle_year integer,
  vehicle_engine text,
  
  -- Pièce recherchée
  part_type text NOT NULL,
  part_names text[] NOT NULL,
  additional_info text,
  
  -- Métadonnées
  status text DEFAULT 'active' CHECK (status IN ('active', 'closed', 'fulfilled')),
  is_anonymous boolean DEFAULT false,
  response_count integer DEFAULT 0,
  pending_response_count integer DEFAULT 0,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '30 days')
);
```

**Champs principaux:**
- `part_names`: Array des noms de pièces recherchées
- `response_count`: Compteur total de réponses (maintenu par trigger)
- `pending_response_count`: Réponses en attente (maintenu par trigger)

### 4. `seller_responses`
Réponses des vendeurs aux demandes

```sql
CREATE TABLE public.seller_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES part_requests(id),
  seller_id uuid NOT NULL REFERENCES sellers(id),
  message text NOT NULL,
  price numeric,
  availability text,
  estimated_delivery_days integer,
  attachments jsonb DEFAULT '[]',
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

**Champs principaux:**
- `price`: Prix proposé pour la pièce
- `availability`: Disponibilité ("en stock", "2-3 jours", etc.)
- `attachments`: Photos/documents JSON

### 5. `conversations`
Conversations entre utilisateurs et vendeurs

```sql
CREATE TABLE public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES part_requests(id),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  seller_id uuid NOT NULL REFERENCES sellers(id),
  
  -- Informations dénormalisées (optimisation)
  seller_name text,
  seller_company text,
  request_title text,
  
  -- Métadonnées conversation
  status text DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  last_message_at timestamptz DEFAULT now(),
  
  -- Dernier message (dénormalisé)
  last_message_content text,
  last_message_sender_type text,
  last_message_created_at timestamptz,
  
  -- Compteurs
  unread_count integer DEFAULT 0,
  total_messages integer DEFAULT 0,
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

**Optimisations:**
- Données dénormalisées pour éviter les JOINs
- Compteurs maintenus par triggers

### 6. `messages`
Messages dans les conversations

```sql
CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations(id),
  sender_id uuid NOT NULL REFERENCES auth.users(id),
  sender_type text NOT NULL CHECK (sender_type IN ('user', 'seller')),
  
  -- Contenu
  content text NOT NULL,
  message_type text DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'offer')),
  
  -- Offres spécifiques (quand message_type = 'offer')
  offer_price numeric,
  offer_availability text,
  offer_delivery_days integer,
  
  -- Pièces jointes
  attachments jsonb DEFAULT '[]',
  metadata jsonb DEFAULT '{}',
  
  -- Lecture
  is_read boolean DEFAULT false,
  read_at timestamptz,
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

**Types de messages:**
- `text`: Message texte standard
- `image`: Image avec légende
- `offer`: Offre commerciale avec prix

### 7. `anonymous_users`
Utilisateurs temporaires anonymes

```sql
CREATE TABLE public.anonymous_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id text NOT NULL UNIQUE,
  session_token text NOT NULL UNIQUE,
  temp_email text,
  temp_phone text,
  last_active_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '7 days')
);
```

**Usage:**
- Sessions temporaires pour utilisateurs non inscrits
- Expiration automatique après 7 jours

## Index de Performance

### Index Principaux

```sql
-- Particuliers
CREATE INDEX idx_particuliers_email ON particuliers(email);
CREATE INDEX idx_particuliers_is_active ON particuliers(is_active);

-- Sellers
CREATE INDEX idx_sellers_email ON sellers(email);
CREATE INDEX idx_sellers_is_active ON sellers(is_active);

-- Part Requests
CREATE INDEX idx_part_requests_user_id ON part_requests(user_id);
CREATE INDEX idx_part_requests_status ON part_requests(status);
CREATE INDEX idx_part_requests_part_type ON part_requests(part_type);
CREATE INDEX idx_part_requests_created_at ON part_requests(created_at);

-- Conversations
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_seller_id ON conversations(seller_id);
CREATE INDEX idx_conversations_last_message_at ON conversations(last_message_at);

-- Messages
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_is_read ON messages(is_read);
```

## Triggers Automatiques

### 1. Compteurs de Réponses
Trigger `update_part_request_response_counts()` :
- Met à jour `response_count` et `pending_response_count` sur `part_requests`
- Déclenché sur INSERT/UPDATE/DELETE de `seller_responses`

### 2. Métadonnées Conversations
Trigger `update_conversation_metadata()` :
- Met à jour les informations du dernier message
- Maintient les compteurs `unread_count` et `total_messages`
- Déclenché sur INSERT/UPDATE/DELETE de `messages`

### 3. Updated_at Automatique
Trigger `update_updated_at_column()` :
- Met à jour automatiquement le champ `updated_at`
- Appliqué sur toutes les tables principales

## Politiques RLS (Row Level Security)

### Particuliers
```sql
-- Les utilisateurs ne voient que leur propre profil
CREATE POLICY "Particuliers peuvent voir leur propre profil" 
ON particuliers FOR ALL USING (auth.uid() = id::uuid);
```

### Sellers
```sql
-- Les vendeurs voient leur profil + sont visibles pour les réponses
CREATE POLICY "Sellers peuvent voir leur propre profil" 
ON sellers FOR ALL USING (auth.uid() = id::uuid);

CREATE POLICY "Sellers sont visibles pour les réponses" 
ON sellers FOR SELECT USING (is_active = true);
```

### Demandes de Pièces
```sql
-- Users créent leurs demandes et voient les leurs
-- Sellers voient toutes les demandes actives
CREATE POLICY "Users peuvent créer des demandes" 
ON part_requests FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Sellers peuvent voir les demandes actives" 
ON part_requests FOR SELECT USING (status = 'active' AND EXISTS (...));
```

## Vues Utiles

### 1. `conversations_with_details`
Conversations enrichies avec infos vendeur et demande :

```sql
CREATE VIEW conversations_with_details AS
SELECT 
  c.*,
  s.first_name as seller_first_name,
  s.company_name as seller_company_name,
  pr.part_type,
  pr.vehicle_brand
FROM conversations c
JOIN sellers s ON c.seller_id = s.id
JOIN part_requests pr ON c.request_id = pr.id;
```

### 2. `seller_stats`
Statistiques des vendeurs :

```sql
CREATE VIEW seller_stats AS
SELECT 
  s.id,
  s.company_name,
  COUNT(sr.id) as total_responses,
  COUNT(c.id) as total_conversations,
  AVG(sr.price) as avg_price
FROM sellers s
LEFT JOIN seller_responses sr ON s.id = sr.seller_id
LEFT JOIN conversations c ON s.id = c.seller_id
GROUP BY s.id;
```

## Migration

Pour mettre à jour votre base de données :

1. **Sauvegarde** : Exportez d'abord vos données
2. **Exécution** : Lancez le script `database_migration.sql` dans Supabase SQL Editor
3. **Vérification** : Contrôlez que toutes les tables et triggers sont créés
4. **Test** : Testez les opérations CRUD depuis l'app Flutter

## Optimisations Intégrées

### Performance
- **Dénormalisation** : Infos fréquentes stockées directement (seller_name, last_message)
- **Compteurs** : Maintenus par triggers pour éviter les COUNT()
- **Index** : Sur tous les champs de recherche fréquents

### Sécurité
- **RLS** : Politiques strictes par rôle utilisateur
- **UUID** : Identifiants non séquentiels
- **Validation** : Contraintes CHECK sur les statuts

### Maintenance
- **Triggers** : Mise à jour automatique des métadonnées
- **Expiration** : Nettoyage automatique des sessions anonymes
- **Timestamps** : Suivi complet des modifications

## Structure Flutter Correspondante

Ce schéma correspond aux modèles Flutter :
- `ParticulierModel` → `particuliers`
- `SellerModel` → `sellers`
- `PartRequestModel` → `part_requests`
- `ConversationModel` → `conversations`
- `MessageModel` → `messages`
- `SellerResponseModel` → `seller_responses`