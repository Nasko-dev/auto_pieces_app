-- Migration: Ajout des pièces de carrosserie, intérieur et injection
-- Date: 2025-10-20
-- Description: Ajout pare-chocs, portes, sièges, banquette, injecteurs et joints

INSERT INTO public.parts (name, category, subcategory, synonyms, description, is_popular) VALUES

  -- ============================================
  -- CARROSSERIE
  -- ============================================

  ('Pare-choc avant', 'carrosserie', 'Bouclier',
   ARRAY['Par choc avant', 'Pare choc avant', 'Bouclier avant', 'Pare-chocs avant'],
   'Élément de protection avant du véhicule', true),

  ('Pare-choc arrière', 'carrosserie', 'Bouclier',
   ARRAY['Par choc arrière', 'Pare choc arriere', 'Bouclier arrière', 'Pare-chocs arrière'],
   'Élément de protection arrière du véhicule', true),

  ('Capot', 'carrosserie', 'Ouvrant',
   ARRAY['Capot moteur', 'Couvercle moteur'],
   'Capot avant recouvrant le compartiment moteur', true),

  ('Coffre', 'carrosserie', 'Ouvrant',
   ARRAY['Hayon', 'Couvercle coffre', 'Malle arrière'],
   'Couvercle du compartiment de rangement arrière', true),

  ('Porte avant gauche', 'carrosserie', 'Ouvrant',
   ARRAY['Porte AVG', 'Portière avant gauche'],
   'Porte conducteur ou passager avant gauche', true),

  ('Porte avant droite', 'carrosserie', 'Ouvrant',
   ARRAY['Porte AVD', 'Portière avant droite'],
   'Porte conducteur ou passager avant droite', true),

  ('Porte arrière gauche', 'carrosserie', 'Ouvrant',
   ARRAY['Porte arriere gauche', 'Porte ARG', 'Portière arrière gauche'],
   'Porte passager arrière gauche', true),

  ('Porte arrière droite', 'carrosserie', 'Ouvrant',
   ARRAY['Porte arriere droite', 'Porte ARD', 'Portière arrière droite'],
   'Porte passager arrière droite', true),

  ('Panneau de porte', 'carrosserie', 'Habillage',
   ARRAY['Garniture de porte', 'Panneau intérieur porte'],
   'Panneau intérieur de porte (toutes positions)', false),

  ('Panneau de porte avant', 'carrosserie', 'Habillage',
   ARRAY['Garniture porte avant', 'Panneau intérieur porte avant'],
   'Panneau intérieur de porte avant', false),

  ('Panneau de porte arrière', 'carrosserie', 'Habillage',
   ARRAY['Garniture porte arrière', 'Panneau intérieur porte arrière'],
   'Panneau intérieur de porte arrière', false),

  -- ============================================
  -- INTÉRIEUR
  -- ============================================

  ('Siège avant', 'interieur', 'Sièges',
   ARRAY['Chaise avant', 'Fauteuil avant', 'Siège conducteur', 'Siège passager'],
   'Siège avant conducteur ou passager', true),

  ('Siège arrière', 'interieur', 'Sièges',
   ARRAY['Chaise arrière', 'Fauteuil arrière'],
   'Siège arrière individuel', true),

  ('Banquette arrière', 'interieur', 'Sièges',
   ARRAY['Banquette arriere', 'Siège banquette', 'Banquette AR'],
   'Banquette arrière complète', true),

  ('Ceinture de sécurité', 'interieur', 'Sécurité',
   ARRAY['Ceinture', 'Harnais', 'Sangle de sécurité'],
   'Ceinture de sécurité (toutes positions)', true),

  -- ============================================
  -- MOTEUR - SYSTÈME D'INJECTION
  -- ============================================

  ('Injecteur', 'moteur', 'Injection',
   ARRAY['Injecteur de carburant', 'Injecteur essence', 'Injecteur diesel'],
   'Injecteur de carburant (unitaire)', true),

  ('Kit 2 injecteurs', 'moteur', 'Injection',
   ARRAY['2 injecteur', '2 injecteurs'],
   'Lot de 2 injecteurs', false),

  ('Kit 3 injecteurs', 'moteur', 'Injection',
   ARRAY['3 injecteur', '3 injecteurs'],
   'Lot de 3 injecteurs', false),

  ('Kit 4 injecteurs', 'moteur', 'Injection',
   ARRAY['4 injecteur', '4 injecteurs'],
   'Lot de 4 injecteurs', false),

  ('Injecteur cylindre 1', 'moteur', 'Injection',
   ARRAY['Injecteur 1', 'Injecteur C1'],
   'Injecteur du cylindre n°1', false),

  ('Injecteur cylindre 2', 'moteur', 'Injection',
   ARRAY['Injecteur 2', 'Injecteur C2'],
   'Injecteur du cylindre n°2', false),

  ('Injecteur cylindre 3', 'moteur', 'Injection',
   ARRAY['Injecteur 3', 'Injecteur C3'],
   'Injecteur du cylindre n°3', false),

  ('Injecteur cylindre 4', 'moteur', 'Injection',
   ARRAY['Injecteur 4', 'Injecteur C4'],
   'Injecteur du cylindre n°4', false),

  ('Joint d''injecteur', 'moteur', 'Joints',
   ARRAY['Join de injecteur', 'Joint injecteur', 'Rondelle injecteur', 'Joint étanchéité injecteur'],
   'Joint d''étanchéité pour injecteur', false)

ON CONFLICT (name) DO NOTHING;
