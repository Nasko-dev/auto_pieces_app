# Diagnostic et Fix du Problème de Mise à Jour des Annonces

## Problème Identifié

L'erreur "Vous n'êtes pas autorisé à modifier cette annonce" est causée par un **mismatch entre le device_id** stocké en base et celui utilisé par l'application.

### Symptômes
- ✅ La détection de changements fonctionne (`hasPartsChanged: true`)
- ✅ L'appel RPC est effectué correctement
- ❌ La fonction SQL retourne une liste vide `[]`
- ❌ Message d'erreur: "Vous n'êtes pas autorisé à modifier cette annonce"

### Logs Flutter
```
📡 [DataSource] Device ID: device_1761207781009_ssx265g5
📡 [DataSource] Réponse RPC reçue: []
❌ [DataSource] Liste vide - annonce non trouvée ou non autorisée
```

## Étape 1: Diagnostic

### 1.1 Exécuter le Script de Diagnostic

Dans le **SQL Editor de Supabase**, exécutez le fichier `diagnostic_device_id.sql`:

```sql
-- Ce script va afficher:
-- 1. Vos annonces récentes
-- 2. Le device_id associé à l'annonce que vous essayez de modifier
-- 3. Tous les device_ids de vos particuliers
-- 4. Quel particulier utilise le device_id de l'app
```

### 1.2 Analyser les Résultats

Après l'exécution, vous devriez voir plusieurs sections de résultats. Comparez:

**Device ID dans l'app (logs Flutter):**
```
device_1761207781009_ssx265g5
```

**Device ID en base de données:**
- Si différent → **Problème de device_id** (voir Cas 1)
- Si identique → **Autre problème** (voir Cas 2)

## Étape 2: Correction

### Cas 1: Device_id a Changé (LE PLUS PROBABLE)

**Cause:** Le device_id a changé (réinstallation app, clear cache, etc.)

**Solution:** Mettre à jour le device_id du particulier en base

```sql
-- Dans SQL Editor, exécutez:
UPDATE particuliers
SET device_id = 'device_1761207781009_ssx265g5' -- Device_id actuel de l'app
WHERE id = (
    SELECT user_id
    FROM part_advertisements
    WHERE id = '2d949987-6a3d-467a-b01f-09c9f3428fab' -- ID de votre annonce
);
```

**Vérification:**
```sql
SELECT
    p.full_name,
    p.device_id,
    pa.part_name
FROM part_advertisements pa
JOIN particuliers p ON p.id = pa.user_id
WHERE pa.id = '2d949987-6a3d-467a-b01f-09c9f3428fab';
-- Le device_id devrait maintenant être: device_1761207781009_ssx265g5
```

### Cas 2: Annonce Appartient à un Autre Compte

**Cause:** Vous avez plusieurs comptes particuliers

**Solution:** Identifier et utiliser le bon compte, ou transférer l'annonce

```sql
-- Voir tous vos comptes particuliers
SELECT id, full_name, device_id, created_at
FROM particuliers
ORDER BY created_at DESC;

-- Option A: Se connecter avec le bon device_id
-- (Nécessite de retrouver le bon compte dans l'app)

-- Option B: Transférer l'annonce au compte actuel
UPDATE part_advertisements
SET user_id = (
    SELECT id FROM particuliers
    WHERE device_id = 'device_1761207781009_ssx265g5'
)
WHERE id = '2d949987-6a3d-467a-b01f-09c9f3428fab';
```

## Étape 3: Appliquer la Migration avec Debug

Pour voir les logs détaillés, exécutez dans SQL Editor:

```sql
-- Contenu du fichier: 20250123_update_function_with_debug.sql
DROP FUNCTION IF EXISTS update_part_advertisement_by_device(UUID, TEXT, JSONB);
-- ... [le reste de la migration]
```

## Étape 4: Tester la Correction

### 4.1 Test Direct en SQL

```sql
SELECT * FROM update_part_advertisement_by_device(
    '2d949987-6a3d-467a-b01f-09c9f3428fab'::UUID,
    'device_1761207781009_ssx265g5',
    '{"quantity": 5, "part_name": "Test correction"}'::JSONB
);
-- Devrait retourner 1 ligne avec les données de l'annonce mise à jour
```

### 4.2 Test dans l'Application

1. Relancez l'application Flutter
2. Allez dans "Mes Annonces"
3. Cliquez sur "Modifier" sur une annonce
4. Décochez une pièce
5. Cliquez "Enregistrer"

**Résultat attendu:**
- ✅ Notification: "Modifications enregistrées"
- ✅ Les changements sont visibles immédiatement

### 4.3 Vérifier les Logs

**Logs Flutter (console):**
```
📡 [DataSource] Device ID: device_1761207781009_ssx265g5
📡 [DataSource] Réponse RPC reçue: [...]
✅ [DataSource] Données annonce récupérées: 2d949987-6a3d-467a-b01f-09c9f3428fab
```

**Logs Supabase (si migration debug appliquée):**
```
=== DEBUG UPDATE FUNCTION ===
p_ad_id: 2d949987-6a3d-467a-b01f-09c9f3428fab
p_device_id: device_1761207781009_ssx265g5
v_user_id trouvé: [UUID]
v_particulier_device_id trouvé: device_1761207781009_ssx265g5
Comparaison: DB[device_1761207781009_ssx265g5] vs PROVIDED[device_1761207781009_ssx265g5]
SUCCESS: Device ID vérifié, mise à jour en cours...
```

## Étape 5: Nettoyer les Logs de Debug (Optionnel)

Une fois que tout fonctionne, vous pouvez retirer les logs de debug:

```sql
-- Remplacer par la version sans RAISE NOTICE
-- Exécutez: 20250123_update_stock_fields_in_update_function.sql
```

## Résumé des Fichiers Créés

- ✅ `diagnostic_device_id.sql` - Script de diagnostic
- ✅ `fix_device_id.sql` - Script de correction
- ✅ `20250123_update_function_with_debug.sql` - Fonction avec logs debug
- ✅ `DIAGNOSTIC_ET_FIX.md` - Ce guide

## Support

Si le problème persiste après avoir suivi ce guide:

1. Vérifiez que le device_id n'a pas changé à nouveau
2. Vérifiez les permissions RLS sur la table `part_advertisements`
3. Assurez-vous que la fonction SQL a bien été mise à jour
4. Consultez les logs Postgres dans Supabase Dashboard → Logs
