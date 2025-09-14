-- Script pour créer des messages de test non lus
-- À exécuter dans Supabase pour tester les effets visuels

-- 1. Vérifier les conversations existantes
SELECT id, user_id, seller_id, last_message_content
FROM conversations
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT 5;

-- 2. Insérer des messages NON LUS pour tester
-- Message du vendeur vers le particulier (sera compté comme non lu côté particulier)
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
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',  -- Utiliser un vrai ID de conversation
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- ID vendeur
    'seller',     -- ⚠️ IMPORTANT pour effets visuels côté particulier
    'Vendeur Test',
    '🎯 NOUVEAU MESSAGE TEST - Vous devriez voir les effets visuels !',
    'text',
    false,        -- ⚠️ IMPORTANT: is_read=false
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Message du particulier vers le vendeur (sera compté comme non lu côté vendeur)
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
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',  -- Même conversation
    '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0',  -- ID particulier
    'user',       -- ⚠️ IMPORTANT pour effets visuels côté vendeur
    'Particulier Test',
    '💬 Réponse du particulier - Message non lu pour le vendeur',
    'text',
    false,        -- ⚠️ IMPORTANT: is_read=false
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- 3. Mettre à jour la conversation
UPDATE conversations
SET
    last_message_content = '🎯 NOUVEAU MESSAGE TEST - Vous devriez voir les effets visuels !',
    last_message_sender_type = 'seller',
    last_message_created_at = NOW(),
    updated_at = NOW()
WHERE id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';

-- 4. VÉRIFICATION - Voir les messages non lus créés
SELECT
    m.id,
    m.conversation_id,
    m.sender_type,
    m.is_read,
    m.content,
    c.user_id as particulier_id,
    c.seller_id as vendeur_id
FROM messages m
JOIN conversations c ON m.conversation_id = c.id
WHERE m.conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND m.is_read = false
ORDER BY m.created_at DESC;

-- 5. Compter les messages non lus par type
SELECT
    sender_type,
    COUNT(*) as nb_messages_non_lus
FROM messages m
JOIN conversations c ON m.conversation_id = c.id
WHERE c.id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND m.is_read = false
GROUP BY sender_type;

-- ============================================
-- RÉSULTAT ATTENDU DANS L'APP :
-- ✅ Particulier voit 1 message non lu (sender_type='seller')
-- ✅ Vendeur voit 1 message non lu (sender_type='user')
-- ✅ Effets visuels activés des deux côtés
-- ✅ Animation pulse + bordure rouge + badges
-- ============================================