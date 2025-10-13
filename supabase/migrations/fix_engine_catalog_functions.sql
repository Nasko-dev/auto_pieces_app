-- Correction des fonctions RPC du catalogue moteur
-- Correction de l'erreur "ORDER BY expressions must appear in select list"

-- Fonction corrigée pour récupérer toutes les cylindrées uniques
CREATE OR REPLACE FUNCTION get_engine_cylinders()
RETURNS TABLE(cylindree TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ec.cylindree
  FROM public.engine_catalog ec
  ORDER BY ec.cylindree;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction corrigée pour récupérer tous les types de carburant uniques
CREATE OR REPLACE FUNCTION get_fuel_types()
RETURNS TABLE(fuel_type TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ec.fuel_type
  FROM public.engine_catalog ec
  ORDER BY ec.fuel_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- La fonction get_engine_models est OK, on la recrée juste avec SECURITY DEFINER
CREATE OR REPLACE FUNCTION get_engine_models(
  p_cylindree TEXT DEFAULT NULL,
  p_fuel_type TEXT DEFAULT NULL
)
RETURNS TABLE(
  engine_code TEXT,
  power INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT ec.engine_code, ec.power
  FROM public.engine_catalog ec
  WHERE
    (p_cylindree IS NULL OR ec.cylindree = p_cylindree)
    AND (p_fuel_type IS NULL OR ec.fuel_type = p_fuel_type)
  ORDER BY ec.power ASC NULLS LAST, ec.engine_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Donner les permissions d'exécution aux fonctions RPC
GRANT EXECUTE ON FUNCTION public.get_engine_cylinders() TO anon;
GRANT EXECUTE ON FUNCTION public.get_engine_cylinders() TO authenticated;

GRANT EXECUTE ON FUNCTION public.get_fuel_types() TO anon;
GRANT EXECUTE ON FUNCTION public.get_fuel_types() TO authenticated;

GRANT EXECUTE ON FUNCTION public.get_engine_models(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_engine_models(TEXT, TEXT) TO authenticated;

-- Vérifier que la table engine_catalog a bien les bonnes permissions
GRANT SELECT ON public.engine_catalog TO anon;
GRANT SELECT ON public.engine_catalog TO authenticated;
