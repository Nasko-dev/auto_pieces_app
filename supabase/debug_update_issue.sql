-- Script de debug pour comprendre pourquoi l'update ne fonctionne pas

-- 1. Vérifier si l'annonce existe
SELECT
    'Annonce trouvée' as status,
    id,
    user_id,
    part_name,
    created_at
FROM part_advertisements
WHERE id = '2d949987-6a3d-467a-b01f-09c9f3428fab';

-- 2. Vérifier le device_id du particulier propriétaire
SELECT
    'Particulier trouvé' as status,
    p.id as particulier_id,
    p.device_id,
    p.full_name
FROM part_advertisements pa
JOIN particuliers p ON p.id = pa.user_id
WHERE pa.id = '2d949987-6a3d-467a-b01f-09c9f3428fab';

-- 3. Comparer les device_ids
SELECT
    CASE
        WHEN p.device_id = 'device_1761207781009_ssx265g5' THEN 'MATCH ✓'
        ELSE 'NO MATCH ✗ - Device ID attendu: ' || COALESCE(p.device_id, 'NULL')
    END as device_check,
    p.device_id as stored_device_id,
    'device_1761207781009_ssx265g5' as provided_device_id
FROM part_advertisements pa
LEFT JOIN particuliers p ON p.id = pa.user_id
WHERE pa.id = '2d949987-6a3d-467a-b01f-09c9f3428fab';

-- 4. Tester la fonction directement
SELECT * FROM update_part_advertisement_by_device(
    '2d949987-6a3d-467a-b01f-09c9f3428fab'::UUID,
    'device_1761207781009_ssx265g5',
    '{"part_name": "Test", "quantity": 5}'::JSONB
);
