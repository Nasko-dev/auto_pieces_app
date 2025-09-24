-- Désactiver temporairement les triggers problématiques sur messages
DROP TRIGGER IF EXISTS on_message_insert ON messages;

-- Recréer un trigger plus simple sans référence à last_active
CREATE OR REPLACE FUNCTION handle_new_message()
RETURNS TRIGGER AS $$
BEGIN
  -- Mettre à jour les compteurs de messages non lus selon le sender_type
  IF NEW.sender_type = 'user' THEN
    -- Si c'est un utilisateur qui envoie, incrémenter le compteur pour le vendeur
    UPDATE conversations
    SET
      unread_count_for_seller = unread_count_for_seller + 1,
      total_messages = total_messages + 1,
      last_message_at = NOW(),
      updated_at = NOW()
    WHERE id = NEW.conversation_id;
  ELSE
    -- Si c'est un vendeur qui envoie, incrémenter le compteur pour l'utilisateur
    UPDATE conversations
    SET
      unread_count_for_user = unread_count_for_user + 1,
      total_messages = total_messages + 1,
      last_message_at = NOW(),
      updated_at = NOW()
    WHERE id = NEW.conversation_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recréer le trigger
CREATE TRIGGER on_message_insert
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_message();