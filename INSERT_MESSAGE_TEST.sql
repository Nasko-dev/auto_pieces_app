-- 🎯 COMMANDE SQL POUR TESTER LES EFFETS VISUELS
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
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- ID vendeur (Edern)
    'seller',     -- ⚠️ IMPORTANT: 'seller' pour déclencher effets côté particulier
    'Edern Ferlicot',
    '🔴 NOUVEAU MESSAGE TEST - Vous devez voir: animation pulse + bordure rouge + badge !',
    'text',
    false,        -- ⚠️ IMPORTANT: is_read=false pour compteur
    NOW(),
    NOW()
);

-- 2. Mettre à jour la conversation
UPDATE conversations
SET
    last_message_content = '🔴 NOUVEAU MESSAGE TEST - Vous devez voir: animation pulse + bordure rouge + badge !',
    last_message_sender_type = 'seller',
    last_message_created_at = NOW(),
    updated_at = NOW()
WHERE id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';

-- 3. VÉRIFICATION - Voir le message créé
SELECT
    id,
    sender_type,
    is_read,
    content,
    created_at
FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND is_read = false
ORDER BY created_at DESC
LIMIT 3;

-- ============================================
-- RÉSULTAT ATTENDU DANS L'APP :
-- ✅ Badge rouge avec compteur "1" (ou plus)
-- ✅ Animation pulse continue
-- ✅ Bordure rouge autour de la conversation
-- ✅ Gradient rouge en arrière-plan
-- ✅ Ombre plus prononcée
-- ============================================