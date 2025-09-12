-- Table des pièces détachées avec catégorisation
CREATE TABLE IF NOT EXISTS public.parts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  category text NOT NULL CHECK (category IN ('moteur', 'interieur', 'carrosserie', 'transmission', 'freinage', 'direction', 'suspension', 'roues', 'eclairage', 'climatisation', 'electronique', 'accessoires')),
  subcategory text,
  synonyms text[] DEFAULT '{}',
  description text,
  is_popular boolean DEFAULT false,
  search_count integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index pour optimiser les recherches
CREATE INDEX idx_parts_name ON parts USING gin(to_tsvector('french', name));
CREATE INDEX idx_parts_category ON parts(category);
CREATE INDEX idx_parts_subcategory ON parts(subcategory);
CREATE INDEX idx_parts_is_active ON parts(is_active);
CREATE INDEX idx_parts_is_popular ON parts(is_popular);
CREATE INDEX idx_parts_search_count ON parts(search_count DESC);

-- Index pour recherche dans les synonymes
CREATE INDEX idx_parts_synonyms ON parts USING gin(synonyms);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_parts_updated_at 
  BEFORE UPDATE ON parts 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Fonction de recherche de pièces avec suggestions
CREATE OR REPLACE FUNCTION search_parts(
  search_query text,
  filter_category text DEFAULT NULL,
  limit_results integer DEFAULT 20
)
RETURNS TABLE (
  id uuid,
  name text,
  category text,
  subcategory text,
  synonyms text[],
  description text,
  is_popular boolean,
  search_count integer,
  relevance numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    p.category,
    p.subcategory,
    p.synonyms,
    p.description,
    p.is_popular,
    p.search_count,
    (
      CASE 
        WHEN p.name ILIKE search_query || '%' THEN 1.0
        WHEN p.name ILIKE '%' || search_query || '%' THEN 0.8
        WHEN EXISTS (SELECT 1 FROM unnest(p.synonyms) s WHERE s ILIKE '%' || search_query || '%') THEN 0.6
        ELSE 0.4
      END * 
      CASE 
        WHEN p.is_popular THEN 1.2
        ELSE 1.0
      END
    ) as relevance
  FROM parts p
  WHERE 
    p.is_active = true
    AND (filter_category IS NULL OR p.category = filter_category)
    AND (
      p.name ILIKE '%' || search_query || '%'
      OR EXISTS (SELECT 1 FROM unnest(p.synonyms) s WHERE s ILIKE '%' || search_query || '%')
      OR p.description ILIKE '%' || search_query || '%'
    )
  ORDER BY 
    relevance DESC,
    p.search_count DESC,
    p.name
  LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour incrémenter le compteur de recherche
CREATE OR REPLACE FUNCTION increment_search_count(part_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE parts 
  SET search_count = search_count + 1
  WHERE id = part_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour obtenir les pièces populaires par catégorie
CREATE OR REPLACE FUNCTION get_popular_parts_by_category(
  filter_category text,
  limit_results integer DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  name text,
  category text,
  subcategory text,
  search_count integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    p.category,
    p.subcategory,
    p.search_count
  FROM parts p
  WHERE 
    p.is_active = true
    AND p.category = filter_category
    AND (p.is_popular = true OR p.search_count > 10)
  ORDER BY 
    p.is_popular DESC,
    p.search_count DESC
  LIMIT limit_results;
END;
$$ LANGUAGE plpgsql;

-- RLS (Row Level Security)
ALTER TABLE parts ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre la lecture à tous
CREATE POLICY "Tout le monde peut lire les pièces actives" 
ON parts FOR SELECT 
USING (is_active = true);

-- Politique pour permettre l'insertion/modification aux admins seulement
CREATE POLICY "Seuls les admins peuvent modifier les pièces" 
ON parts FOR ALL 
USING (auth.jwt() ->> 'role' = 'admin')
WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Vue pour les statistiques
CREATE OR REPLACE VIEW parts_statistics AS
SELECT 
  category,
  COUNT(*) as total_parts,
  COUNT(*) FILTER (WHERE is_popular) as popular_parts,
  SUM(search_count) as total_searches,
  AVG(search_count) as avg_searches
FROM parts
WHERE is_active = true
GROUP BY category
ORDER BY total_searches DESC;