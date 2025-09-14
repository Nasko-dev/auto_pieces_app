-- Insérer un message NON LU dans la conversation existante pour tester
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
    '63175f1f-a4dc-4101-911d-0ba540fd06d1',  -- Conversation ID existante
    'a525d360-6022-4016-927c-c6dc905f8af7',  -- Vendeur ID
    'seller',    -- IMPORTANT: sender_type='seller'
    'Vendeur Test',
    '🔴 MESSAGE TEST NON LU - Effets visuels attendus !',
    'text',
    false,       -- IMPORTANT: is_read=false
    NOW(),
    NOW()
);

-- Mettre à jour la conversation
UPDATE conversations 
SET 
    last_message_content = '🔴 MESSAGE TEST NON LU - Effets visuels attendus !',
    last_message_sender_type = 'seller',
    last_message_created_at = NOW(),
    updated_at = NOW()
WHERE id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';