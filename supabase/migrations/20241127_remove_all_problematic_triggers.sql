-- Lister et supprimer tous les triggers problématiques
DROP TRIGGER IF EXISTS on_message_insert ON messages;
DROP TRIGGER IF EXISTS handle_new_message ON messages;
DROP TRIGGER IF EXISTS update_last_active ON messages;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- DROP TRIGGER IF EXISTS on_public_users_created ON public.users;

-- Supprimer les fonctions qui pourraient référencer last_active
DROP FUNCTION IF EXISTS handle_new_message() CASCADE;
DROP FUNCTION IF EXISTS update_last_active() CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Créer une fonction simple pour les messages
CREATE OR REPLACE FUNCTION simple_message_handler()
RETURNS TRIGGER AS $$
BEGIN
  -- Juste mettre à jour la conversation sans référence à last_active
  UPDATE conversations
  SET
    total_messages = COALESCE(total_messages, 0) + 1,
    last_message_at = NOW(),
    updated_at = NOW()
  WHERE id = NEW.conversation_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger simple
CREATE TRIGGER simple_message_trigger
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION simple_message_handler();