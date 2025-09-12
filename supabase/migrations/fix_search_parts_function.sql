-- Script de correction pour la fonction search_parts
-- Erreur: type real vs numeric

-- 1. Supprimer la fonction existante
DROP FUNCTION IF EXISTS search_parts(text, text, integer);

-- 2. Recréer la fonction avec le bon type numeric
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