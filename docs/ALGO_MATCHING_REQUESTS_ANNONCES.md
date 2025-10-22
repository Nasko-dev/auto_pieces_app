# Algorithme de Matching : Demandes ↔ Annonces

## 🎯 Objectif

Mettre en relation automatiquement les **demandes de pièces** des particuliers avec les **annonces d'inventaire** des vendeurs (casses/pros) qui correspondent.

---

## 📋 Principe Général

### Flux complet

```
1. Particulier crée une DEMANDE (PartRequest)
   ↓
2. ALGO DE MATCHING analyse toutes les annonces
   ↓
3. Trouve les annonces qui correspondent
   ↓
4. Crée des NOTIFICATIONS pour les vendeurs concernés
   ↓
5. Vendeur voit la demande dans son dashboard
   ↓
6. Vendeur accepte → Conversation → Négociation → Vente
   ↓
7. Vente finalisée → Décrémentation du stock (-1)
```

---

## 🔍 Critères de Matching

### 1. **Pièce correspondante** (OBLIGATOIRE)
```sql
-- La pièce demandée doit matcher avec le nom de la pièce en annonce
-- Utiliser la recherche textuelle flexible
part_request.partNames[] MATCH part_advertisement.partName
```

**Logique** :
- Recherche par similarité textuelle (trigrams, full-text search)
- Ignorer la casse et les accents
- Accepter les variantes (ex: "capot avant" = "capot" = "capot av")

**Exemples** :
- ✅ Demande "Capot avant" ↔ Annonce "capot avant gauche"
- ✅ Demande "Phare" ↔ Annonce "phare avant droit"
- ❌ Demande "Capot" ↔ Annonce "Moteur complet"

---

### 2. **Véhicule compatible** (IMPORTANT)
```sql
-- Match sur marque + modèle + année (tolérance ±2 ans)
part_request.vehicleBrand = part_advertisement.vehicleBrand
AND part_request.vehicleModel = part_advertisement.vehicleModel
AND part_advertisement.vehicleYear BETWEEN (part_request.vehicleYear - 2) AND (part_request.vehicleYear + 2)
```

**Logique** :
- Marque et modèle doivent être identiques (strictement)
- Année : tolérance de ±2 ans (compatibilité générations)
- Motorisation : optionnelle, bonus de score si match

**Exemples** :
- ✅ Demande "Peugeot 206 2005" ↔ Annonce "Peugeot 206 2004" (tolérance)
- ✅ Demande "Renault Clio" ↔ Annonce "Renault Clio" (sans année)
- ❌ Demande "Peugeot 206" ↔ Annonce "Peugeot 207" (modèle différent)

---

### 3. **Type de pièce** (OBLIGATOIRE)
```sql
-- Le type doit correspondre (moteur ou carrosserie)
part_request.partType = part_advertisement.partType
```

**Valeurs** :
- `engine` : Pièces mécaniques/moteur
- `body` : Pièces de carrosserie/habitacle

**Exemples** :
- ✅ Demande type "engine" ↔ Annonce type "engine"
- ❌ Demande type "body" ↔ Annonce type "engine"

---

### 4. **Stock disponible** (CRITIQUE)
```sql
-- L'annonce doit avoir du stock disponible
part_advertisement.quantity_available > 0
AND part_advertisement.status = 'active'
```

**Règles** :
- Si `quantity_available = 0` → Annonce IGNORÉE
- Si `status != 'active'` → Annonce IGNORÉE (vendue, pausée, supprimée)

---

### 5. **Proximité géographique** (BONUS)
```sql
-- Prioriser les vendeurs proches du demandeur
-- Utiliser la localisation (département, ville, code postal)
CASE
  WHEN vendeur.department = particulier.department THEN score + 30
  WHEN vendeur.region = particulier.region THEN score + 15
  ELSE score + 0
END
```

**Logique** :
- Même département : +30 points
- Même région : +15 points
- Reste de la France : 0 points (mais toujours visible)

**Note** : La proximité n'élimine JAMAIS un match, elle **priorise** seulement.

---

## 🧮 Système de Score

Chaque match reçoit un **score de pertinence** :

| Critère | Points | Obligatoire |
|---------|--------|-------------|
| Nom de pièce exact | 50 | ✅ Oui |
| Nom de pièce similaire (80%+) | 30 | ✅ Oui |
| Marque + Modèle exact | 40 | ✅ Oui |
| Année compatible (±2 ans) | 20 | Non |
| Motorisation identique | 10 | Non |
| Même département | 30 | Non |
| Même région | 15 | Non |
| Stock élevé (>5 unités) | 5 | Non |

**Seuil minimum** : 120 points pour générer une notification

**Résultat** :
- Score ≥ 120 → Notification envoyée au vendeur
- Score < 120 → Aucune notification (pas assez pertinent)

---

## 🗄️ Implémentation Supabase

### Option 1 : Fonction SQL (RECOMMANDÉE)

```sql
CREATE OR REPLACE FUNCTION match_request_with_advertisements(
  p_request_id UUID
)
RETURNS TABLE (
  advertisement_id UUID,
  seller_id UUID,
  match_score INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    pa.id AS advertisement_id,
    pa.user_id AS seller_id,
    (
      -- Score base : nom de pièce
      CASE
        WHEN pa.part_name ILIKE '%' || ANY(pr.part_names) || '%' THEN 50
        WHEN similarity(pa.part_name, pr.part_names[1]) > 0.8 THEN 30
        ELSE 0
      END

      -- Score véhicule
      + CASE
        WHEN pa.vehicle_brand = pr.vehicle_brand
         AND pa.vehicle_model = pr.vehicle_model THEN 40
        ELSE 0
      END

      -- Score année
      + CASE
        WHEN pa.vehicle_year BETWEEN (pr.vehicle_year - 2) AND (pr.vehicle_year + 2) THEN 20
        ELSE 0
      END

      -- Score motorisation
      + CASE
        WHEN pa.vehicle_engine = pr.vehicle_engine THEN 10
        ELSE 0
      END

      -- Score proximité (TODO: ajouter localisation)
      + 0

      -- Bonus stock élevé
      + CASE
        WHEN pa.quantity_available > 5 THEN 5
        ELSE 0
      END

    ) AS match_score
  FROM part_advertisements pa
  CROSS JOIN part_requests pr
  WHERE pr.id = p_request_id
    AND pa.status = 'active'
    AND pa.quantity_available > 0
    AND pa.part_type = pr.part_type
    -- Filtre minimum de pertinence
    AND (
      pa.part_name ILIKE '%' || ANY(pr.part_names) || '%'
      OR similarity(pa.part_name, pr.part_names[1]) > 0.5
    )
  HAVING (
    -- Calcul du score (répété car HAVING ne peut pas utiliser l'alias)
    CASE
      WHEN pa.part_name ILIKE '%' || ANY(pr.part_names) || '%' THEN 50
      WHEN similarity(pa.part_name, pr.part_names[1]) > 0.8 THEN 30
      ELSE 0
    END
    + CASE
      WHEN pa.vehicle_brand = pr.vehicle_brand
       AND pa.vehicle_model = pr.vehicle_model THEN 40
      ELSE 0
    END
    + CASE
      WHEN pa.vehicle_year BETWEEN (pr.vehicle_year - 2) AND (pr.vehicle_year + 2) THEN 20
      ELSE 0
    END
    + CASE
      WHEN pa.vehicle_engine = pr.vehicle_engine THEN 10
      ELSE 0
    END
    + CASE
      WHEN pa.quantity_available > 5 THEN 5
      ELSE 0
    END
  ) >= 120  -- Seuil minimum
  ORDER BY match_score DESC
  LIMIT 50;  -- Limiter à 50 vendeurs max
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### Option 2 : Trigger automatique (ALTERNATIVE)

```sql
-- Trigger qui s'exécute automatiquement à la création d'une demande
CREATE OR REPLACE FUNCTION auto_match_new_request()
RETURNS TRIGGER AS $$
BEGIN
  -- Appeler la fonction de matching
  INSERT INTO seller_notifications (seller_id, request_id, match_score, created_at)
  SELECT
    seller_id,
    NEW.id,
    match_score,
    NOW()
  FROM match_request_with_advertisements(NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_match_request
  AFTER INSERT ON part_requests
  FOR EACH ROW
  EXECUTE FUNCTION auto_match_new_request();
```

**Avantage** : Automatique, pas besoin d'appeler manuellement
**Inconvénient** : Moins de contrôle, plus difficile à débugger

---

## 📊 Table de Notifications

Créer une table pour stocker les matches :

```sql
CREATE TABLE seller_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID NOT NULL REFERENCES auth.users(id),
  request_id UUID NOT NULL REFERENCES part_requests(id),
  advertisement_id UUID REFERENCES part_advertisements(id),
  match_score INTEGER NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(seller_id, request_id, advertisement_id)
);

-- Index pour performance
CREATE INDEX idx_seller_notifications_seller ON seller_notifications(seller_id, status);
CREATE INDEX idx_seller_notifications_request ON seller_notifications(request_id);
```

---

## 🚀 Utilisation dans l'App

### 1. Côté Particulier (création demande)

```dart
// Après création de la demande
await ref.read(partRequestRepositoryProvider).createPartRequest(params);

// Appeler l'algo de matching
await supabase.rpc('match_request_with_advertisements', {
  'p_request_id': newRequest.id,
});

// Les vendeurs concernés recevront automatiquement les notifications
```

### 2. Côté Vendeur (dashboard)

```dart
// Récupérer les notifications du vendeur
final notifications = await supabase
  .from('seller_notifications')
  .select('*, part_requests(*)')
  .eq('seller_id', currentUserId)
  .eq('status', 'pending')
  .order('match_score', ascending: false);

// Afficher dans home_selleur.dart
```

---

## ⚡ Optimisations Futures

### 1. **Cache des résultats**
- Stocker les matches en cache Redis
- Invalider le cache quand stock change

### 2. **Matching en temps réel**
- WebSocket Supabase pour notifier instantanément
- Notification push sur mobile

### 3. **Machine Learning**
- Analyser les transactions passées
- Améliorer le score selon les taux d'acceptation
- Prédire quels vendeurs répondent le plus vite

### 4. **Géolocalisation précise**
- Calcul de distance en km (PostGIS)
- Rayon de recherche personnalisable

### 5. **Historique de matching**
- Tracker quels vendeurs ont déjà répondu au particulier
- Prioriser les nouveaux vendeurs pour diversité

---

## 📝 Exemple Complet

### Scénario

**Particulier** : Marie cherche un capot avant pour sa Peugeot 206 de 2005 (département 75 - Paris)

**Demande créée** :
```json
{
  "partNames": ["Capot avant"],
  "partType": "body",
  "vehicleBrand": "Peugeot",
  "vehicleModel": "206",
  "vehicleYear": 2005,
  "location": "75"
}
```

**Annonces en base** :
1. **Vendeur A** : Capot avant Peugeot 206 (2004), département 75, stock 2 → **Score : 165** ✅
2. **Vendeur B** : Capot Peugeot 207 (2008), département 75, stock 1 → **Score : 80** ❌
3. **Vendeur C** : Capot avant Peugeot 206 (2006), département 92, stock 5 → **Score : 150** ✅
4. **Vendeur D** : Portière Peugeot 206 (2005), département 75, stock 3 → **Score : 60** ❌

**Résultat** :
- Vendeur A et C reçoivent une notification (score ≥ 120)
- Vendeur A est priorisé (score plus élevé + même département)
- Marie peut voir "2 vendeurs disponibles" dans son interface

---

## ✅ Checklist Implémentation

- [ ] Créer la fonction SQL `match_request_with_advertisements`
- [ ] Créer la table `seller_notifications`
- [ ] Ajouter les index de performance
- [ ] Implémenter l'appel RPC côté Flutter (particulier)
- [ ] Modifier `home_selleur.dart` pour afficher les notifications matchées
- [ ] Ajouter le système de décrémentation de stock lors de vente finalisée
- [ ] Tester avec des données réelles
- [ ] Optimiser les performances (cache, index)
- [ ] Ajouter la géolocalisation si nécessaire

---

## 🔗 Fichiers Concernés

### Backend (Supabase)
- `supabase/migrations/YYYYMMDD_matching_algorithm.sql`

### Frontend (Flutter)
- `lib/src/features/parts/data/datasources/part_request_remote_datasource.dart` (appel RPC)
- `lib/src/features/parts/presentation/pages/Vendeur/home_selleur.dart` (affichage notifications)
- `lib/src/core/providers/seller_dashboard_providers.dart` (provider notifications)

---

## 🎓 Concepts Clés

1. **Score de pertinence** : Plus le score est élevé, plus le match est pertinent
2. **Seuil minimum** : Évite de spammer les vendeurs avec des matches peu pertinents
3. **Priorisation** : Les meilleurs matches sont affichés en premier
4. **Stock disponible** : Critère bloquant, pas de notification si stock = 0
5. **Automatisation** : Le matching se fait automatiquement à la création de la demande

---

**Auteur** : William Le Gall
**Date** : 2025-01-21
**Version** : 1.0
