-- Script de test pour créer un message non lu du vendeur vers particulier
-- Ce script permet de tester les effets visuels des messages non lus

-- 1. Trouver une conversation existante
SELECT id, user_id, seller_id 
FROM conversations 
WHERE user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0' 
ORDER BY created_at DESC 
LIMIT 1;

-- 2. Si pas de conversation, en créer une (remplacer les IDs selon votre contexte)
INSERT INTO conversations (
    id,
    user_id,
    seller_id, 
    part_request_id,
    status,
    last_message_content,
    last_message_sender_type,
    last_message_created_at,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0',  -- ID particulier
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- ID vendeur  
    '1afd3595-4e4b-49bf-954e-8aa935b762aa',  -- ID part_request
    'active',
    'Message de test du vendeur',
    'seller',
    NOW(),
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- 3. Insérer un message NON LU du vendeur vers le particulier
INSERT INTO messages (
    id,
    conversation_id,
    sender_id,
    sender_type,
    sender_name,
    content,
    message_type,
    is_read,     -- IMPORTANT: false pour tester les effets visuels
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM conversations WHERE user_id = '6e7ddfd6-3ab0-481b-bdae-d72d2d6c8cf0' LIMIT 1),
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- ID vendeur
    'seller',    -- IMPORTANT: sender_type='seller' pour message du vendeur
    'Edern Ferlicot',
    '🔴 MESSAGE TEST NON LU - Les effets visuels doivent apparaître !',
    'text',
    false,       -- IMPORTANT: is_read=false
    NOW(),
    NOW()
);

-- 4. Vérification - Afficher le message créé
SELECT 
    m.id,
    m.sender_type,
    m.is_read,
    m.content,
    c.user_id as particulier_id
FROM messages m
JOIN conversations c ON m.conversation_id = c.id
WHERE m.content LIKE '%MESSAGE TEST NON LU%'
ORDER BY m.created_at DESC
LIMIT 1;