-- ============================================
-- SCRIPT DE VALIDATION FINALE
-- Insérer un message test NON LU pour valider les effets visuels
-- ============================================

-- 1. Vérifier les conversations existantes pour le particulier
SELECT 
    c.id,
    c.user_id,
    c.seller_id,
    c.last_message_content,
    COUNT(m.id) as message_count
FROM conversations c
LEFT JOIN messages m ON c.id = m.conversation_id
WHERE c.user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0'
GROUP BY c.id, c.user_id, c.seller_id, c.last_message_content;

-- 2. Insérer un message NON LU du vendeur vers le particulier
INSERT INTO messages (
    id,
    conversation_id,
    sender_id,
    sender_type,
    sender_name,
    content,
    message_type,
    is_read,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM conversations WHERE user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0' LIMIT 1),
    'a525d360-6022-4016-927c-c6dc905f8af7',
    'seller',   -- ⚠️ IMPORTANT: sender_type='seller' pour message du vendeur
    'Vendeur Test',
    '🎯 VALIDATION FINALE - Message non lu pour tester effets visuels !',
    'text',
    false,      -- ⚠️ IMPORTANT: is_read=false pour déclencher les effets
    NOW(),
    NOW()
);

-- 3. Mettre à jour la conversation avec le nouveau message
UPDATE conversations 
SET 
    last_message_content = '🎯 VALIDATION FINALE - Message non lu pour tester effets visuels !',
    last_message_sender_type = 'seller',
    last_message_created_at = NOW(),
    updated_at = NOW()
WHERE user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0';

-- 4. VÉRIFICATION - Messages qui devraient être comptés comme non lus
SELECT 
    m.id,
    m.sender_type,
    m.is_read,
    m.content,
    CASE 
        WHEN m.sender_type = 'seller' AND m.is_read = false THEN '✅ SERA COMPTÉ'
        ELSE '❌ IGNORÉ'
    END as status_calcul
FROM messages m
JOIN conversations c ON m.conversation_id = c.id
WHERE c.user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0'
ORDER BY m.created_at DESC
LIMIT 10;

-- ============================================
-- RÉSULTAT ATTENDU DANS L'APP :
-- ✅ unreadCount = 1 (pour le nouveau message)  
-- ✅ hasUnread = true
-- ✅ Effets visuels : 
--    - Animation pulse (scale 1.0 → 1.05)
--    - Bordure rouge + ombrage
--    - Badge avec "1"
--    - Gradient d'arrière-plan
-- ============================================