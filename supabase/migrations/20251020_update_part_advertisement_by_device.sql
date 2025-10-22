-- Fonction pour mettre à jour une annonce en vérifiant le device_id du particulier
-- Permet de bypass RLS de manière sécurisée
CREATE OR REPLACE FUNCTION update_part_advertisement_by_device(
    p_ad_id UUID,
    p_device_id TEXT,
    p_updates JSONB
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    part_type TEXT,
    part_name TEXT,
    vehicle_plate TEXT,
    vehicle_brand TEXT,
    vehicle_model TEXT,
    vehicle_year INTEGER,
    vehicle_engine TEXT,
    description TEXT,
    price NUMERIC,
    condition TEXT,
    images TEXT[],
    status TEXT,
    is_negotiable BOOLEAN,
    contact_phone TEXT,
    contact_email TEXT,
    city TEXT,
    zip_code TEXT,
    department TEXT,
    view_count INTEGER,
    contact_count INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
)
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id UUID;
    v_particulier_device_id TEXT;
BEGIN
    -- Récupérer le user_id de l'annonce
    SELECT pa.user_id INTO v_user_id
    FROM part_advertisements pa
    WHERE pa.id = p_ad_id;

    -- Si l'annonce n'existe pas, retourner vide
    IF v_user_id IS NULL THEN
        RETURN;
    END IF;

    -- Vérifier que le device_id correspond au propriétaire de l'annonce
    SELECT p.device_id INTO v_particulier_device_id
    FROM particuliers p
    WHERE p.id = v_user_id;

    -- Si le device_id ne correspond pas, retourner vide
    IF v_particulier_device_id IS NULL OR v_particulier_device_id != p_device_id THEN
        RETURN;
    END IF;

    -- Mettre à jour l'annonce et retourner les données
    RETURN QUERY
    UPDATE part_advertisements
    SET
        part_name = COALESCE((p_updates->>'part_name')::TEXT, part_advertisements.part_name),
        vehicle_plate = CASE WHEN p_updates ? 'vehicle_plate' THEN (p_updates->>'vehicle_plate')::TEXT ELSE part_advertisements.vehicle_plate END,
        vehicle_brand = CASE WHEN p_updates ? 'vehicle_brand' THEN (p_updates->>'vehicle_brand')::TEXT ELSE part_advertisements.vehicle_brand END,
        vehicle_model = CASE WHEN p_updates ? 'vehicle_model' THEN (p_updates->>'vehicle_model')::TEXT ELSE part_advertisements.vehicle_model END,
        vehicle_year = CASE WHEN p_updates ? 'vehicle_year' THEN (p_updates->>'vehicle_year')::INTEGER ELSE part_advertisements.vehicle_year END,
        vehicle_engine = CASE WHEN p_updates ? 'vehicle_engine' THEN (p_updates->>'vehicle_engine')::TEXT ELSE part_advertisements.vehicle_engine END,
        description = CASE WHEN p_updates ? 'description' THEN (p_updates->>'description')::TEXT ELSE part_advertisements.description END,
        price = CASE WHEN p_updates ? 'price' THEN (p_updates->>'price')::NUMERIC ELSE part_advertisements.price END,
        condition = CASE WHEN p_updates ? 'condition' THEN (p_updates->>'condition')::TEXT ELSE part_advertisements.condition END,
        status = CASE WHEN p_updates ? 'status' THEN (p_updates->>'status')::TEXT ELSE part_advertisements.status END,
        updated_at = NOW()
    WHERE part_advertisements.id = p_ad_id
    RETURNING
        part_advertisements.id,
        part_advertisements.user_id,
        part_advertisements.part_type,
        part_advertisements.part_name,
        part_advertisements.vehicle_plate,
        part_advertisements.vehicle_brand,
        part_advertisements.vehicle_model,
        part_advertisements.vehicle_year,
        part_advertisements.vehicle_engine,
        part_advertisements.description,
        part_advertisements.price,
        part_advertisements.condition,
        part_advertisements.images,
        part_advertisements.status,
        part_advertisements.is_negotiable,
        part_advertisements.contact_phone,
        part_advertisements.contact_email,
        part_advertisements.city,
        part_advertisements.zip_code,
        part_advertisements.department,
        part_advertisements.view_count,
        part_advertisements.contact_count,
        part_advertisements.created_at,
        part_advertisements.updated_at,
        part_advertisements.expires_at;
END;
$$;

-- Donner les permissions d'exécution
GRANT EXECUTE ON FUNCTION update_part_advertisement_by_device(UUID, TEXT, JSONB) TO anon;
GRANT EXECUTE ON FUNCTION update_part_advertisement_by_device(UUID, TEXT, JSONB) TO authenticated;
