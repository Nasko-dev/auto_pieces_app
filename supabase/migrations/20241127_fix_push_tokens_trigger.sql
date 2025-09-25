-- Supprimer le trigger automatique sur push_tokens qui cause le problème
DROP TRIGGER IF EXISTS update_push_tokens_updated_at ON push_tokens;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- Créer une fonction plus simple qui ne référence que les champs existants
CREATE OR REPLACE FUNCTION simple_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Recréer le trigger de manière simple
CREATE TRIGGER update_push_tokens_timestamp
  BEFORE UPDATE ON push_tokens
  FOR EACH ROW
  EXECUTE FUNCTION simple_update_timestamp();