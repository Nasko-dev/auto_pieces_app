-- ✅ SQL pour tester l'envoi d'un message du PARTICULIER vers le VENDEUR
-- Ceci devrait déclencher le widget visuel côté VENDEUR

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
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',
    'eb9c6d37-7f20-47b4-bcfd-b1f88c92e1e0',  -- ID du particulier
    'user',                                    -- ⭐ IMPORTANT: sender_type = 'user' pour particulier
    'Jean Particulier',
    '💬 NOUVEAU MESSAGE PARTICULIER NON LU - Test Widget Vendeur!',
    'text',
    false,
    NOW(),
    NOW()
);

-- Note: Ce message devrait être détecté par le vendeur via _handleGlobalNewMessage()
-- et incrémenter son compteur local pour cette conversation
