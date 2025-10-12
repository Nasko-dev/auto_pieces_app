-- Ajout complet freinage

-- ========================================
-- FREINAGE
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Disques et tambours
('Disque de frein avant gauche', 'freinage', 'disque', ARRAY['disque AV G'], true),
('Disque de frein avant droit', 'freinage', 'disque', ARRAY['disque AV D'], true),
('Disque de frein arrière gauche', 'freinage', 'disque', ARRAY['disque AR G'], true),
('Disque de frein arrière droit', 'freinage', 'disque', ARRAY['disque AR D'], true),
('Kit disques de frein avant', 'freinage', 'kit', ARRAY['paire disques AV'], true),
('Kit disques de frein arrière', 'freinage', 'kit', ARRAY['paire disques AR'], true),
('Disque de frein ventilé avant', 'freinage', 'disque', ARRAY['disque ventilé AV'], true),
('Disque de frein percé avant', 'freinage', 'performance', ARRAY['disque sport percé AV'], false),
('Disque de frein rainuré avant', 'freinage', 'performance', ARRAY['disque sport rainuré AV'], false),
('Tambour de frein arrière gauche', 'freinage', 'tambour', ARRAY['tambour AR G'], true),
('Tambour de frein arrière droit', 'freinage', 'tambour', ARRAY['tambour AR D'], true),
('Kit tambours de frein arrière', 'freinage', 'kit', ARRAY['paire tambours AR'], false),

-- Plaquettes et garnitures
('Plaquettes de frein avant', 'freinage', 'plaquette', ARRAY['plaquettes AV', 'jeu plaquettes AV'], true),
('Plaquettes de frein arrière', 'freinage', 'plaquette', ARRAY['plaquettes AR', 'jeu plaquettes AR'], true),
('Plaquettes de frein céramique avant', 'freinage', 'performance', ARRAY['plaquettes céramique AV'], false),
('Plaquettes de frein sport avant', 'freinage', 'performance', ARRAY['plaquettes performance AV'], false),
('Garnitures de frein à tambour arrière', 'freinage', 'garniture', ARRAY['mâchoires AR'], true),
('Kit de garnitures de frein arrière', 'freinage', 'kit', ARRAY['kit mâchoires AR'], false),

-- Étriers
('Étrier de frein avant gauche', 'freinage', 'etrier', ARRAY['étrier AV G', 'caliper G'], true),
('Étrier de frein avant droit', 'freinage', 'etrier', ARRAY['étrier AV D', 'caliper D'], true),
('Étrier de frein arrière gauche', 'freinage', 'etrier', ARRAY['étrier AR G'], true),
('Étrier de frein arrière droit', 'freinage', 'etrier', ARRAY['étrier AR D'], true),
('Étrier de frein sport multi-pistons avant', 'freinage', 'performance', ARRAY['étrier sport AV'], false),
('Support d''étrier avant gauche', 'freinage', 'fixation', ARRAY['chape étrier AV G'], true),
('Support d''étrier avant droit', 'freinage', 'fixation', ARRAY['chape étrier AV D'], true),
('Support d''étrier arrière gauche', 'freinage', 'fixation', ARRAY['chape étrier AR G'], false),
('Support d''étrier arrière droit', 'freinage', 'fixation', ARRAY['chape étrier AR D'], false),
('Piston d''étrier de frein', 'freinage', 'etrier', ARRAY['piston caliper'], false),
('Kit de réparation d''étrier avant', 'freinage', 'kit', ARRAY['kit joints étrier AV'], true),
('Kit de réparation d''étrier arrière', 'freinage', 'kit', ARRAY['kit joints étrier AR'], false),
('Vis de purge d''étrier', 'freinage', 'fixation', ARRAY['vis de purge'], false),

-- Maître-cylindre et servofrein
('Maître-cylindre de frein', 'freinage', 'maitre-cylindre', ARRAY['MC frein', 'pompe frein'], true),
('Bocal de liquide de frein', 'freinage', 'reservoir', ARRAY['réservoir LDF'], true),
('Servofrein', 'freinage', 'servofrein', ARRAY['mastervac', 'assistance freinage'], true),
('Durite de servofrein', 'freinage', 'durite', ARRAY['durite dépression servo'], false),
('Clapet de servofrein', 'freinage', 'servofrein', ARRAY['valve servo'], false),
('Kit de réparation maître-cylindre', 'freinage', 'kit', ARRAY['kit joints MC'], false),

-- Frein de stationnement
('Câble de frein à main gauche', 'freinage', 'frein-main', ARRAY['câble parking G'], true),
('Câble de frein à main droit', 'freinage', 'frein-main', ARRAY['câble parking D'], true),
('Câble de frein à main central', 'freinage', 'frein-main', ARRAY['câble parking central'], false),
('Levier de frein à main', 'freinage', 'frein-main', ARRAY['levier parking'], true),
('Étrier de frein de stationnement arrière gauche', 'freinage', 'frein-main', ARRAY['étrier parking AR G'], false),
('Étrier de frein de stationnement arrière droit', 'freinage', 'frein-main', ARRAY['étrier parking AR D'], false),
('Moteur de frein de stationnement électrique gauche', 'freinage', 'electronique', ARRAY['moteur EPB G'], true),
('Moteur de frein de stationnement électrique droit', 'freinage', 'electronique', ARRAY['moteur EPB D'], true),
('Module de frein de stationnement électrique', 'freinage', 'electronique', ARRAY['calculateur EPB'], false),
('Bouton de frein de stationnement électrique', 'freinage', 'commande', ARRAY['bouton EPB'], false),

-- Circuits hydrauliques
('Flexible de frein avant gauche', 'freinage', 'durite', ARRAY['durite flexible AV G'], true),
('Flexible de frein avant droit', 'freinage', 'durite', ARRAY['durite flexible AV D'], true),
('Flexible de frein arrière gauche', 'freinage', 'durite', ARRAY['durite flexible AR G'], true),
('Flexible de frein arrière droit', 'freinage', 'durite', ARRAY['durite flexible AR D'], true),
('Kit flexibles de frein avant', 'freinage', 'kit', ARRAY['kit durites AV'], false),
('Kit flexibles de frein arrière', 'freinage', 'kit', ARRAY['kit durites AR'], false),
('Flexible de frein tressé avant', 'freinage', 'performance', ARRAY['durite aviation AV'], false),
('Canalisation de frein avant', 'freinage', 'durite', ARRAY['pipe rigide AV'], false),
('Canalisation de frein arrière', 'freinage', 'durite', ARRAY['pipe rigide AR'], false),
('Raccord de durite de frein', 'freinage', 'fixation', ARRAY['banjo frein'], false),
('Rondelle de raccord de frein', 'freinage', 'joint', ARRAY['joint banjo'], false),

-- ABS et ESP
('Capteur ABS avant gauche', 'freinage', 'capteur', ARRAY['capteur vitesse roue AV G'], true),
('Capteur ABS avant droit', 'freinage', 'capteur', ARRAY['capteur vitesse roue AV D'], true),
('Capteur ABS arrière gauche', 'freinage', 'capteur', ARRAY['capteur vitesse roue AR G'], true),
('Capteur ABS arrière droit', 'freinage', 'capteur', ARRAY['capteur vitesse roue AR D'], true),
('Calculateur ABS', 'freinage', 'electronique', ARRAY['module ABS', 'ECU ABS'], true),
('Calculateur ESP', 'freinage', 'electronique', ARRAY['module ESP', 'ECU ESP'], false),
('Bloc hydraulique ABS', 'freinage', 'hydraulique', ARRAY['bloc ABS', 'HCU'], true),
('Bloc hydraulique ESP', 'freinage', 'hydraulique', ARRAY['bloc ESP'], false),
('Pompe ABS', 'freinage', 'hydraulique', ARRAY['pompe bloc ABS'], false),
('Capteur de pression de frein', 'freinage', 'capteur', ARRAY['capteur pression freinage'], false),
('Contacteur de stop', 'freinage', 'capteur', ARRAY['contacteur feux stop'], true),
('Capteur d''usure de plaquettes avant', 'freinage', 'capteur', ARRAY['témoin usure plaquettes AV'], false),
('Capteur d''usure de plaquettes arrière', 'freinage', 'capteur', ARRAY['témoin usure plaquettes AR'], false),

-- Frein moteur et assistance
('Valve de frein moteur', 'freinage', 'valve', ARRAY['valve échappement frein'], false),
('Capteur d''angle de pédale de frein', 'freinage', 'capteur', ARRAY['capteur position pédale'], false),
('Pédale de frein', 'freinage', 'pedale', ARRAY['pédalier frein'], true),
('Support de pédale de frein', 'freinage', 'fixation', ARRAY['fixation pédale'], false),
('Ressort de pédale de frein', 'freinage', 'ressort', ARRAY['rappel pédale'], false),

-- Liquide et joints
('Liquide de frein DOT 4', 'freinage', 'fluide', ARRAY['LDF DOT4'], true),
('Liquide de frein DOT 5.1', 'freinage', 'fluide', ARRAY['LDF DOT5.1'], false),
('Kit de joints de frein', 'freinage', 'kit', ARRAY['kit joints circuit frein'], false),

-- Assistance freinage
('Assistant de freinage d''urgence', 'freinage', 'electronique', ARRAY['BAS', 'brake assist'], false),
('Module de freinage automatique d''urgence', 'freinage', 'electronique', ARRAY['AEB', 'autonomous emergency braking'], false),

-- Pièces tambour
('Cylindre de roue arrière gauche', 'freinage', 'tambour', ARRAY['cylindre récepteur AR G'], true),
('Cylindre de roue arrière droit', 'freinage', 'tambour', ARRAY['cylindre récepteur AR D'], true),
('Ressort de rappel de mâchoire', 'freinage', 'tambour', ARRAY['ressort tambour'], false),
('Kit de ressorts de frein à tambour', 'freinage', 'kit', ARRAY['kit ressorts tambour'], false),
('Kit de réparation cylindre de roue', 'freinage', 'kit', ARRAY['kit joints cylindre'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Disque de frein avant gauche',
  'Disque de frein avant droit',
  'Plaquettes de frein avant',
  'Plaquettes de frein arrière',
  'Étrier de frein avant gauche',
  'Étrier de frein avant droit',
  'Maître-cylindre de frein',
  'Servofrein',
  'Capteur ABS avant gauche',
  'Capteur ABS avant droit',
  'Calculateur ABS',
  'Flexible de frein avant gauche',
  'Contacteur de stop'
);
