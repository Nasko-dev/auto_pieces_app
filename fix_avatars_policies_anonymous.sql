-- Supprimer les anciennes politiques (si elles existent)
DROP POLICY IF EXISTS "Public Avatar Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Avatar Upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Avatar Update" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Avatar Delete" ON storage.objects;

-- Activer RLS sur storage.objects (si pas déjà fait)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre à tous de lire les avatars (public)
CREATE POLICY "Public Avatar Access" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Politique pour permettre l'upload d'avatars (plus permissive pour les utilisateurs anonymes)
-- Permet l'upload si le bucket est 'avatars' et si le chemin respecte le format userId/filename
CREATE POLICY "Avatar Upload Policy" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars'
  );

-- Politique pour permettre la modification des avatars
CREATE POLICY "Avatar Update Policy" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars'
  );

-- Politique pour permettre la suppression des avatars
CREATE POLICY "Avatar Delete Policy" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars'
  );

-- S'assurer que le bucket existe et est public
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,  -- Public pour que les images soient accessibles
  5242880,  -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];