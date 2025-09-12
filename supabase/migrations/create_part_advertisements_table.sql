-- Table des annonces de pièces détachées par les particuliers
CREATE TABLE IF NOT EXISTS public.part_advertisements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Type de pièce recherchée (compatibilité avec le front-end existant)
  part_type text NOT NULL CHECK (part_type IN ('engine', 'body')),
  part_name text NOT NULL,
  
  -- Informations du véhicule (récupérées via API ou saisie manuelle)
  vehicle_plate text,
  vehicle_brand text,
  vehicle_model text,
  vehicle_year integer,
  vehicle_engine text,
  
  -- Informations spécifiques à l'annonce
  description text,
  price numeric(10,2), -- Prix en euros avec centimes
  condition text CHECK (condition IN ('neuf', 'bon', 'moyen', 'pour-pieces')),
  images text[] DEFAULT '{}', -- URLs des images
  
  -- Métadonnées
  status text DEFAULT 'active' CHECK (status IN ('active', 'sold', 'inactive')),
  is_negotiable boolean DEFAULT true,
  contact_phone text,
  contact_email text,
  
  -- Localisation (pour futures recherches géographiques)
  city text,
  zip_code text,
  department text,
  
  -- Compteurs
  view_count integer DEFAULT 0,
  contact_count integer DEFAULT 0,
  
  -- Timestamps
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '90 days') -- Expire après 3 mois
);

-- Index pour optimiser les recherches
CREATE INDEX idx_part_advertisements_user_id ON part_advertisements(user_id);
CREATE INDEX idx_part_advertisements_part_type ON part_advertisements(part_type);
CREATE INDEX idx_part_advertisements_part_name ON part_advertisements USING gin(to_tsvector('french', part_name));
CREATE INDEX idx_part_advertisements_status ON part_advertisements(status);
CREATE INDEX idx_part_advertisements_created_at ON part_advertisements(created_at DESC);
CREATE INDEX idx_part_advertisements_city ON part_advertisements(city);
CREATE INDEX idx_part_advertisements_price ON part_advertisements(price);
CREATE INDEX idx_part_advertisements_vehicle_brand ON part_advertisements(vehicle_brand);

-- Index composite pour recherches fréquentes
CREATE INDEX idx_part_advertisements_search ON part_advertisements(status, part_type, created_at DESC) 
WHERE status = 'active';

-- Trigger pour mettre à jour updated_at
CREATE TRIGGER update_part_advertisements_updated_at 
  BEFORE UPDATE ON part_advertisements 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour créer une annonce avec données véhicule
CREATE OR REPLACE FUNCTION create_part_advertisement(
  p_part_type text,
  p_part_name text,
  p_vehicle_plate text DEFAULT NULL,
  p_description text DEFAULT NULL,
  p_price numeric DEFAULT NULL,
  p_condition text DEFAULT NULL,
  p_images text[] DEFAULT '{}',
  p_contact_phone text DEFAULT NULL,
  p_contact_email text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
  ad_id uuid;
  vehicle_info record;
BEGIN
  -- Si une plaque est fournie, essayer de récupérer les infos véhicule
  -- (Cette partie sera utilisée quand on intégrera l'API d'immatriculation)
  
  -- Créer l'annonce
  INSERT INTO part_advertisements (
    user_id,
    part_type,
    part_name,
    vehicle_plate,
    description,
    price,
    condition,
    images,
    contact_phone,
    contact_email
  ) VALUES (
    auth.uid(),
    p_part_type,
    p_part_name,
    p_vehicle_plate,
    p_description,
    p_price,
    p_condition,
    p_images,
    p_contact_phone,
    p_contact_email
  ) RETURNING id INTO ad_id;
  
  RETURN ad_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour rechercher des annonces
CREATE OR REPLACE FUNCTION search_part_advertisements(
  search_query text DEFAULT NULL,
  filter_part_type text DEFAULT NULL,
  filter_city text DEFAULT NULL,
  min_price numeric DEFAULT NULL,
  max_price numeric DEFAULT NULL,
  limit_results integer DEFAULT 20,
  offset_results integer DEFAULT 0
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  part_type text,
  part_name text,
  vehicle_plate text,
  vehicle_brand text,
  vehicle_model text,
  vehicle_year integer,
  description text,
  price numeric,
  condition text,
  images text[],
  city text,
  view_count integer,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pa.id,
    pa.user_id,
    pa.part_type,
    pa.part_name,
    pa.vehicle_plate,
    pa.vehicle_brand,
    pa.vehicle_model,
    pa.vehicle_year,
    pa.description,
    pa.price,
    pa.condition,
    pa.images,
    pa.city,
    pa.view_count,
    pa.created_at
  FROM part_advertisements pa
  WHERE 
    pa.status = 'active'
    AND pa.expires_at > now()
    AND (search_query IS NULL OR pa.part_name ILIKE '%' || search_query || '%')
    AND (filter_part_type IS NULL OR pa.part_type = filter_part_type)
    AND (filter_city IS NULL OR pa.city ILIKE '%' || filter_city || '%')
    AND (min_price IS NULL OR pa.price >= min_price)
    AND (max_price IS NULL OR pa.price <= max_price)
  ORDER BY 
    pa.created_at DESC
  LIMIT limit_results
  OFFSET offset_results;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RLS (Row Level Security)
ALTER TABLE part_advertisements ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre la lecture de toutes les annonces actives
CREATE POLICY "Tout le monde peut lire les annonces actives" 
ON part_advertisements FOR SELECT 
USING (status = 'active' AND expires_at > now());

-- Politique pour permettre aux utilisateurs de gérer leurs propres annonces
CREATE POLICY "Les utilisateurs peuvent gérer leurs annonces" 
ON part_advertisements FOR ALL 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permissions pour les fonctions
GRANT EXECUTE ON FUNCTION create_part_advertisement(text, text, text, text, numeric, text, text[], text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION search_part_advertisements(text, text, text, numeric, numeric, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION search_part_advertisements(text, text, text, numeric, numeric, integer, integer) TO anon;