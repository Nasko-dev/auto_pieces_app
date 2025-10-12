-- Ajout complet alimentation carburant

-- ========================================
-- ALIMENTATION CARBURANT
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Réservoir
('Réservoir de carburant', 'carburant', 'reservoir', ARRAY['réservoir essence', 'fuel tank'], true),
('Bouchon de réservoir', 'carburant', 'reservoir', ARRAY['bouchon essence'], true),
('Bouchon de réservoir avec clé', 'carburant', 'reservoir', ARRAY['bouchon verrouillable'], false),
('Trappe à carburant', 'carburant', 'reservoir', ARRAY['volet essence'], true),
('Goulotte de remplissage', 'carburant', 'reservoir', ARRAY['col de cygne'], false),
('Durite de remplissage', 'carburant', 'reservoir', ARRAY['tuyau remplissage'], true),
('Durite de mise à l''air', 'carburant', 'reservoir', ARRAY['évent réservoir'], false),
('Capteur de niveau de carburant', 'carburant', 'capteur', ARRAY['jauge carburant'], true),
('Flotteur de réservoir', 'carburant', 'reservoir', ARRAY['flotteur jauge'], false),

-- Pompe à carburant
('Pompe à carburant', 'carburant', 'pompe', ARRAY['pompe essence', 'fuel pump'], true),
('Pompe à carburant immergée', 'carburant', 'pompe', ARRAY['pompe in-tank'], true),
('Pompe de gavage', 'carburant', 'pompe', ARRAY['pompe basse pression'], false),
('Pompe haute pression essence', 'carburant', 'pompe', ARRAY['pompe HP essence'], true),
('Pompe haute pression diesel', 'carburant', 'pompe', ARRAY['pompe HP diesel'], true),
('Pompe d''amorçage diesel', 'carburant', 'pompe', ARRAY['poire d''amorçage'], true),
('Relais de pompe à carburant', 'carburant', 'electronique', ARRAY['relais pompe'], false),
('Pré-filtre de pompe à carburant', 'carburant', 'filtre', ARRAY['crépine pompe'], true),

-- Filtre à carburant
('Filtre à carburant', 'carburant', 'filtre', ARRAY['filtre essence', 'fuel filter'], true),
('Filtre à gasoil', 'carburant', 'filtre', ARRAY['filtre diesel'], true),
('Filtre à carburant avec décanteur', 'carburant', 'filtre', ARRAY['filtre séparateur'], false),
('Capteur d''eau dans gasoil', 'carburant', 'capteur', ARRAY['sonde eau filtre'], false),
('Support de filtre à carburant', 'carburant', 'fixation', ARRAY['corps filtre'], false),

-- Durites et canalisations
('Durite d''alimentation carburant', 'carburant', 'durite', ARRAY['durite essence'], true),
('Durite de retour de carburant', 'carburant', 'durite', ARRAY['durite retour'], false),
('Canalisation rigide de carburant', 'carburant', 'durite', ARRAY['pipe essence'], false),
('Raccord rapide de carburant', 'carburant', 'raccord', ARRAY['quick connector'], true),
('Clapet anti-retour de carburant', 'carburant', 'valve', ARRAY['valve anti-retour'], false),

-- Injection essence
('Injecteur essence', 'carburant', 'injection', ARRAY['injecteur multipoint'], true),
('Rampe d''injection essence', 'carburant', 'injection', ARRAY['rail injecteurs'], true),
('Joint d''injecteur essence', 'carburant', 'joint', ARRAY['joint torique injecteur'], true),
('Régulateur de pression essence', 'carburant', 'injection', ARRAY['RDS'], true),
('Capteur de pression de carburant', 'carburant', 'capteur', ARRAY['capteur rail'], true),
('Capteur de température de carburant', 'carburant', 'capteur', ARRAY['sonde T° carburant'], false),

-- Injection diesel
('Injecteur diesel', 'carburant', 'injection', ARRAY['injecteur HDI'], true),
('Injecteur pompe diesel', 'carburant', 'injection', ARRAY['injecteur pompe'], false),
('Rampe commune diesel', 'carburant', 'injection', ARRAY['common rail'], true),
('Régulateur de pression diesel', 'carburant', 'injection', ARRAY['IMV', 'DRV'], true),
('Capteur de pression rampe diesel', 'carburant', 'capteur', ARRAY['capteur rail HP'], true),
('Joint d''injecteur diesel', 'carburant', 'joint', ARRAY['joint cuivre injecteur'], true),
('Rondelle d''injecteur diesel', 'carburant', 'joint', ARRAY['rondelle étanchéité'], true),
('Vis d''injecteur diesel', 'carburant', 'fixation', ARRAY['vis fixation injecteur'], false),

-- Carburateur (véhicules anciens)
('Carburateur', 'carburant', 'carburateur', ARRAY['carbu'], false),
('Kit de réparation carburateur', 'carburant', 'kit', ARRAY['kit joints carbu'], false),
('Membrane de carburateur', 'carburant', 'carburateur', ARRAY['diaphragme carbu'], false),
('Gicleur de carburateur', 'carburant', 'carburateur', ARRAY['jet'], false),
('Pointeau de carburateur', 'carburant', 'carburateur', ARRAY['aiguille carbu'], false),
('Flotteur de carburateur', 'carburant', 'carburateur', ARRAY['float'], false),
('Starter de carburateur', 'carburant', 'carburateur', ARRAY['enrichisseur'], false),

-- Canister et vapeurs
('Canister', 'carburant', 'canister', ARRAY['filtre à charbon'], true),
('Électrovanne de canister', 'carburant', 'canister', ARRAY['purge canister'], true),
('Durite de canister', 'carburant', 'canister', ARRAY['tuyau vapeur'], false),
('Capteur de pression de vapeur', 'carburant', 'capteur', ARRAY['LDP'], false),

-- Accélérateur
('Pédale d''accélérateur', 'carburant', 'pedale', ARRAY['pédale de gaz'], true),
('Capteur de pédale d''accélérateur', 'carburant', 'capteur', ARRAY['potentiomètre pédale'], true),
('Câble d''accélérateur', 'carburant', 'cable', ARRAY['câble de gaz'], true),
('Ressort de rappel d''accélérateur', 'carburant', 'ressort', ARRAY['rappel pédale'], false),

-- Régulateur de ralenti
('Régulateur de ralenti', 'carburant', 'valve', ARRAY['IAC', 'boisseau'], true),
('Vis de richesse', 'carburant', 'reglage', ARRAY['vis mélange'], false),
('Vis de ralenti', 'carburant', 'reglage', ARRAY['vis by-pass'], false),

-- Réchauffeur carburant diesel
('Réchauffeur de gasoil', 'carburant', 'rechauffeur', ARRAY['chauffage diesel'], false),
('Résistance de réchauffeur diesel', 'carburant', 'rechauffeur', ARRAY['bougie de préchauffage carburant'], false),

-- Clapet et vannes
('Clapet de décharge de pression', 'carburant', 'valve', ARRAY['soupape surpression'], false),
('Vanne de coupure de carburant', 'carburant', 'valve', ARRAY['électrovanne arrêt'], false),

-- Additifs et traitements
('Additif nettoyant injecteurs essence', 'carburant', 'additif', ARRAY['nettoyant injection'], true),
('Additif nettoyant injecteurs diesel', 'carburant', 'additif', ARRAY['nettoyant diesel'], true),
('Anti-gel diesel', 'carburant', 'additif', ARRAY['additif hiver'], true),
('Additif cétan', 'carburant', 'additif', ARRAY['booster cétan'], false),
('Additif octane', 'carburant', 'additif', ARRAY['booster octane'], false),

-- Bouchons et joints
('Joint de bouchon de réservoir', 'carburant', 'joint', ARRAY['joint bouchon'], false),
('Joint de capteur de niveau', 'carburant', 'joint', ARRAY['joint jauge'], false),
('Joint de pompe à carburant', 'carburant', 'joint', ARRAY['joint pompe'], true),

-- GPL et carburants alternatifs
('Réservoir GPL', 'carburant', 'gpl', ARRAY['bouteille GPL'], false),
('Détendeur GPL', 'carburant', 'gpl', ARRAY['vaporisateur'], false),
('Injecteur GPL', 'carburant', 'gpl', ARRAY['rail GPL'], false),
('Électrovanne GPL', 'carburant', 'gpl', ARRAY['valve GPL'], false),
('Filtre GPL', 'carburant', 'gpl', ARRAY['filtre gaz'], false),
('Calculateur GPL', 'carburant', 'gpl', ARRAY['ECU GPL'], false),
('Commutateur essence/GPL', 'carburant', 'gpl', ARRAY['switch GPL'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Réservoir de carburant',
  'Bouchon de réservoir',
  'Pompe à carburant',
  'Filtre à carburant',
  'Filtre à gasoil',
  'Injecteur essence',
  'Injecteur diesel',
  'Rampe d''injection essence',
  'Rampe commune diesel',
  'Capteur de niveau de carburant',
  'Canister',
  'Électrovanne de canister',
  'Pédale d''accélérateur',
  'Capteur de pédale d''accélérateur'
);
