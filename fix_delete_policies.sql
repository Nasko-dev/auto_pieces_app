-- Script pour corriger les politiques RLS et permettre la suppression des demandes

-- 1. Vérifier d'abord que la contrainte permet le statut 'deleted'
ALTER TABLE part_requests
DROP CONSTRAINT IF EXISTS part_requests_status_check;

ALTER TABLE part_requests
ADD CONSTRAINT part_requests_status_check
CHECK (status = ANY(ARRAY['active'::text, 'closed'::text, 'fulfilled'::text, 'deleted'::text]));

-- 2. Supprimer toutes les policies existantes sur part_requests
DROP POLICY IF EXISTS "Enable read access for all users" ON part_requests;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON part_requests;
DROP POLICY IF EXISTS "Enable update for own requests" ON part_requests;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON part_requests;
DROP POLICY IF EXISTS "Users can soft delete their own part requests" ON part_requests;
DROP POLICY IF EXISTS "Enable soft delete for own requests" ON part_requests;

-- 3. Créer les nouvelles policies

-- Policy pour SELECT (lecture) - exclure les demandes supprimées
CREATE POLICY "Enable read access for all users"
ON part_requests
FOR SELECT
USING (status != 'deleted' OR status IS NULL);

-- Policy pour INSERT (création)
CREATE POLICY "Enable insert for authenticated users"
ON part_requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy pour UPDATE plus permissive pour gérer device_id
-- Cette policy permet à un utilisateur de modifier une demande si:
-- 1. Il est le propriétaire direct (user_id match)
-- 2. OU il partage le même device_id via la table particuliers
CREATE POLICY "Enable update for own requests or same device"
ON part_requests
FOR UPDATE
USING (
  auth.uid() = user_id
  OR
  EXISTS (
    SELECT 1 FROM particuliers p1
    JOIN particuliers p2 ON p1.device_id = p2.device_id
    WHERE p1.id = auth.uid()
    AND p2.id = part_requests.user_id
  )
)
WITH CHECK (
  auth.uid() = user_id
  OR
  EXISTS (
    SELECT 1 FROM particuliers p1
    JOIN particuliers p2 ON p1.device_id = p2.device_id
    WHERE p1.id = auth.uid()
    AND p2.id = part_requests.user_id
  )
);

-- 4. Créer une fonction pour vérifier le device_id ownership (optionnel, plus efficace)
CREATE OR REPLACE FUNCTION has_same_device_id(auth_user_id uuid, request_user_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM particuliers p1
    JOIN particuliers p2 ON p1.device_id = p2.device_id
    WHERE p1.id = auth_user_id
    AND p2.id = request_user_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Alternative avec fonction (plus performante)
DROP POLICY IF EXISTS "Enable update for own requests or same device" ON part_requests;

CREATE POLICY "Enable update with device check"
ON part_requests
FOR UPDATE
USING (
  auth.uid() = user_id
  OR
  has_same_device_id(auth.uid(), user_id)
)
WITH CHECK (
  auth.uid() = user_id
  OR
  has_same_device_id(auth.uid(), user_id)
);

-- 6. Vérification des policies créées
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'part_requests'
ORDER BY policyname;

-- 7. Test de suppression (soft delete)
-- Pour tester, remplacer les UUID par des vraies valeurs
/*
-- Test 1: Vérifier qu'un utilisateur peut soft delete sa propre demande
UPDATE part_requests
SET status = 'deleted'
WHERE id = 'REQUEST_ID_TO_TEST'
AND user_id = auth.uid();

-- Test 2: Vérifier qu'un utilisateur avec le même device_id peut soft delete
UPDATE part_requests
SET status = 'deleted'
WHERE id = 'REQUEST_ID_TO_TEST'
AND has_same_device_id(auth.uid(), user_id);
*/

-- 8. Créer un index pour améliorer les performances de la fonction
CREATE INDEX IF NOT EXISTS idx_particuliers_device_id ON particuliers(device_id);
CREATE INDEX IF NOT EXISTS idx_part_requests_user_id ON part_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_part_requests_status ON part_requests(status);