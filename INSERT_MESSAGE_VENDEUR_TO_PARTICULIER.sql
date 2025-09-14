-- 🎯 COMMANDE SQL POUR TESTER VENDEUR → PARTICULIER (direction inverse)
-- À exécuter dans Supabase SQL Editor

-- 1. Insérer un MESSAGE NON LU du vendeur vers le particulier
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
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',  -- ID conversation existante
    '618928a1-5fb5-46e7-b58b-88b10ce523ce',  -- ID vendeur (pas particulier)
    'seller',    -- ⚠️ IMPORTANT: 'seller' pour déclencher effets côté particulier
    'Vendeur Auto Parts',
    '🔥 NOUVEAU MESSAGE VENDEUR - Le particulier doit voir: animation + bordure rouge + badge !',
    'text',
    false,       -- ⚠️ IMPORTANT: is_read=false pour compteur
    NOW(),
    NOW()
);

-- 2. Mettre à jour la conversation
UPDATE conversations
SET
    last_message_content = '🔥 NOUVEAU MESSAGE VENDEUR - Le particulier doit voir: animation + bordure rouge + badge !',
    last_message_sender_type = 'seller',
    last_message_created_at = NOW(),
    updated_at = NOW()
WHERE id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';

-- 3. VÉRIFICATION - Voir le message créé
SELECT
    id,
    sender_type,
    sender_id,
    is_read,
    content,
    created_at
FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND is_read = false
ORDER BY created_at DESC
LIMIT 3;

-- ============================================
-- RÉSULTAT ATTENDU CÔTÉ PARTICULIER :
-- ✅ Badge rouge avec compteur dans l'interface
-- ✅ Animation pulse sur la conversation
-- ✅ Bordure rouge autour de la conversation
-- ✅ Gradient rouge en arrière-plan
-- ✅ Ombre plus prononcée
-- ============================================