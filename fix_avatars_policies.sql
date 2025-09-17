-- Supprimer les anciennes politiques (si elles existent)
DROP POLICY IF EXISTS "Public Avatar Access" ON storage.objects;
DROP POLICY IF EXISTS "User Avatar Upload" ON storage.objects;
DROP POLICY IF EXISTS "User Avatar Update" ON storage.objects;
DROP POLICY IF EXISTS "User Avatar Delete" ON storage.objects;

-- Activer RLS sur storage.objects (si pas déjà fait)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre à tous de lire les avatars (public)
CREATE POLICY "Public Avatar Access" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Politique pour permettre aux utilisateurs authentifiés d'uploader des avatars
-- Cette politique permet l'upload si l'utilisateur est authentifié et que le fichier
-- est dans un dossier correspondant à son ID utilisateur
CREATE POLICY "Authenticated Avatar Upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Politique pour permettre aux utilisateurs de modifier leurs propres avatars
CREATE POLICY "Authenticated Avatar Update" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Politique pour permettre aux utilisateurs de supprimer leurs propres avatars
CREATE POLICY "Authenticated Avatar Delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Vérifier le bucket existe et est public
UPDATE storage.buckets
SET public = true
WHERE id = 'avatars';