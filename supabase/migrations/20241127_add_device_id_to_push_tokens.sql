-- Ajouter device_id à la table push_tokens pour gérer les particuliers anonymes
ALTER TABLE public.push_tokens
ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Créer un index sur device_id pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_push_tokens_device_id ON public.push_tokens(device_id);

-- Commentaire pour expliquer l'usage
COMMENT ON COLUMN public.push_tokens.device_id IS 'Device ID pour les particuliers anonymes - permet de retrouver les Player IDs même quand le user_id change';