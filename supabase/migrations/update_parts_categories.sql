-- Mise à jour de la contrainte de catégories pour inclure toutes les catégories nécessaires

-- Supprimer l'ancienne contrainte
ALTER TABLE public.parts DROP CONSTRAINT IF EXISTS parts_category_check;

-- Ajouter la nouvelle contrainte avec toutes les catégories
ALTER TABLE public.parts ADD CONSTRAINT parts_category_check
CHECK (category IN (
  'moteur',
  'interieur',
  'carrosserie',
  'transmission',
  'freinage',
  'direction',
  'suspension',
  'roues',
  'eclairage',
  'climatisation',
  'electronique',
  'accessoires',
  'echappement',
  'electricite',
  'vitrage',
  'carburant'
));
