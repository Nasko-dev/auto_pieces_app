-- Script de diagnostic complet pour identifier le problème de device_id

-- Étape 1: Trouver toutes vos annonces récentes
SELECT
    '=== ANNONCES RÉCENTES ===' as section,
    id,
    part_name,
    created_at
FROM part_advertisements
ORDER BY created_at DESC
LIMIT 5;

-- Étape 2: Pour une annonce spécifique, voir le device_id associé
-- Remplacez 'VOTRE_ID_ANNONCE' par l'ID de l'annonce que vous essayez de modifier
SELECT
    '=== DEVICE_ID DE L''ANNONCE ===' as section,
    pa.id as annonce_id,
    pa.part_name,
    p.id as particulier_id,
    p.device_id as device_id_stocke,
    p.full_name,
    pa.created_at
FROM part_advertisements pa
LEFT JOIN particuliers p ON p.id = pa.user_id
WHERE pa.id = '2d949987-6a3d-467a-b01f-09c9f3428fab'; -- Remplacez par votre ID

-- Étape 3: Vérifier tous les device_ids des particuliers
SELECT
    '=== TOUS LES DEVICE_IDS ===' as section,
    id,
    full_name,
    device_id,
    created_at
FROM particuliers
ORDER BY created_at DESC;

-- Étape 4: Trouver quel particulier utilise le device_id de l'app
SELECT
    '=== RECHERCHE PAR DEVICE_ID APP ===' as section,
    id,
    full_name,
    device_id,
    created_at
FROM particuliers
WHERE device_id = 'device_1761207781009_ssx265g5'; -- Device ID visible dans les logs Flutter

-- Étape 5: Compter les annonces par particulier
SELECT
    '=== ANNONCES PAR PARTICULIER ===' as section,
    p.full_name,
    p.device_id,
    COUNT(pa.id) as nb_annonces
FROM particuliers p
LEFT JOIN part_advertisements pa ON pa.user_id = p.id
GROUP BY p.id, p.full_name, p.device_id
ORDER BY nb_annonces DESC;
