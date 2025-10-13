-- Ajout complet direction

-- ========================================
-- DIRECTION
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Crémaillère et direction assistée
('Crémaillère de direction', 'direction', 'cremaillere', ARRAY['rack de direction', 'boîtier direction'], true),
('Crémaillère de direction assistée', 'direction', 'cremaillere', ARRAY['rack assistée', 'DAE'], true),
('Boîtier de direction', 'direction', 'boitier', ARRAY['boîtier vis-écrou'], false),
('Pompe de direction assistée', 'direction', 'hydraulique', ARRAY['pompe DAH'], true),
('Réservoir de liquide de direction assistée', 'direction', 'hydraulique', ARRAY['bocal DAH'], true),
('Capteur de direction assistée électrique', 'direction', 'electronique', ARRAY['capteur DAE'], false),
('Calculateur de direction assistée électrique', 'direction', 'electronique', ARRAY['ECU DAE', 'module EPS'], false),
('Moteur de direction assistée électrique', 'direction', 'electronique', ARRAY['moteur DAE', 'EPS motor'], true),
('Kit de réparation crémaillère', 'direction', 'kit', ARRAY['kit joints crémaillère'], false),
('Soufflet de crémaillère gauche', 'direction', 'soufflet', ARRAY['soufflet rack G'], true),
('Soufflet de crémaillère droit', 'direction', 'soufflet', ARRAY['soufflet rack D'], true),
('Kit soufflets de crémaillère', 'direction', 'kit', ARRAY['kit soufflets direction'], true),

-- Timonerie et biellettes
('Rotule de direction gauche', 'direction', 'rotule', ARRAY['rotule axiale G'], true),
('Rotule de direction droite', 'direction', 'rotule', ARRAY['rotule axiale D'], true),
('Biellette de direction gauche', 'direction', 'biellette', ARRAY['bielle direction G', 'tie rod G'], true),
('Biellette de direction droite', 'direction', 'biellette', ARRAY['bielle direction D', 'tie rod D'], true),
('Rotule de biellette de direction gauche', 'direction', 'rotule', ARRAY['embout biellette G'], true),
('Rotule de biellette de direction droite', 'direction', 'rotule', ARRAY['embout biellette D'], true),
('Barre de direction', 'direction', 'barre', ARRAY['barre d''accouplement'], false),
('Kit timonerie de direction complet', 'direction', 'kit', ARRAY['kit rotules direction'], true),
('Rotule intérieure de direction gauche', 'direction', 'rotule', ARRAY['rotule interne G'], false),
('Rotule intérieure de direction droite', 'direction', 'rotule', ARRAY['rotule interne D'], false),
('Rotule extérieure de direction gauche', 'direction', 'rotule', ARRAY['rotule externe G'], false),
('Rotule extérieure de direction droite', 'direction', 'rotule', ARRAY['rotule externe D'], false),

-- Colonne de direction
('Colonne de direction', 'direction', 'colonne', ARRAY['arbre de direction'], true),
('Colonne de direction réglable', 'direction', 'colonne', ARRAY['colonne ajustable'], false),
('Cardan de colonne de direction', 'direction', 'colonne', ARRAY['joint cardan direction'], true),
('Palier de colonne de direction', 'direction', 'colonne', ARRAY['roulement colonne'], false),
('Manchon de colonne de direction', 'direction', 'colonne', ARRAY['coulissant direction'], false),
('Contacteur tournant', 'direction', 'electronique', ARRAY['contacteur sous-volant', 'ressort spiral'], true),
('Antivol de colonne de direction', 'direction', 'securite', ARRAY['neiman', 'verrou colonne'], true),
('Support de colonne de direction', 'direction', 'fixation', ARRAY['fixation colonne'], false),

-- Volant et commandes
('Volant', 'direction', 'volant', ARRAY['steering wheel'], true),
('Volant sport', 'direction', 'volant', ARRAY['volant cuir'], false),
('Volant multifonction', 'direction', 'volant', ARRAY['volant avec commandes'], true),
('Volant chauffant', 'direction', 'volant', ARRAY['volant avec chauffage'], false),
('Airbag conducteur', 'direction', 'securite', ARRAY['coussin gonflable volant'], true),
('Moyeu de volant', 'direction', 'fixation', ARRAY['hub volant'], false),
('Écrou de volant', 'direction', 'fixation', ARRAY['vis volant'], false),
('Commodo d''essuie-glace', 'direction', 'commande', ARRAY['comodo essuie-glace'], true),
('Commodo de clignotants', 'direction', 'commande', ARRAY['comodo clignotant'], true),
('Commodo multifonction gauche', 'direction', 'commande', ARRAY['manette gauche'], true),
('Commodo multifonction droit', 'direction', 'commande', ARRAY['manette droite'], false),
('Commande au volant gauche', 'direction', 'commande', ARRAY['boutons volant G'], false),
('Commande au volant droite', 'direction', 'commande', ARRAY['boutons volant D'], false),
('Module de commande régulateur', 'direction', 'commande', ARRAY['commande cruise control'], false),

-- Durites et circuits hydrauliques
('Durite haute pression de direction assistée', 'direction', 'hydraulique', ARRAY['durite HP DAH'], true),
('Durite basse pression de direction assistée', 'direction', 'hydraulique', ARRAY['durite BP DAH', 'durite retour'], true),
('Flexible de direction assistée', 'direction', 'hydraulique', ARRAY['flexible DAH'], false),
('Refroidisseur de direction assistée', 'direction', 'hydraulique', ARRAY['radiateur DAH'], false),

-- Direction assistée variable et active
('Calculateur de direction variable', 'direction', 'electronique', ARRAY['ECU direction variable'], false),
('Actuateur de direction active', 'direction', 'electronique', ARRAY['servo direction active'], false),
('Capteur d''angle de volant', 'direction', 'capteur', ARRAY['capteur position volant', 'SAS'], true),
('Capteur de couple de direction', 'direction', 'capteur', ARRAY['torque sensor'], false),
('Relais de direction assistée électrique', 'direction', 'electronique', ARRAY['relais DAE'], false),

-- Joints et fixations
('Joint de crémaillère', 'direction', 'joint', ARRAY['joint rack'], false),
('Rondelle de crémaillère', 'direction', 'fixation', ARRAY['clip crémaillère'], false),
('Circlips de direction', 'direction', 'fixation', ARRAY['clips direction'], false),
('Support de crémaillère avant', 'direction', 'fixation', ARRAY['fixation crémaillère AV'], false),
('Support de crémaillère arrière', 'direction', 'fixation', ARRAY['fixation crémaillère AR'], false),
('Silent-bloc de crémaillère', 'direction', 'silent-bloc', ARRAY['silent-bloc rack'], true),
('Kit de fixation de crémaillère', 'direction', 'kit', ARRAY['kit fixations rack'], false),

-- Liquide et entretien
('Liquide de direction assistée', 'direction', 'fluide', ARRAY['huile DAH'], true),
('Filtre de direction assistée', 'direction', 'filtre', ARRAY['filtre DAH'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Crémaillère de direction',
  'Pompe de direction assistée',
  'Rotule de direction gauche',
  'Rotule de direction droite',
  'Biellette de direction gauche',
  'Biellette de direction droite',
  'Soufflet de crémaillère gauche',
  'Soufflet de crémaillère droit',
  'Colonne de direction',
  'Volant',
  'Airbag conducteur'
);
