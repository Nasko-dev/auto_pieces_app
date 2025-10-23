-- Script de correction du device_id
-- À exécuter APRÈS avoir identifié le problème avec diagnostic_device_id.sql

-- CAS 1: Mettre à jour le device_id d'un particulier
-- Utilisez ceci si le device_id a changé (ex: après réinstall de l'app)
-- Remplacez les valeurs entre guillemets par les bonnes valeurs

-- Étape 1: Vérifier avant correction
SELECT
    '=== AVANT CORRECTION ===' as section,
    id,
    full_name,
    device_id as ancien_device_id
FROM particuliers
WHERE device_id = 'ANCIEN_DEVICE_ID'; -- Device_id actuellement en base

-- Étape 2: Effectuer la mise à jour
UPDATE particuliers
SET device_id = 'NOUVEAU_DEVICE_ID' -- Device_id utilisé par l'app (visible dans les logs)
WHERE device_id = 'ANCIEN_DEVICE_ID'; -- Device_id actuellement en base

-- Étape 3: Vérifier après correction
SELECT
    '=== APRÈS CORRECTION ===' as section,
    id,
    full_name,
    device_id as nouveau_device_id,
    updated_at
FROM particuliers
WHERE device_id = 'NOUVEAU_DEVICE_ID';

-- Étape 4: Tester la fonction update
-- Remplacez les valeurs par celles de votre annonce
SELECT * FROM update_part_advertisement_by_device(
    'ID_ANNONCE'::UUID,
    'NOUVEAU_DEVICE_ID',
    '{"part_name": "Test de mise à jour"}'::JSONB
);

-- EXEMPLE CONCRET basé sur vos logs:
/*
-- Si diagnostic_device_id.sql montre que:
-- - L'annonce 2d949987-6a3d-467a-b01f-09c9f3428fab existe
-- - Elle appartient à un particulier avec device_id différent de 'device_1761207781009_ssx265g5'
-- Alors exécutez:

UPDATE particuliers
SET device_id = 'device_1761207781009_ssx265g5'
WHERE id = (
    SELECT user_id
    FROM part_advertisements
    WHERE id = '2d949987-6a3d-467a-b01f-09c9f3428fab'
);

-- Puis testez:
SELECT * FROM update_part_advertisement_by_device(
    '2d949987-6a3d-467a-b01f-09c9f3428fab'::UUID,
    'device_1761207781009_ssx265g5',
    '{"quantity": 5}'::JSONB
);
*/
