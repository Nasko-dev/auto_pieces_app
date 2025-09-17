-- Fix pour les policies RLS avec les fonctions RPC

-- Option 1: Désactiver temporairement RLS pour la table parts (solution rapide)
-- ALTER TABLE parts DISABLE ROW LEVEL SECURITY;

-- Option 2: Modifier la function pour être SECURITY DEFINER (solution propre)
DROP FUNCTION IF EXISTS search_parts(text, text, integer);

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
) 
SECURITY DEFINER -- Cette ligne permet à la fonction d'ignorer RLS
SET search_path = public
AS $$
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
    )::numeric as relevance
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

-- Donner les permissions d'exécution à tous les utilisateurs authentifiés
GRANT EXECUTE ON FUNCTION search_parts(text, text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION search_parts(text, text, integer) TO anon;