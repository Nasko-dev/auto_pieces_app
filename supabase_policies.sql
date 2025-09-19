-- 1. D'abord modifier la contrainte pour permettre le statut 'deleted'
ALTER TABLE part_requests
DROP CONSTRAINT IF EXISTS part_requests_status_check;

ALTER TABLE part_requests
ADD CONSTRAINT part_requests_status_check
CHECK (status = ANY(ARRAY['active'::text, 'closed'::text, 'fulfilled'::text, 'deleted'::text]));

-- 2. Supprimer toutes les policies existantes sur part_requests
DROP POLICY IF EXISTS "Enable read access for all users" ON part_requests;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON part_requests;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON part_requests;
DROP POLICY IF EXISTS "Users can soft delete their own part requests" ON part_requests;
DROP POLICY IF EXISTS "Enable soft delete for own requests" ON part_requests;

-- 3. Créer les policies avec les bons types UUID
-- Policy pour SELECT (lecture)
CREATE POLICY "Enable read access for all users"
ON part_requests
FOR SELECT
USING (status != 'deleted' OR status IS NULL);

-- Policy pour INSERT (création)
CREATE POLICY "Enable insert for authenticated users"
ON part_requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy pour UPDATE (modification et soft delete)
CREATE POLICY "Enable update for own requests"
ON part_requests
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Vérifier les policies créées
SELECT schemaname, tablename, policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'part_requests'
ORDER BY policyname;

-- 5. Test de la structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'part_requests'
  AND column_name IN ('id', 'user_id', 'status')
ORDER BY column_name;