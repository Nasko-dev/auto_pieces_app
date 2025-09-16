-- Créer le bucket pour les images de messages
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'message-images',
    'message-images',
    true, -- Public pour permettre l'accès aux images
    5242880, -- Limite de 5MB par fichier
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
)
ON CONFLICT (id) DO UPDATE
SET
    public = true,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[];

-- Supprimer les politiques existantes si elles existent
DROP POLICY IF EXISTS "Permettre upload images messages authentifiés" ON storage.objects;
DROP POLICY IF EXISTS "Permettre lecture publique images messages" ON storage.objects;
DROP POLICY IF EXISTS "Permettre suppression propres images messages" ON storage.objects;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated can upload" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own uploads" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own uploads" ON storage.objects;

-- Créer les politiques RLS pour le bucket
CREATE POLICY "message_images_upload_policy" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'message-images');

CREATE POLICY "message_images_read_policy" ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'message-images');

CREATE POLICY "message_images_delete_policy" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'message-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Afficher le résultat
SELECT * FROM storage.buckets WHERE id = 'message-images';