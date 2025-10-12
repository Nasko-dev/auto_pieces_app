-- Création de la table vehicle_catalog pour stocker les marques, modèles et années de véhicules
CREATE TABLE IF NOT EXISTS public.vehicle_catalog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  brand TEXT NOT NULL,
  model TEXT NOT NULL,
  year_start INTEGER NOT NULL,
  year_end INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

  -- Index pour améliorer les performances de recherche
  CONSTRAINT vehicle_catalog_brand_model_unique UNIQUE (brand, model, year_start, year_end)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_vehicle_catalog_brand ON public.vehicle_catalog(brand);
CREATE INDEX IF NOT EXISTS idx_vehicle_catalog_model ON public.vehicle_catalog(model);
CREATE INDEX IF NOT EXISTS idx_vehicle_catalog_brand_model ON public.vehicle_catalog(brand, model);

-- RLS (Row Level Security) - permettre la lecture à tous
ALTER TABLE public.vehicle_catalog ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON public.vehicle_catalog
  FOR SELECT
  TO public
  USING (true);

-- Insertion de données d'exemple pour les marques françaises populaires
INSERT INTO public.vehicle_catalog (brand, model, year_start, year_end) VALUES
  -- Renault
  ('Renault', 'Clio', 2012, 2024),
  ('Renault', 'Megane', 2016, 2024),
  ('Renault', 'Captur', 2013, 2024),
  ('Renault', 'Twingo', 2014, 2024),
  ('Renault', 'Kadjar', 2015, 2024),
  ('Renault', 'Scenic', 2016, 2024),
  ('Renault', 'Kangoo', 2013, 2024),
  ('Renault', 'Zoe', 2012, 2024),

  -- Peugeot
  ('Peugeot', '208', 2012, 2024),
  ('Peugeot', '308', 2013, 2024),
  ('Peugeot', '3008', 2016, 2024),
  ('Peugeot', '2008', 2013, 2024),
  ('Peugeot', '5008', 2017, 2024),
  ('Peugeot', '508', 2018, 2024),
  ('Peugeot', 'Partner', 2018, 2024),
  ('Peugeot', 'Rifter', 2018, 2024),

  -- Citroën
  ('Citroën', 'C3', 2016, 2024),
  ('Citroën', 'C4', 2020, 2024),
  ('Citroën', 'C5 Aircross', 2018, 2024),
  ('Citroën', 'Berlingo', 2018, 2024),
  ('Citroën', 'C3 Aircross', 2017, 2024),
  ('Citroën', 'C1', 2014, 2022),
  ('Citroën', 'SpaceTourer', 2016, 2024),

  -- Volkswagen
  ('Volkswagen', 'Golf', 2012, 2024),
  ('Volkswagen', 'Polo', 2017, 2024),
  ('Volkswagen', 'Tiguan', 2016, 2024),
  ('Volkswagen', 'T-Roc', 2017, 2024),
  ('Volkswagen', 'Passat', 2014, 2024),
  ('Volkswagen', 'ID.3', 2020, 2024),
  ('Volkswagen', 'T-Cross', 2018, 2024),

  -- BMW
  ('BMW', 'Serie 1', 2011, 2024),
  ('BMW', 'Serie 3', 2012, 2024),
  ('BMW', 'Serie 5', 2017, 2024),
  ('BMW', 'X1', 2015, 2024),
  ('BMW', 'X3', 2017, 2024),
  ('BMW', 'X5', 2013, 2024),

  -- Mercedes
  ('Mercedes', 'Classe A', 2018, 2024),
  ('Mercedes', 'Classe B', 2018, 2024),
  ('Mercedes', 'Classe C', 2014, 2024),
  ('Mercedes', 'Classe E', 2016, 2024),
  ('Mercedes', 'GLA', 2020, 2024),
  ('Mercedes', 'GLC', 2015, 2024),

  -- Audi
  ('Audi', 'A3', 2012, 2024),
  ('Audi', 'A4', 2015, 2024),
  ('Audi', 'A6', 2018, 2024),
  ('Audi', 'Q3', 2018, 2024),
  ('Audi', 'Q5', 2016, 2024),
  ('Audi', 'Q7', 2015, 2024),

  -- Toyota
  ('Toyota', 'Yaris', 2011, 2024),
  ('Toyota', 'Corolla', 2018, 2024),
  ('Toyota', 'C-HR', 2016, 2024),
  ('Toyota', 'RAV4', 2018, 2024),
  ('Toyota', 'Aygo', 2014, 2022),

  -- Ford
  ('Ford', 'Fiesta', 2013, 2023),
  ('Ford', 'Focus', 2014, 2024),
  ('Ford', 'Puma', 2019, 2024),
  ('Ford', 'Kuga', 2019, 2024),
  ('Ford', 'Mustang Mach-E', 2021, 2024),

  -- Opel
  ('Opel', 'Corsa', 2019, 2024),
  ('Opel', 'Astra', 2021, 2024),
  ('Opel', 'Crossland', 2017, 2024),
  ('Opel', 'Grandland', 2017, 2024),
  ('Opel', 'Mokka', 2020, 2024),

  -- Fiat
  ('Fiat', '500', 2015, 2024),
  ('Fiat', 'Panda', 2012, 2024),
  ('Fiat', 'Tipo', 2016, 2024),
  ('Fiat', '500X', 2014, 2024)
ON CONFLICT (brand, model, year_start, year_end) DO NOTHING;

-- Fonctions helper pour récupérer les données

-- Récupérer toutes les marques distinctes
CREATE OR REPLACE FUNCTION get_vehicle_brands()
RETURNS TABLE (brand TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT vehicle_catalog.brand
  FROM public.vehicle_catalog
  ORDER BY vehicle_catalog.brand ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Récupérer les modèles d'une marque
CREATE OR REPLACE FUNCTION get_vehicle_models(brand_name TEXT)
RETURNS TABLE (model TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT vehicle_catalog.model
  FROM public.vehicle_catalog
  WHERE vehicle_catalog.brand = brand_name
  ORDER BY vehicle_catalog.model ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Récupérer les années pour une marque et un modèle
CREATE OR REPLACE FUNCTION get_vehicle_years(brand_name TEXT, model_name TEXT)
RETURNS TABLE (year INTEGER) AS $$
BEGIN
  RETURN QUERY
  SELECT generate_series(
    MIN(vehicle_catalog.year_start),
    MAX(vehicle_catalog.year_end)
  ) AS year
  FROM public.vehicle_catalog
  WHERE vehicle_catalog.brand = brand_name
    AND vehicle_catalog.model = model_name
  ORDER BY year DESC;
END;
$$ LANGUAGE plpgsql STABLE;
