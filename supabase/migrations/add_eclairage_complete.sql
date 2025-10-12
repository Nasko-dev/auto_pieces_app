-- Ajout complet éclairage

-- ========================================
-- ÉCLAIRAGE
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Phares avant
('Phare avant gauche', 'eclairage', 'phare', ARRAY['optique AV G'], true),
('Phare avant droit', 'eclairage', 'phare', ARRAY['optique AV D'], true),
('Phare avant gauche LED', 'eclairage', 'phare', ARRAY['phare LED G'], false),
('Phare avant droit LED', 'eclairage', 'phare', ARRAY['phare LED D'], false),
('Phare avant gauche Xénon', 'eclairage', 'phare', ARRAY['phare Xenon G'], false),
('Phare avant droit Xénon', 'eclairage', 'phare', ARRAY['phare Xenon D'], false),
('Glace de phare avant gauche', 'eclairage', 'phare', ARRAY['verre phare AV G'], true),
('Glace de phare avant droit', 'eclairage', 'phare', ARRAY['verre phare AV D'], true),
('Support de phare avant gauche', 'eclairage', 'fixation', ARRAY['fixation phare G'], false),
('Support de phare avant droit', 'eclairage', 'fixation', ARRAY['fixation phare D'], false),

-- Feux arrière
('Feu arrière gauche', 'eclairage', 'feu', ARRAY['optique AR G'], true),
('Feu arrière droit', 'eclairage', 'feu', ARRAY['optique AR D'], true),
('Feu arrière gauche LED', 'eclairage', 'feu', ARRAY['feu LED AR G'], false),
('Feu arrière droit LED', 'eclairage', 'feu', ARRAY['feu LED AR D'], false),
('Glace de feu arrière gauche', 'eclairage', 'feu', ARRAY['verre feu AR G'], false),
('Glace de feu arrière droit', 'eclairage', 'feu', ARRAY['verre feu AR D'], false),
('Feu de hayon central', 'eclairage', 'feu', ARRAY['3ème feu stop'], true),
('Feu de coffre gauche', 'eclairage', 'feu', ARRAY['feu coffre G'], false),
('Feu de coffre droit', 'eclairage', 'feu', ARRAY['feu coffre D'], false),

-- Antibrouillards
('Antibrouillard avant gauche', 'eclairage', 'antibrouillard', ARRAY['feu antibrouillard AV G'], true),
('Antibrouillard avant droit', 'eclairage', 'antibrouillard', ARRAY['feu antibrouillard AV D'], true),
('Antibrouillard arrière gauche', 'eclairage', 'antibrouillard', ARRAY['feu antibrouillard AR G'], false),
('Antibrouillard arrière droit', 'eclairage', 'antibrouillard', ARRAY['feu antibrouillard AR D'], false),
('Grille d''antibrouillard avant gauche', 'carrosserie', 'grille', ARRAY['grille antibrouillard G'], false),
('Grille d''antibrouillard avant droite', 'carrosserie', 'grille', ARRAY['grille antibrouillard D'], false),

-- Clignotants
('Clignotant avant gauche', 'eclairage', 'clignotant', ARRAY['feu clignotant AV G'], true),
('Clignotant avant droit', 'eclairage', 'clignotant', ARRAY['feu clignotant AV D'], true),
('Clignotant latéral gauche', 'eclairage', 'clignotant', ARRAY['répétiteur latéral G'], true),
('Clignotant latéral droit', 'eclairage', 'clignotant', ARRAY['répétiteur latéral D'], true),

-- Feux de position et diurne
('Feu de position avant gauche', 'eclairage', 'position', ARRAY['veilleuse AV G'], false),
('Feu de position avant droit', 'eclairage', 'position', ARRAY['veilleuse AV D'], false),
('Feu de jour avant gauche', 'eclairage', 'feu-diurne', ARRAY['DRL gauche'], false),
('Feu de jour avant droit', 'eclairage', 'feu-diurne', ARRAY['DRL droit'], false),

-- Éclairage de plaque
('Éclairage de plaque d''immatriculation', 'eclairage', 'plaque', ARRAY['feu plaque'], true),
('Support d''éclairage de plaque', 'eclairage', 'fixation', ARRAY['fixation feu plaque'], false),

-- Ampoules
('Ampoule H1', 'eclairage', 'ampoule', ARRAY['lampe H1'], true),
('Ampoule H4', 'eclairage', 'ampoule', ARRAY['lampe H4'], true),
('Ampoule H7', 'eclairage', 'ampoule', ARRAY['lampe H7'], true),
('Ampoule H11', 'eclairage', 'ampoule', ARRAY['lampe H11'], true),
('Ampoule H3', 'eclairage', 'ampoule', ARRAY['lampe H3'], false),
('Ampoule H8', 'eclairage', 'ampoule', ARRAY['lampe H8'], false),
('Ampoule H9', 'eclairage', 'ampoule', ARRAY['lampe H9'], false),
('Ampoule HB3', 'eclairage', 'ampoule', ARRAY['lampe 9005'], false),
('Ampoule HB4', 'eclairage', 'ampoule', ARRAY['lampe 9006'], false),
('Ampoule P21W', 'eclairage', 'ampoule', ARRAY['lampe 1156'], true),
('Ampoule P21/5W', 'eclairage', 'ampoule', ARRAY['lampe 1157'], true),
('Ampoule W5W', 'eclairage', 'ampoule', ARRAY['lampe T10'], true),
('Ampoule T4W', 'eclairage', 'ampoule', ARRAY['veilleuse tableau bord'], false),
('Ampoule C5W', 'eclairage', 'ampoule', ARRAY['navette'], true),
('Ampoule PY21W', 'eclairage', 'ampoule', ARRAY['clignotant orange'], true),
('Kit ampoules de rechange', 'eclairage', 'kit', ARRAY['coffret ampoules'], false),

-- Ampoules LED
('Ampoule LED H7', 'eclairage', 'ampoule-led', ARRAY['LED H7'], false),
('Ampoule LED W5W', 'eclairage', 'ampoule-led', ARRAY['LED T10'], false),
('Ampoule LED P21W', 'eclairage', 'ampoule-led', ARRAY['LED BA15S'], false),

-- Xénon
('Ampoule Xénon D1S', 'eclairage', 'xenon', ARRAY['lampe Xenon D1S'], false),
('Ampoule Xénon D2S', 'eclairage', 'xenon', ARRAY['lampe Xenon D2S'], false),
('Ampoule Xénon D3S', 'eclairage', 'xenon', ARRAY['lampe Xenon D3S'], false),
('Ampoule Xénon D4S', 'eclairage', 'xenon', ARRAY['lampe Xenon D4S'], false),
('Ballast Xénon', 'eclairage', 'xenon', ARRAY['module Xenon'], true),
('Allumeur Xénon', 'eclairage', 'xenon', ARRAY['igniter Xenon'], false),

-- Lave-phares
('Lave-phare gauche', 'eclairage', 'lave-phare', ARRAY['gicleur phare G'], true),
('Lave-phare droit', 'eclairage', 'lave-phare', ARRAY['gicleur phare D'], true),
('Pompe de lave-phares', 'eclairage', 'lave-phare', ARRAY['pompe lave-optique'], true),
('Réservoir de lave-phares', 'eclairage', 'lave-phare', ARRAY['bocal lave-phare'], false),

-- Correcteur de phares
('Correcteur de phare gauche', 'eclairage', 'correcteur', ARRAY['vérin phare G'], false),
('Correcteur de phare droit', 'eclairage', 'correcteur', ARRAY['vérin phare D'], false),
('Moteur de correcteur de phare', 'eclairage', 'correcteur', ARRAY['servo correcteur'], false),
('Capteur d''assiette avant', 'eclairage', 'capteur', ARRAY['capteur hauteur AV'], false),
('Capteur d''assiette arrière', 'eclairage', 'capteur', ARRAY['capteur hauteur AR'], false),

-- Commandes d'éclairage
('Commodo d''éclairage', 'eclairage', 'commande', ARRAY['interrupteur phares'], true),
('Bouton d''antibrouillard', 'eclairage', 'commande', ARRAY['interrupteur antibrouillard'], false),
('Variateur d''éclairage', 'eclairage', 'commande', ARRAY['rhéostat'], false),
('Capteur de pluie et lumière', 'eclairage', 'capteur', ARRAY['capteur automatique'], false),

-- Phares additionnels
('Phare longue portée', 'eclairage', 'phare-additionnel', ARRAY['longue portée'], false),
('Barre LED', 'eclairage', 'phare-additionnel', ARRAY['rampe LED'], false),
('Phare de travail', 'eclairage', 'phare-additionnel', ARRAY['projecteur'], false),

-- Modules et calculateurs
('Module LED de phare avant gauche', 'eclairage', 'module', ARRAY['driver LED G'], false),
('Module LED de phare avant droit', 'eclairage', 'module', ARRAY['driver LED D'], false),
('Calculateur de phares adaptatifs', 'eclairage', 'module', ARRAY['ECU phares directionnels'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Phare avant gauche',
  'Phare avant droit',
  'Feu arrière gauche',
  'Feu arrière droit',
  'Antibrouillard avant gauche',
  'Antibrouillard avant droit',
  'Clignotant avant gauche',
  'Clignotant avant droit',
  'Ampoule H7',
  'Ampoule H4',
  'Ampoule W5W',
  'Ampoule P21W',
  'Ballast Xénon',
  'Lave-phare gauche',
  'Lave-phare droit'
);
