-- Script pour corriger les conversations avec les nouveaux User IDs
-- Remplacer l'ancien user_id par le nouveau dans toutes les conversations

UPDATE conversations
SET user_id = '1001ba4e-6f09-43d9-92ce-4f878b3dec25'
WHERE user_id = 'dfcc814d-85ba-46df-ab2f-bb4a2c00c95e';

-- Vérifier le résultat
SELECT id, user_id, seller_id, request_title
FROM conversations
WHERE user_id = '1001ba4e-6f09-43d9-92ce-4f878b3dec25';