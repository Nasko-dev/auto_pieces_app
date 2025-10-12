-- Ajout complet électricité et électronique moteur

-- ========================================
-- ÉLECTRICITÉ & ÉLECTRONIQUE MOTEUR
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Batterie et démarrage
('Batterie 12V', 'electricite', 'batterie', ARRAY['batterie voiture'], true),
('Batterie 60Ah', 'electricite', 'batterie', ARRAY['batterie 60A'], true),
('Batterie 70Ah', 'electricite', 'batterie', ARRAY['batterie 70A'], true),
('Batterie 80Ah', 'electricite', 'batterie', ARRAY['batterie 80A'], true),
('Batterie AGM', 'electricite', 'batterie', ARRAY['batterie start-stop'], true),
('Batterie EFB', 'electricite', 'batterie', ARRAY['batterie enhanced'], false),
('Câble de batterie positif', 'electricite', 'cable', ARRAY['cosse +'], true),
('Câble de batterie négatif', 'electricite', 'cable', ARRAY['cosse -', 'masse'], true),
('Cosse de batterie', 'electricite', 'batterie', ARRAY['borne batterie'], false),
('Bac à batterie', 'electricite', 'fixation', ARRAY['support batterie'], false),
('Sangle de batterie', 'electricite', 'fixation', ARRAY['maintien batterie'], false),

-- Démarreur
('Démarreur', 'electricite', 'demarreur', ARRAY['starter'], true),
('Solénoïde de démarreur', 'electricite', 'demarreur', ARRAY['contacteur démarreur'], false),
('Lanceur de démarreur', 'electricite', 'demarreur', ARRAY['pignon lanceur'], true),
('Induit de démarreur', 'electricite', 'demarreur', ARRAY['rotor démarreur'], false),
('Stator de démarreur', 'electricite', 'demarreur', ARRAY['inducteur'], false),
('Charbon de démarreur', 'electricite', 'demarreur', ARRAY['balai démarreur'], false),
('Kit de réparation démarreur', 'electricite', 'kit', ARRAY['kit démarreur'], false),

-- Alternateur
('Alternateur', 'electricite', 'alternateur', ARRAY['alternator'], true),
('Poulie d''alternateur', 'electricite', 'alternateur', ARRAY['poulie roue libre'], true),
('Régulateur d''alternateur', 'electricite', 'alternateur', ARRAY['regulateur tension'], true),
('Charbon d''alternateur', 'electricite', 'alternateur', ARRAY['balai alternateur'], true),
('Rotor d''alternateur', 'electricite', 'alternateur', ARRAY['induit alternateur'], false),
('Stator d''alternateur', 'electricite', 'alternateur', ARRAY['bobinage alternateur'], false),
('Pont de diodes d''alternateur', 'electricite', 'alternateur', ARRAY['redresseur alternateur'], false),
('Roulement d''alternateur', 'electricite', 'alternateur', ARRAY['bearing alternateur'], false),
('Kit de réparation alternateur', 'electricite', 'kit', ARRAY['kit alternateur'], false),

-- Courroie accessoires
('Courroie d''accessoires', 'moteur', 'courroie', ARRAY['courroie serpentine'], true),
('Courroie trapézoïdale', 'moteur', 'courroie', ARRAY['courroie en V'], false),
('Courroie poly-V', 'moteur', 'courroie', ARRAY['courroie striée'], true),
('Galet tendeur de courroie accessoires', 'moteur', 'courroie', ARRAY['tendeur courroie'], true),
('Galet enrouleur de courroie', 'moteur', 'courroie', ARRAY['poulie de renvoi'], true),
('Poulie d''accessoires', 'moteur', 'courroie', ARRAY['poulie'], false),

-- Calculateurs et modules
('Calculateur moteur', 'electronique', 'calculateur', ARRAY['ECU', 'UCE moteur'], true),
('Calculateur injection', 'electronique', 'calculateur', ARRAY['module injection'], false),
('Module d''allumage', 'electronique', 'allumage', ARRAY['boîtier allumage'], false),
('Boîtier BSI', 'electronique', 'calculateur', ARRAY['fusebox intelligent'], true),
('Boîtier BSM', 'electronique', 'calculateur', ARRAY['module fusibles'], false),

-- Allumage essence
('Bobine d''allumage', 'electricite', 'allumage', ARRAY['coil'], true),
('Bougie d''allumage', 'electricite', 'allumage', ARRAY['spark plug'], true),
('Câble de bougie', 'electricite', 'allumage', ARRAY['fil HT'], true),
('Antiparasites de bougie', 'electricite', 'allumage', ARRAY['capuchon bougie'], false),
('Delco', 'electricite', 'allumage', ARRAY['distributeur'], false),
('Tête de delco', 'electricite', 'allumage', ARRAY['doigt delco'], false),

-- Préchauffage diesel
('Bougie de préchauffage', 'electricite', 'prechauffage', ARRAY['bougie diesel'], true),
('Relais de préchauffage', 'electricite', 'prechauffage', ARRAY['boîtier préchauffage'], true),
('Centrale de préchauffage', 'electricite', 'prechauffage', ARRAY['module glow plug'], false),

-- Capteurs moteur
('Capteur PMH', 'electronique', 'capteur', ARRAY['capteur vilebrequin'], true),
('Capteur AAC', 'electronique', 'capteur', ARRAY['capteur arbre à cames'], true),
('Capteur de cliquetis', 'electronique', 'capteur', ARRAY['knock sensor'], true),
('Capteur de pression atmosphérique', 'electronique', 'capteur', ARRAY['capteur BARO'], false),
('Capteur de température moteur', 'electronique', 'capteur', ARRAY['sonde eau moteur'], true),
('Sonde de température d''air', 'electronique', 'capteur', ARRAY['capteur IAT'], false),
('Capteur de régime moteur', 'electronique', 'capteur', ARRAY['capteur RPM'], false),

-- Relais et fusibles
('Boîte à fusibles moteur', 'electricite', 'fusible', ARRAY['PDC'], true),
('Boîte à fusibles habitacle', 'electricite', 'fusible', ARRAY['boîtier fusibles intérieur'], false),
('Fusible standard', 'electricite', 'fusible', ARRAY['fusible lame'], true),
('Fusible maxi', 'electricite', 'fusible', ARRAY['maxi fuse'], false),
('Fusible mini', 'electricite', 'fusible', ARRAY['mini fuse'], false),
('Relais principal', 'electricite', 'relais', ARRAY['relais contact'], true),
('Relais de pompe à carburant', 'electricite', 'relais', ARRAY['relais pompe'], false),
('Relais de démarreur', 'electricite', 'relais', ARRAY['relais starter'], false),

-- Câblage moteur
('Faisceau moteur', 'electricite', 'faisceau', ARRAY['câblage moteur'], true),
('Faisceau d''injection', 'electricite', 'faisceau', ARRAY['câblage injecteurs'], true),
('Faisceau de bougie de préchauffage', 'electricite', 'faisceau', ARRAY['câblage bougies diesel'], false),
('Connecteur moteur', 'electricite', 'connecteur', ARRAY['prise moteur'], false),
('Cosse électrique', 'electricite', 'connecteur', ARRAY['connecteur rapide'], false),

-- Masse et terre
('Câble de masse moteur', 'electricite', 'cable', ARRAY['tresse masse'], true),
('Câble de masse châssis', 'electricite', 'cable', ARRAY['masse carrosserie'], false),
('Point de masse', 'electricite', 'fixation', ARRAY['prise masse'], false),

-- Contacteur et interrupteurs
('Contacteur de pédale de frein', 'electricite', 'contacteur', ARRAY['stop switch'], true),
('Contacteur de pédale d''embrayage', 'electricite', 'contacteur', ARRAY['embrayage switch'], false),
('Contacteur de marche arrière', 'electricite', 'contacteur', ARRAY['switch recul'], true),
('Contacteur de porte', 'electricite', 'contacteur', ARRAY['switch porte'], false),

-- Neiman et antidémarrage
('Neiman', 'electricite', 'antivol', ARRAY['contacteur clé'], true),
('Barillet de neiman', 'electricite', 'antivol', ARRAY['serrure neiman'], false),
('Antenne d''antidémarrage', 'electronique', 'antivol', ARRAY['lecteur transpondeur'], false),
('Transpondeur de clé', 'electronique', 'antivol', ARRAY['puce clé'], true),
('Calculateur d''antidémarrage', 'electronique', 'antivol', ARRAY['immobilizer'], false),

-- Pompe et électrovanne
('Pompe à dépression', 'electricite', 'pompe', ARRAY['pompe vacuum'], false),
('Électrovanne de dépression', 'electricite', 'valve', ARRAY['solénoïde vacuum'], false),
('Électrovanne de géométrie variable', 'electricite', 'valve', ARRAY['solénoïde VGT'], false),

-- Actuateurs
('Actuateur de ralenti', 'electricite', 'actuateur', ARRAY['IAC valve'], false),
('Actuateur de papillon', 'electricite', 'actuateur', ARRAY['moteur papillon'], false),
('Actuateur de volet d''admission', 'electricite', 'actuateur', ARRAY['servo admission'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Batterie 12V',
  'Batterie AGM',
  'Démarreur',
  'Alternateur',
  'Courroie d''accessoires',
  'Galet tendeur de courroie accessoires',
  'Calculateur moteur',
  'Bobine d''allumage',
  'Bougie d''allumage',
  'Bougie de préchauffage',
  'Relais de préchauffage',
  'Capteur PMH',
  'Capteur AAC',
  'Capteur de cliquetis',
  'Faisceau moteur',
  'Neiman'
);
