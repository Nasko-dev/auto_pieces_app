-- Ajouter la colonne avatar_url à la table particuliers
ALTER TABLE public.particuliers
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Optionnel : Ajouter un commentaire pour documenter la colonne
COMMENT ON COLUMN public.particuliers.avatar_url IS 'URL de l''avatar/photo de profil de l''utilisateur stockée dans Supabase Storage';

-- Vérifier que la colonne a été ajoutée
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'particuliers'
  AND table_schema = 'public'
  AND column_name = 'avatar_url';