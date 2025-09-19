-- Script corrigé pour permettre la suppression avec device_id
-- Ce script règle le problème où un utilisateur ne peut pas supprimer ses propres demandes
-- créées avec un user_id différent mais le même device_id

-- 1. D'abord, s'assurer que la contrainte permet le statut 'deleted'
ALTER TABLE part_requests
DROP CONSTRAINT IF EXISTS part_requests_status_check;

ALTER TABLE part_requests
ADD CONSTRAINT part_requests_status_check
CHECK (status = ANY(ARRAY['active'::text, 'closed'::text, 'fulfilled'::text, 'deleted'::text]));

-- 2. Supprimer TOUTES les anciennes policies
DROP POLICY IF EXISTS "Enable read access for all users" ON part_requests;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON part_requests;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON part_requests;
DROP POLICY IF EXISTS "Enable update for own requests" ON part_requests;
DROP POLICY IF EXISTS "Enable update with device check" ON part_requests;
DROP POLICY IF EXISTS "Enable update for own requests or same device" ON part_requests;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON part_requests;
DROP POLICY IF EXISTS "Users can soft delete their own part requests" ON part_requests;
DROP POLICY IF EXISTS "Enable soft delete for own requests" ON part_requests;

-- 3. Créer une fonction helper pour vérifier le device_id
CREATE OR REPLACE FUNCTION check_device_ownership(auth_user_id uuid, request_user_id uuid)
RETURNS boolean AS $$
DECLARE
    auth_device_id text;
    request_device_id text;
BEGIN
    -- Récupérer le device_id de l'utilisateur authentifié
    SELECT device_id INTO auth_device_id
    FROM particuliers
    WHERE id = auth_user_id
    LIMIT 1;

    -- Récupérer le device_id du propriétaire de la demande
    SELECT device_id INTO request_device_id
    FROM particuliers
    WHERE id = request_user_id
    LIMIT 1;

    -- Vérifier si les device_id correspondent
    IF auth_device_id IS NOT NULL AND request_device_id IS NOT NULL THEN
        RETURN auth_device_id = request_device_id;
    END IF;

    -- Si l'un des device_id n'est pas trouvé, vérifier l'égalité directe des user_id
    RETURN auth_user_id = request_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Créer les nouvelles policies

-- Policy pour SELECT (lecture) - exclure les demandes supprimées
CREATE POLICY "Read non-deleted requests"
ON part_requests
FOR SELECT
USING (status != 'deleted' OR status IS NULL);

-- Policy pour INSERT - permettre création pour utilisateurs authentifiés
CREATE POLICY "Insert for authenticated users"
ON part_requests
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- Policy pour UPDATE - PLUS PERMISSIVE pour gérer le device_id
-- Cette policy est LA CLÉ pour résoudre le problème
CREATE POLICY "Update own requests or same device"
ON part_requests
FOR UPDATE
USING (
    -- Permettre si c'est le même user_id
    auth.uid() = user_id
    OR
    -- OU si les deux utilisateurs partagent le même device_id
    check_device_ownership(auth.uid(), user_id)
)
WITH CHECK (
    -- Mêmes conditions pour le WITH CHECK
    auth.uid() = user_id
    OR
    check_device_ownership(auth.uid(), user_id)
);

-- 5. Créer des index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_particuliers_device_id ON particuliers(device_id);
CREATE INDEX IF NOT EXISTS idx_particuliers_id ON particuliers(id);
CREATE INDEX IF NOT EXISTS idx_part_requests_user_id ON part_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_part_requests_status ON part_requests(status);

-- 6. Vérifier les policies créées
SELECT
    schemaname,
    tablename,
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'part_requests'
ORDER BY policyname;

-- 7. Test de vérification avec vos IDs réels
-- Remplacez ces valeurs par les vraies pour tester
DO $$
DECLARE
    test_auth_id uuid := '8ff4ddc5-1ffc-49c1-980f-7df39e2e639c'::uuid;
    test_request_user_id uuid := 'dfcc814d-85ba-46df-ab2f-bb4a2c00c95e'::uuid;
    test_result boolean;
BEGIN
    -- Tester la fonction
    test_result := check_device_ownership(test_auth_id, test_request_user_id);

    RAISE NOTICE 'Test device ownership: auth_id=%, request_user_id=%, result=%',
        test_auth_id, test_request_user_id, test_result;

    -- Afficher les device_ids pour debug
    RAISE NOTICE 'Auth user device_id: %',
        (SELECT device_id FROM particuliers WHERE id = test_auth_id);
    RAISE NOTICE 'Request user device_id: %',
        (SELECT device_id FROM particuliers WHERE id = test_request_user_id);
END $$;

-- 8. ALTERNATIVE: Policy encore plus permissive (à utiliser en dernier recours)
-- Si la solution ci-dessus ne fonctionne pas, décommentez ceci :
/*
DROP POLICY IF EXISTS "Update own requests or same device" ON part_requests;

CREATE POLICY "Update with flexible device check"
ON part_requests
FOR UPDATE
USING (
    true  -- Permet la lecture pour vérifier
)
WITH CHECK (
    -- Vérifier que l'utilisateur a le droit via device_id
    EXISTS (
        SELECT 1
        FROM particuliers p1
        WHERE p1.id = auth.uid()
        AND p1.device_id IN (
            SELECT device_id
            FROM particuliers
            WHERE id = user_id
        )
    )
    OR
    auth.uid() = user_id
);
*/

-- 9. Grant des permissions nécessaires sur la fonction
GRANT EXECUTE ON FUNCTION check_device_ownership TO authenticated;
GRANT EXECUTE ON FUNCTION check_device_ownership TO anon;