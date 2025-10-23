# 📦 Système de Gestion de Stock - Documentation Complète

**Date de création:** 22 janvier 2025
**Version:** 1.0.0
**Statut:** ✅ Production Ready

---

## 🎯 Vue d'ensemble

Le système de gestion de stock permet aux vendeurs de gérer l'inventaire de leurs pièces automobiles avec 3 modes différents:

1. **Pièce unique** (`single`) - Pour une seule pièce disponible
2. **Stock limité** (`multiple`) - Pour plusieurs pièces identiques (ex: 5 pneus)
3. **Stock illimité** (`unlimited`) - Pour les pièces toujours disponibles

---

## 🗂️ Architecture

### Fichiers modifiés

| Fichier | Description | Changements |
|---------|-------------|-------------|
| `supabase/migrations/20250122_add_stock_system.sql` | Migration SQL | Ajout colonnes + fonctions + triggers |
| `lib/src/features/parts/domain/entities/part_advertisement.dart` | Entity | +8 champs stock + 4 getters |
| `lib/src/features/parts/data/models/part_advertisement_model.dart` | Model Freezed | +8 champs dans model + conversions |

### Nouveaux champs dans `part_advertisements`

| Colonne | Type | Défaut | Description |
|---------|------|--------|-------------|
| `stock_type` | VARCHAR(20) | 'single' | Type de stock |
| `quantity` | INTEGER | NULL | Quantité disponible (NULL si unlimited) |
| `initial_quantity` | INTEGER | NULL | Quantité initiale (stats) |
| `sold_quantity` | INTEGER | 0 | Nombre vendus |
| `reserved_quantity` | INTEGER | 0 | Nombre réservés temporairement |
| `low_stock_threshold` | INTEGER | 1 | Seuil alerte stock bas |
| `auto_disable_when_empty` | BOOLEAN | true | Désactiver auto quand stock=0 |
| `stock_alert_enabled` | BOOLEAN | true | Activer alertes stock bas |

---

## 📊 Modèles de Données

### Entity PartAdvertisement

```dart
class PartAdvertisement extends Equatable {
  // Champs stock
  final String stockType; // 'single', 'multiple', 'unlimited'
  final int? quantity;
  final int? initialQuantity;
  final int soldQuantity;
  final int reservedQuantity;
  final int lowStockThreshold;
  final bool autoDisableWhenEmpty;
  final bool stockAlertEnabled;

  // Getters utiles
  int get availableQuantity; // quantity - reservedQuantity
  bool get isLowStock; // availableQuantity <= threshold
  bool get isOutOfStock; // availableQuantity == 0
  bool get isInStock; // availableQuantity > 0
}
```

### Paramètres de création

```dart
CreatePartAdvertisementParams(
  partName: 'Moteur 1.6 HDI',
  stockType: 'multiple',  // 'single', 'multiple', 'unlimited'
  quantity: 5,             // Obligatoire si multiple
  lowStockThreshold: 2,    // Alerte si ≤2
  autoDisableWhenEmpty: true,
)
```

---

## 🔧 Fonctions SQL Disponibles

### 1. `decrement_stock(advertisement_id, quantity)`

Décrémente le stock lors d'une vente.

```sql
SELECT decrement_stock('annonce-uuid', 1);
```

**Comportement:**
- Vérifie le stock disponible
- Décrémente `quantity`
- Incrémente `sold_quantity`
- Enregistre dans `stock_movements`
- Auto-désactive si stock=0 et `auto_disable_when_empty=true`

**Erreurs:**
- `Stock insuffisant` si quantité demandée > disponible

### 2. `restock_advertisement(advertisement_id, quantity, reason)`

Réapprovisionne le stock.

```sql
SELECT restock_advertisement('annonce-uuid', 10, 'Nouvel arrivage');
```

**Comportement:**
- Augmente `quantity`
- Réactive l'annonce si était `sold`
- Enregistre dans `stock_movements`

### 3. `reserve_stock(advertisement_id, quantity)`

Réserve temporairement du stock (utile pour panier).

```sql
SELECT reserve_stock('annonce-uuid', 2);
```

**Comportement:**
- Vérifie disponibilité (quantity - reserved_quantity)
- Incrémente `reserved_quantity`
- N'affecte pas `quantity` directe

### 4. `unreserve_stock(advertisement_id, quantity)`

Libère une réservation.

```sql
SELECT unreserve_stock('annonce-uuid', 2);
```

---

## 📈 Vue `advertisement_stock_status`

Vue en temps réel du statut du stock:

```sql
SELECT * FROM advertisement_stock_status WHERE id = 'annonce-uuid';
```

**Colonnes retournées:**
- `total_quantity` - Quantité totale
- `reserved_quantity` - Réservé
- `available_quantity` - Disponible (total - reserved)
- `sold_quantity` - Vendus
- `is_low_stock` - true si ≤ threshold
- `is_out_of_stock` - true si disponible = 0

---

## 🔔 Système de Notifications

### Trigger automatique `trigger_low_stock_notification`

Déclenché lors de mise à jour de `quantity` ou `reserved_quantity`.

**Condition:** Stock passe sous le seuil (`available ≤ threshold`)

**Action:** Envoie notification via `pg_notify` sur le canal `low_stock_alert`

**Payload:**
```json
{
  "advertisement_id": "uuid",
  "part_name": "Moteur 1.6 HDI",
  "available_quantity": 1,
  "threshold": 2
}
```

**Écoute côté Flutter:**
```dart
// TODO: Implémenter listener OneSignal ou Supabase Realtime
supabase
  .from('part_advertisements')
  .on('UPDATE', (payload) {
    if (payload.new.available_quantity <= payload.new.low_stock_threshold) {
      // Afficher alerte
    }
  })
  .subscribe();
```

---

## 💼 Cas d'Usage

### Cas 1: Vendeur avec pièce unique

```dart
// Création
CreatePartAdvertisementParams(
  partName: 'Capot avant Renault Clio 2015',
  stockType: 'single',
  // quantity sera automatiquement = 1
)
```

**Workflow:**
1. Annonce créée → `quantity = 1`, `status = 'active'`
2. Client achète → `decrement_stock()` → `quantity = 0`, `status = 'sold'`

### Cas 2: Vendeur avec stock multiple

```dart
// Création
CreatePartAdvertisementParams(
  partName: 'Pneu Michelin 205/55 R16',
  stockType: 'multiple',
  quantity: 8,
  lowStockThreshold: 2,
)
```

**Workflow:**
1. Annonce créée → `quantity = 8`, `initial_quantity = 8`
2. Client achète 3 → `quantity = 5`
3. Client achète 3 → `quantity = 2` → 🔔 Alerte stock bas
4. Réappro +10 → `quantity = 12`

### Cas 3: Vendeur avec stock illimité

```dart
// Création
CreatePartAdvertisementParams(
  partName: 'Filtre à huile universel',
  stockType: 'unlimited',
)
```

**Workflow:**
- `quantity` reste NULL
- Jamais d'alerte
- Annonce toujours `active`

---

## 🎨 UI/UX Recommandé

### Affichage dans la liste des annonces

```dart
// Badge de stock
if (advertisement.isOutOfStock) {
  Badge(
    label: 'Épuisé',
    color: Colors.red,
  );
} else if (advertisement.isLowStock) {
  Badge(
    label: 'Stock limité (${advertisement.availableQuantity})',
    color: Colors.orange,
  );
} else if (advertisement.stockType == 'unlimited') {
  Badge(
    label: 'Toujours disponible',
    color: Colors.green,
  );
}
```

### Page de création/modification

```dart
// Sélecteur de type de stock
DropdownButton<String>(
  value: stockType,
  items: [
    DropdownMenuItem(value: 'single', child: Text('Pièce unique')),
    DropdownMenuItem(value: 'multiple', child: Text('Stock limité')),
    DropdownMenuItem(value: 'unlimited', child: Text('Stock illimité')),
  ],
  onChanged: (value) => setState(() => stockType = value),
)

// Saisie quantité (si multiple)
if (stockType == 'multiple')
  TextField(
    decoration: InputDecoration(labelText: 'Quantité en stock'),
    keyboardType: TextInputType.number,
    controller: quantityController,
  )
```

### Page "Mes annonces" du vendeur

```dart
// Indicateur visuel
ListTile(
  title: Text(advertisement.partName),
  subtitle: Row(
    children: [
      Icon(
        advertisement.isInStock ? Icons.check_circle : Icons.cancel,
        color: advertisement.isInStock ? Colors.green : Colors.red,
        size: 16,
      ),
      SizedBox(width: 4),
      Text(
        advertisement.stockType == 'unlimited'
          ? 'Stock illimité'
          : '${advertisement.availableQuantity} disponible(s)',
      ),
    ],
  ),
  trailing: advertisement.isLowStock
    ? Chip(
        label: Text('Stock bas!'),
        backgroundColor: Colors.orange,
      )
    : null,
)
```

---

## 🧪 Tests Recommandés

### Tests unitaires

```dart
test('availableQuantity calcule correctement', () {
  final ad = PartAdvertisement(
    stockType: 'multiple',
    quantity: 10,
    reservedQuantity: 3,
  );

  expect(ad.availableQuantity, equals(7));
});

test('isLowStock détecte correctement', () {
  final ad = PartAdvertisement(
    stockType: 'multiple',
    quantity: 2,
    reservedQuantity: 0,
    lowStockThreshold: 3,
  );

  expect(ad.isLowStock, isTrue);
});
```

### Tests d'intégration SQL

```sql
-- Test décrémentation
BEGIN;
  INSERT INTO part_advertisements (id, stock_type, quantity, initial_quantity)
  VALUES ('test-uuid', 'multiple', 5, 5);

  SELECT decrement_stock('test-uuid', 2);

  SELECT quantity, sold_quantity FROM part_advertisements WHERE id = 'test-uuid';
  -- Devrait retourner: quantity=3, sold_quantity=2
ROLLBACK;
```

---

## 🔒 Sécurité et RLS

### Policies Supabase

```sql
-- Vendeurs peuvent voir leurs propres mouvements de stock
CREATE POLICY "Vendeurs peuvent voir leurs mouvements"
ON stock_movements FOR SELECT
USING (
  advertisement_id IN (
    SELECT id FROM part_advertisements WHERE user_id = auth.uid()
  )
);
```

### Validation

- Seul le propriétaire peut modifier le stock
- Les réservations expirent après 30 minutes (à implémenter côté backend)
- Historique complet dans `stock_movements` pour audit

---

## 📊 Statistiques Disponibles

### Pour le vendeur

```sql
-- Performance de vente
SELECT
  part_name,
  initial_quantity,
  sold_quantity,
  ROUND(sold_quantity::decimal / initial_quantity * 100, 2) AS sell_through_rate
FROM part_advertisements
WHERE user_id = current_user_id
  AND stock_type = 'multiple';
```

### Pour l'admin

```sql
-- Annonces avec stock critique
SELECT
  user_id,
  part_name,
  available_quantity,
  low_stock_threshold
FROM advertisement_stock_status
WHERE is_low_stock = true
  AND status = 'active';
```

---

## 🚀 Déploiement

### 1. Appliquer la migration

```bash
# Production Supabase
supabase db push

# Ou manuellement via Dashboard SQL Editor
# Copier le contenu de 20250122_add_stock_system.sql
```

### 2. Mettre à jour les annonces existantes

```sql
-- Toutes les annonces existantes deviennent "pièce unique"
UPDATE part_advertisements
SET
  stock_type = 'single',
  quantity = 1,
  initial_quantity = 1
WHERE stock_type IS NULL;
```

### 3. Déployer l'app Flutter

```bash
# Build avec nouveau code
flutter build apk --release
flutter build ios --release
```

---

## 🐛 Dépannage

### Problème: Stock négatif

**Cause:** Réservation non libérée après timeout
**Solution:** Créer un CRON job pour nettoyer les réservations expirées

```sql
-- Fonction de nettoyage (à exécuter toutes les heures)
CREATE OR REPLACE FUNCTION cleanup_expired_reservations()
RETURNS void AS $$
BEGIN
  UPDATE part_advertisements
  SET reserved_quantity = 0
  WHERE reserved_quantity > 0
    AND updated_at < NOW() - INTERVAL '30 minutes';
END;
$$ LANGUAGE plpgsql;
```

### Problème: Notification non reçue

**Vérification:**
1. `stock_alert_enabled = true` ?
2. `available_quantity` a-t-il vraiment franchi le seuil ?
3. Listener Supabase Realtime actif ?

---

## 📚 Ressources

- [Documentation Supabase Realtime](https://supabase.com/docs/guides/realtime)
- [Triggers PostgreSQL](https://www.postgresql.org/docs/current/triggers.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

**Maintenu par:** Équipe Dev
**Dernière MAJ:** 22 janvier 2025
**Contact:** support@pieceautoenligne.fr
