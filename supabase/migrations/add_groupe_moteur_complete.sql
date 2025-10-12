-- Ajout complet groupe moteur

-- ========================================
-- GROUPE MOTEUR
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Bloc moteur et culasse
('Bloc moteur', 'moteur', 'bloc', ARRAY['carter cylindres', 'engine block'], true),
('Culasse', 'moteur', 'culasse', ARRAY['tête de cylindre', 'cylinder head'], true),
('Joint de culasse', 'moteur', 'joint', ARRAY['joint tête'], true),
('Carter inférieur', 'moteur', 'carter', ARRAY['carter d''huile', 'oil pan'], true),
('Joint de carter d''huile', 'moteur', 'joint', ARRAY['joint carter inférieur'], true),
('Carter de distribution', 'moteur', 'carter', ARRAY['cache distribution'], false),
('Joint de carter de distribution', 'moteur', 'joint', ARRAY['joint cache distri'], false),
('Couvercle de culasse', 'moteur', 'culasse', ARRAY['cache culbuteurs'], true),
('Joint de couvercle de culasse', 'moteur', 'joint', ARRAY['joint cache culbuteurs'], true),

-- Distribution
('Courroie de distribution', 'moteur', 'distribution', ARRAY['timing belt'], true),
('Kit de distribution', 'moteur', 'kit', ARRAY['kit courroie distri'], true),
('Chaîne de distribution', 'moteur', 'distribution', ARRAY['timing chain'], true),
('Kit chaîne de distribution', 'moteur', 'kit', ARRAY['kit chaîne distri'], true),
('Tendeur de courroie de distribution', 'moteur', 'distribution', ARRAY['tendeur distri'], true),
('Galet tendeur de distribution', 'moteur', 'distribution', ARRAY['poulie tendeur'], true),
('Galet enrouleur de distribution', 'moteur', 'distribution', ARRAY['galet renvoi'], false),
('Pignon de vilebrequin', 'moteur', 'distribution', ARRAY['poulie vilo'], false),
('Pignon d''arbre à cames', 'moteur', 'distribution', ARRAY['poulie AAC'], false),
('Guide de chaîne de distribution', 'moteur', 'distribution', ARRAY['rail chaîne'], false),
('Tendeur hydraulique de chaîne', 'moteur', 'distribution', ARRAY['tendeur chaîne'], true),
('Variateur de calage', 'moteur', 'distribution', ARRAY['VVT', 'déphaseur'], true),
('Électrovanne de variateur', 'moteur', 'distribution', ARRAY['solénoïde VVT'], false),

-- Arbre à cames et soupapes
('Arbre à cames admission', 'moteur', 'culasse', ARRAY['AAC admission'], false),
('Arbre à cames échappement', 'moteur', 'culasse', ARRAY['AAC échappement'], false),
('Soupape d''admission', 'moteur', 'soupape', ARRAY['valve admission'], false),
('Soupape d''échappement', 'moteur', 'soupape', ARRAY['valve échappement'], false),
('Jeu de soupapes', 'moteur', 'kit', ARRAY['kit soupapes'], false),
('Guide de soupape', 'moteur', 'soupape', ARRAY['guide valve'], false),
('Joint de queue de soupape', 'moteur', 'joint', ARRAY['joint de tige'], false),
('Ressort de soupape', 'moteur', 'soupape', ARRAY['spring valve'], false),
('Coupelle de soupape', 'moteur', 'soupape', ARRAY['coupelle valve'], false),
('Poussoir hydraulique', 'moteur', 'culasse', ARRAY['poussoir HVA'], true),
('Culbuteur', 'moteur', 'culasse', ARRAY['rocker arm'], false),
('Axe de culbuteur', 'moteur', 'culasse', ARRAY['arbre culbuteurs'], false),

-- Pistons et bielles
('Piston', 'moteur', 'piston', ARRAY['piston moteur'], false),
('Jeu de pistons', 'moteur', 'kit', ARRAY['kit pistons'], false),
('Segments de piston', 'moteur', 'piston', ARRAY['rings'], true),
('Axe de piston', 'moteur', 'piston', ARRAY['goupille piston'], false),
('Bielle', 'moteur', 'bielle', ARRAY['connecting rod'], false),
('Jeu de bielles', 'moteur', 'kit', ARRAY['kit bielles'], false),
('Coussinet de bielle', 'moteur', 'bielle', ARRAY['bearing bielle'], true),
('Vis de bielle', 'moteur', 'bielle', ARRAY['boulon chapeau bielle'], false),

-- Vilebrequin et volant
('Vilebrequin', 'moteur', 'vilebrequin', ARRAY['crankshaft', 'vilo'], true),
('Coussinet de vilebrequin', 'moteur', 'vilebrequin', ARRAY['bearing vilo', 'paliers'], true),
('Butée de vilebrequin', 'moteur', 'vilebrequin', ARRAY['crapaudine'], false),
('Poulie de vilebrequin', 'moteur', 'vilebrequin', ARRAY['poulie damper'], true),
('Volant moteur', 'moteur', 'volant', ARRAY['flywheel'], true),
('Couronne de démarreur', 'moteur', 'volant', ARRAY['couronne dentée'], false),

-- Joints et pochettes
('Joint spi avant de vilebrequin', 'moteur', 'joint', ARRAY['spi AV vilo'], true),
('Joint spi arrière de vilebrequin', 'moteur', 'joint', ARRAY['spi AR vilo'], true),
('Joint d''arbre à cames', 'moteur', 'joint', ARRAY['spi AAC'], false),
('Pochette de joints moteur complète', 'moteur', 'kit', ARRAY['kit joints moteur'], true),
('Pochette de joints bas moteur', 'moteur', 'kit', ARRAY['kit joints bloc'], false),
('Pochette de joints haut moteur', 'moteur', 'kit', ARRAY['kit joints culasse'], false),

-- Carter et circuit d'huile
('Pompe à huile', 'moteur', 'lubrification', ARRAY['oil pump'], true),
('Crépine de pompe à huile', 'moteur', 'lubrification', ARRAY['tamis pompe huile'], false),
('Filtre à huile', 'moteur', 'filtre', ARRAY['oil filter'], true),
('Support de filtre à huile', 'moteur', 'filtre', ARRAY['corps filtre huile'], false),
('Refroidisseur d''huile moteur', 'moteur', 'lubrification', ARRAY['échangeur huile'], true),
('Joint de refroidisseur d''huile', 'moteur', 'joint', ARRAY['joint échangeur'], false),
('Bouchon de carter d''huile', 'moteur', 'carter', ARRAY['vis de vidange'], true),
('Joint de bouchon de vidange', 'moteur', 'joint', ARRAY['joint crush'], true),
('Jauge d''huile moteur', 'moteur', 'lubrification', ARRAY['dipstick'], false),
('Tube de jauge d''huile', 'moteur', 'lubrification', ARRAY['guide jauge'], false),
('Bouchon de remplissage d''huile', 'moteur', 'carter', ARRAY['bouchon huile'], false),
('Capteur de pression d''huile', 'moteur', 'capteur', ARRAY['mano huile'], true),
('Capteur de niveau d''huile', 'moteur', 'capteur', ARRAY['sonde niveau huile'], false),
('Capteur de température d''huile', 'moteur', 'capteur', ARRAY['sonde température huile'], false),
('Clapet de décharge d''huile', 'moteur', 'lubrification', ARRAY['by-pass huile'], false),

-- Palier et supports
('Palier de moteur', 'moteur', 'bloc', ARRAY['bearing bloc'], false),
('Support de poulie auxiliaire', 'moteur', 'support', ARRAY['support tendeur accessoires'], false),

-- Équilibrage
('Arbre d''équilibrage', 'moteur', 'equilibrage', ARRAY['balancer shaft'], false),
('Chaîne d''arbre d''équilibrage', 'moteur', 'equilibrage', ARRAY['chaîne balancer'], false),

-- Collecteurs
('Collecteur d''admission', 'moteur', 'admission', ARRAY['intake manifold'], true),
('Collecteur d''échappement', 'moteur', 'echappement', ARRAY['exhaust manifold'], true),
('Joint de collecteur d''admission', 'moteur', 'joint', ARRAY['joint admission'], true),
('Joint de collecteur d''échappement', 'moteur', 'joint', ARRAY['joint échappement'], true),

-- Carter de reniflard
('Reniflard de carter', 'moteur', 'reniflard', ARRAY['PCV', 'separator'], true),
('Valve de reniflard', 'moteur', 'reniflard', ARRAY['valve PCV'], false),
('Durite de reniflard', 'moteur', 'reniflard', ARRAY['tuyau vapeur huile'], false),
('Décanteur d''huile', 'moteur', 'reniflard', ARRAY['separator huile'], false),

-- Bouchons et vis
('Bouchons de culasse', 'moteur', 'culasse', ARRAY['bouchons galeries'], false),
('Vis de culasse', 'moteur', 'culasse', ARRAY['boulons culasse'], true),
('Rondelles de vis de culasse', 'moteur', 'culasse', ARRAY['washers culasse'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Bloc moteur',
  'Culasse',
  'Joint de culasse',
  'Courroie de distribution',
  'Kit de distribution',
  'Chaîne de distribution',
  'Tendeur de courroie de distribution',
  'Galet tendeur de distribution',
  'Variateur de calage',
  'Segments de piston',
  'Vilebrequin',
  'Coussinet de vilebrequin',
  'Pompe à huile',
  'Filtre à huile',
  'Joint spi avant de vilebrequin',
  'Pochette de joints moteur complète',
  'Collecteur d''admission',
  'Collecteur d''échappement'
);
