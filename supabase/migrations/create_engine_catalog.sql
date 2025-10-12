-- Création table catalog moteur avec cylindrées, types de carburant et codes moteur

-- ========================================
-- TABLE ENGINE CATALOG
-- ========================================
CREATE TABLE IF NOT EXISTS public.engine_catalog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  cylindree TEXT NOT NULL,
  fuel_type TEXT NOT NULL,
  engine_code TEXT NOT NULL,
  power INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(cylindree, fuel_type, engine_code)
);

-- Index pour améliorer les performances de recherche
CREATE INDEX IF NOT EXISTS idx_engine_cylindree ON public.engine_catalog(cylindree);
CREATE INDEX IF NOT EXISTS idx_engine_fuel_type ON public.engine_catalog(fuel_type);
CREATE INDEX IF NOT EXISTS idx_engine_cylindree_fuel ON public.engine_catalog(cylindree, fuel_type);

-- ========================================
-- INSERTION DES DONNÉES MOTORISATIONS
-- ========================================
INSERT INTO public.engine_catalog (cylindree, fuel_type, engine_code, power) VALUES
-- Essence 1.0L
('1.0L', 'Essence', '1.0 SCe', 65),
('1.0L', 'Essence', '1.0 TCe', 90),
('1.0L', 'Essence', '1.0 TSI', 95),
('1.0L', 'Essence', '1.0 EcoBoost', 100),
('1.0L', 'Essence', '1.0 Turbo', 115),

-- Essence 1.2L
('1.2L', 'Essence', '1.2 SCe', 75),
('1.2L', 'Essence', '1.2 TCe', 100),
('1.2L', 'Essence', '1.2 PureTech', 110),
('1.2L', 'Essence', '1.2 TSI', 105),
('1.2L', 'Essence', '1.2 VTi', 82),

-- Essence 1.3L
('1.3L', 'Essence', '1.3 TCe', 130),
('1.3L', 'Essence', '1.3 TCe', 140),
('1.3L', 'Essence', '1.3 TCe', 150),

-- Essence 1.4L
('1.4L', 'Essence', '1.4 TSI', 122),
('1.4L', 'Essence', '1.4 TSI', 125),
('1.4L', 'Essence', '1.4 TSI', 140),
('1.4L', 'Essence', '1.4 TSI', 150),
('1.4L', 'Essence', '1.4 VVT-i', 90),
('1.4L', 'Essence', '1.4 16v', 95),

-- Essence 1.5L
('1.5L', 'Essence', '1.5 TSI', 130),
('1.5L', 'Essence', '1.5 TSI', 150),
('1.5L', 'Essence', '1.5 TFSI', 150),
('1.5L', 'Essence', '1.5 VVT-i', 110),
('1.5L', 'Essence', '1.5 16v', 105),

-- Essence 1.6L
('1.6L', 'Essence', '1.6 16v', 110),
('1.6L', 'Essence', '1.6 VTi', 120),
('1.6L', 'Essence', '1.6 THP', 150),
('1.6L', 'Essence', '1.6 THP', 156),
('1.6L', 'Essence', '1.6 THP', 165),
('1.6L', 'Essence', '1.6 TSI', 160),

-- Essence 1.8L
('1.8L', 'Essence', '1.8 TSI', 160),
('1.8L', 'Essence', '1.8 TSI', 180),
('1.8L', 'Essence', '1.8 TFSI', 190),
('1.8L', 'Essence', '1.8 VVT-i', 140),

-- Essence 2.0L
('2.0L', 'Essence', '2.0 TSI', 190),
('2.0L', 'Essence', '2.0 TSI', 200),
('2.0L', 'Essence', '2.0 TSI', 220),
('2.0L', 'Essence', '2.0 TFSI', 252),
('2.0L', 'Essence', '2.0 16v', 140),
('2.0L', 'Essence', '2.0 Turbo', 245),

-- Essence 2.5L
('2.5L', 'Essence', '2.5 VVT-i', 180),
('2.5L', 'Essence', '2.5 Turbo', 300),

-- Essence 3.0L
('3.0L', 'Essence', '3.0 TFSI', 340),
('3.0L', 'Essence', '3.0 V6', 272),
('3.0L', 'Essence', '3.0 Turbo', 360),

-- Diesel 1.3L
('1.3L', 'Diesel', '1.3 Multijet', 75),
('1.3L', 'Diesel', '1.3 CDTi', 95),

-- Diesel 1.4L
('1.4L', 'Diesel', '1.4 TDCi', 90),
('1.4L', 'Diesel', '1.4 HDi', 68),

-- Diesel 1.5L
('1.5L', 'Diesel', '1.5 dCi', 90),
('1.5L', 'Diesel', '1.5 dCi', 110),
('1.5L', 'Diesel', '1.5 BlueHDi', 100),
('1.5L', 'Diesel', '1.5 BlueHDi', 130),
('1.5L', 'Diesel', '1.5 TDI', 105),

-- Diesel 1.6L
('1.6L', 'Diesel', '1.6 HDi', 90),
('1.6L', 'Diesel', '1.6 HDi', 92),
('1.6L', 'Diesel', '1.6 BlueHDi', 100),
('1.6L', 'Diesel', '1.6 BlueHDi', 120),
('1.6L', 'Diesel', '1.6 TDI', 105),
('1.6L', 'Diesel', '1.6 TDI', 115),
('1.6L', 'Diesel', '1.6 TDCi', 95),

-- Diesel 2.0L
('2.0L', 'Diesel', '2.0 HDi', 136),
('2.0L', 'Diesel', '2.0 HDi', 140),
('2.0L', 'Diesel', '2.0 BlueHDi', 150),
('2.0L', 'Diesel', '2.0 BlueHDi', 180),
('2.0L', 'Diesel', '2.0 TDI', 136),
('2.0L', 'Diesel', '2.0 TDI', 140),
('2.0L', 'Diesel', '2.0 TDI', 150),
('2.0L', 'Diesel', '2.0 TDI', 190),
('2.0L', 'Diesel', '2.0 TDCi', 150),
('2.0L', 'Diesel', '2.0 TDCi', 170),
('2.0L', 'Diesel', '2.0 D-4D', 150),

-- Diesel 2.2L
('2.2L', 'Diesel', '2.2 HDi', 170),
('2.2L', 'Diesel', '2.2 TDCi', 155),
('2.2L', 'Diesel', '2.2 D-CAT', 177),

-- Diesel 3.0L
('3.0L', 'Diesel', '3.0 TDI', 204),
('3.0L', 'Diesel', '3.0 TDI', 218),
('3.0L', 'Diesel', '3.0 TDI', 272),
('3.0L', 'Diesel', '3.0 D', 265),

-- Hybride 1.5L
('1.5L', 'Hybride', '1.5 Hybrid', 140),
('1.5L', 'Hybride', '1.5 e-Tech', 140),

-- Hybride 1.6L
('1.6L', 'Hybride', '1.6 Hybrid', 141),

-- Hybride 1.8L
('1.8L', 'Hybride', '1.8 Hybrid', 122),
('1.8L', 'Hybride', '1.8 HSD', 136),

-- Hybride 2.0L
('2.0L', 'Hybride', '2.0 Hybrid', 184),
('2.0L', 'Hybride', '2.0 e-TFSI', 204),

-- Hybride 2.5L
('2.5L', 'Hybride', '2.5 Hybrid', 218),

-- Hybride rechargeable 1.4L
('1.4L', 'Hybride rechargeable', '1.4 TSI PHEV', 204),
('1.4L', 'Hybride rechargeable', '1.4 e-THP', 225),

-- Hybride rechargeable 1.6L
('1.6L', 'Hybride rechargeable', '1.6 THP PHEV', 225),
('1.6L', 'Hybride rechargeable', '1.6 e-HDi', 200),

-- Hybride rechargeable 2.0L
('2.0L', 'Hybride rechargeable', '2.0 TSI PHEV', 245),
('2.0L', 'Hybride rechargeable', '2.0 e-TFSI', 299),

-- Hybride rechargeable 3.0L
('3.0L', 'Hybride rechargeable', '3.0 TFSI e', 462),

-- Électrique
('Électrique', 'Électrique', 'Moteur électrique 50 kW', 68),
('Électrique', 'Électrique', 'Moteur électrique 80 kW', 109),
('Électrique', 'Électrique', 'Moteur électrique 100 kW', 136),
('Électrique', 'Électrique', 'Moteur électrique 110 kW', 150),
('Électrique', 'Électrique', 'Moteur électrique 150 kW', 204),
('Électrique', 'Électrique', 'Moteur électrique 160 kW', 218),
('Électrique', 'Électrique', 'Moteur électrique 170 kW', 231),
('Électrique', 'Électrique', 'Moteur électrique 200 kW', 272),
('Électrique', 'Électrique', 'Moteur électrique 250 kW', 340),
('Électrique', 'Électrique', 'Moteur électrique 300 kW', 408),

-- GPL
('1.4L', 'GPL', '1.4 GPL', 90),
('1.6L', 'GPL', '1.6 GPL', 110)

ON CONFLICT (cylindree, fuel_type, engine_code) DO NOTHING;

-- ========================================
-- FONCTIONS SQL POUR RÉCUPÉRER LES DONNÉES
-- ========================================

-- Fonction pour récupérer toutes les cylindrées uniques
CREATE OR REPLACE FUNCTION get_engine_cylinders()
RETURNS TABLE(cylindree TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ec.cylindree
  FROM public.engine_catalog ec
  ORDER BY
    CASE
      WHEN ec.cylindree = 'Électrique' THEN 999
      ELSE CAST(REPLACE(REPLACE(ec.cylindree, 'L', ''), ',', '.') AS DECIMAL)
    END;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour récupérer tous les types de carburant uniques
CREATE OR REPLACE FUNCTION get_fuel_types()
RETURNS TABLE(fuel_type TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ec.fuel_type
  FROM public.engine_catalog ec
  ORDER BY
    CASE ec.fuel_type
      WHEN 'Essence' THEN 1
      WHEN 'Diesel' THEN 2
      WHEN 'Hybride' THEN 3
      WHEN 'Hybride rechargeable' THEN 4
      WHEN 'Électrique' THEN 5
      WHEN 'GPL' THEN 6
      ELSE 99
    END;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour récupérer les codes moteur filtrés par cylindrée et carburant
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
$$ LANGUAGE plpgsql;

-- Activer RLS (Row Level Security) et autoriser lecture publique
ALTER TABLE public.engine_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Lecture publique engine_catalog"
  ON public.engine_catalog
  FOR SELECT
  TO public
  USING (true);
