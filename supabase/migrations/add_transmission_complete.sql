-- Ajout complet transmission

-- ========================================
-- TRANSMISSION
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Boîte de vitesses manuelle
('Boîte de vitesses manuelle', 'transmission', 'boite', ARRAY['BVM', 'gearbox manuelle'], true),
('Boîte de vitesses manuelle 5 rapports', 'transmission', 'boite', ARRAY['BVM5'], true),
('Boîte de vitesses manuelle 6 rapports', 'transmission', 'boite', ARRAY['BVM6'], true),
('Carter de boîte de vitesses', 'transmission', 'boite', ARRAY['coque BV'], false),
('Pignon de boîte de vitesses', 'transmission', 'boite', ARRAY['pignon BV'], false),
('Arbre primaire de boîte', 'transmission', 'boite', ARRAY['arbre d''entrée BV'], false),
('Arbre secondaire de boîte', 'transmission', 'boite', ARRAY['arbre de sortie BV'], false),
('Fourchette de boîte de vitesses', 'transmission', 'boite', ARRAY['fourchette sélection'], false),
('Synchro de boîte de vitesses', 'transmission', 'boite', ARRAY['synchroniseur BV'], false),
('Roulement de boîte de vitesses', 'transmission', 'roulement', ARRAY['bearing BV'], false),
('Joint spi de boîte de vitesses', 'transmission', 'joint', ARRAY['spi arbre BV'], true),
('Kit de réparation boîte de vitesses', 'transmission', 'kit', ARRAY['kit joints BV'], false),

-- Boîte de vitesses automatique
('Boîte de vitesses automatique', 'transmission', 'boite', ARRAY['BVA', 'auto transmission'], true),
('Boîte de vitesses robotisée', 'transmission', 'boite', ARRAY['BVR', 'boîte séquentielle'], false),
('Convertisseur de couple', 'transmission', 'bva', ARRAY['torque converter'], true),
('Valve body de boîte automatique', 'transmission', 'bva', ARRAY['bloc hydraulique BVA'], false),
('Solénoïde de boîte automatique', 'transmission', 'bva', ARRAY['électrovanne BVA'], true),
('Calculateur de boîte automatique', 'transmission', 'electronique', ARRAY['TCU', 'ECU BVA'], true),
('Capteur de vitesse de boîte', 'transmission', 'capteur', ARRAY['capteur régime BV'], true),
('Capteur de température de boîte', 'transmission', 'capteur', ARRAY['sonde température BVA'], false),
('Filtre de boîte automatique', 'transmission', 'filtre', ARRAY['filtre huile BVA'], true),
('Carter d''huile de boîte automatique', 'transmission', 'bva', ARRAY['carter BVA'], false),
('Joint de carter de boîte automatique', 'transmission', 'joint', ARRAY['joint carter BVA'], true),
('Radiateur de boîte automatique', 'transmission', 'refroidissement', ARRAY['échangeur BVA'], true),
('Durite de radiateur de boîte', 'transmission', 'durite', ARRAY['durite refroidisseur BVA'], false),

-- Boîte de vitesses à variation continue (CVT)
('Boîte CVT', 'transmission', 'boite', ARRAY['variation continue', 'CVT transmission'], false),
('Courroie de boîte CVT', 'transmission', 'cvt', ARRAY['chaîne CVT'], false),
('Poulie primaire CVT', 'transmission', 'cvt', ARRAY['poulie motrice CVT'], false),
('Poulie secondaire CVT', 'transmission', 'cvt', ARRAY['poulie menée CVT'], false),
('Actuateur de boîte CVT', 'transmission', 'cvt', ARRAY['servo CVT'], false),

-- Embrayage
('Kit embrayage complet', 'transmission', 'embrayage', ARRAY['kit embrayage 3 pièces'], true),
('Disque d''embrayage', 'transmission', 'embrayage', ARRAY['disque friction'], true),
('Mécanisme d''embrayage', 'transmission', 'embrayage', ARRAY['plateau de pression'], true),
('Butée d''embrayage', 'transmission', 'embrayage', ARRAY['butée hydraulique'], true),
('Volant moteur', 'transmission', 'embrayage', ARRAY['flywheel'], true),
('Volant moteur bi-masse', 'transmission', 'embrayage', ARRAY['DMF', 'dual mass flywheel'], true),
('Kit embrayage renforcé', 'transmission', 'performance', ARRAY['embrayage sport'], false),
('Fourchette d''embrayage', 'transmission', 'embrayage', ARRAY['fourchette débrayage'], false),
('Câble d''embrayage', 'transmission', 'embrayage', ARRAY['câble commande embrayage'], true),
('Émetteur d''embrayage hydraulique', 'transmission', 'embrayage', ARRAY['maître-cylindre embrayage'], true),
('Récepteur d''embrayage hydraulique', 'transmission', 'embrayage', ARRAY['cylindre récepteur embrayage'], true),
('Flexible d''embrayage hydraulique', 'transmission', 'embrayage', ARRAY['durite embrayage'], false),
('Pédale d''embrayage', 'transmission', 'pedale', ARRAY['pédale débrayage'], false),
('Contacteur de pédale d''embrayage', 'transmission', 'capteur', ARRAY['contacteur embrayage'], false),

-- Différentiel
('Différentiel avant', 'transmission', 'differentiel', ARRAY['diff AV'], false),
('Différentiel arrière', 'transmission', 'differentiel', ARRAY['diff AR', 'pont AR'], true),
('Pignon de différentiel', 'transmission', 'differentiel', ARRAY['couronne différentiel'], false),
('Satellites de différentiel', 'transmission', 'differentiel', ARRAY['planétaires diff'], false),
('Carter de différentiel', 'transmission', 'differentiel', ARRAY['coque différentiel'], false),
('Joint de carter de différentiel', 'transmission', 'joint', ARRAY['joint carter diff'], false),
('Roulement de différentiel', 'transmission', 'roulement', ARRAY['bearing différentiel'], false),
('Joint spi de différentiel', 'transmission', 'joint', ARRAY['spi sortie diff'], true),
('Différentiel autobloquant', 'transmission', 'performance', ARRAY['LSD', 'limited slip'], false),
('Kit de réparation différentiel', 'transmission', 'kit', ARRAY['kit joints différentiel'], false),

-- Pont et transmission intégrale
('Pont arrière complet', 'transmission', 'pont', ARRAY['essieu arrière'], true),
('Pont avant', 'transmission', 'pont', ARRAY['essieu avant'], false),
('Boîtier de transfert', 'transmission', '4x4', ARRAY['transfer case'], true),
('Arbre de transmission', 'transmission', 'arbre', ARRAY['arbre à cardans'], true),
('Cardan d''arbre de transmission', 'transmission', 'arbre', ARRAY['joint cardan arbre'], false),
('Palier d''arbre de transmission', 'transmission', 'arbre', ARRAY['palier central'], true),
('Soufflet d''arbre de transmission', 'transmission', 'arbre', ARRAY['soufflet protection arbre'], false),
('Coupleur Haldex', 'transmission', '4x4', ARRAY['embrayage Haldex'], false),
('Calculateur Haldex', 'transmission', 'electronique', ARRAY['ECU Haldex'], false),
('Pompe Haldex', 'transmission', '4x4', ARRAY['pompe huile Haldex'], false),
('Filtre Haldex', 'transmission', '4x4', ARRAY['filtre huile Haldex'], false),

-- Réducteur
('Réducteur de pont', 'transmission', 'reducteur', ARRAY['démultiplicateur'], false),
('Pignon d''attaque', 'transmission', 'reducteur', ARRAY['pignon conique'], false),
('Couronne de pont', 'transmission', 'reducteur', ARRAY['couronne dentée'], false),

-- Levier et timonerie
('Levier de vitesses', 'transmission', 'levier', ARRAY['pommeau vitesses'], true),
('Pommeau de levier de vitesses', 'transmission', 'levier', ARRAY['boule de levier'], true),
('Soufflet de levier de vitesses', 'transmission', 'levier', ARRAY['soufflet de protection levier'], true),
('Tringlerie de boîte de vitesses', 'transmission', 'timonerie', ARRAY['câbles sélection'], true),
('Câble de sélection de vitesses', 'transmission', 'timonerie', ARRAY['câble sélecteur'], true),
('Câble d''engagement de vitesses', 'transmission', 'timonerie', ARRAY['câble passage vitesses'], false),
('Rotule de tringlerie de boîte', 'transmission', 'timonerie', ARRAY['rotule câble BV'], false),

-- Support moteur/boîte
('Support moteur avant', 'transmission', 'support', ARRAY['support moteur AV'], true),
('Support moteur arrière', 'transmission', 'support', ARRAY['support moteur AR'], true),
('Support moteur gauche', 'transmission', 'support', ARRAY['support moteur G'], true),
('Support moteur droit', 'transmission', 'support', ARRAY['support moteur D'], true),
('Support de boîte de vitesses', 'transmission', 'support', ARRAY['support BV'], true),
('Silent-bloc de support moteur', 'transmission', 'silent-bloc', ARRAY['silent-bloc moteur'], true),
('Biellette de couple moteur', 'transmission', 'support', ARRAY['barre de couple'], false),

-- Huiles et fluides
('Huile de boîte de vitesses manuelle', 'transmission', 'fluide', ARRAY['huile BVM', '75W90'], true),
('Huile de boîte automatique', 'transmission', 'fluide', ARRAY['ATF', 'huile BVA'], true),
('Huile de pont', 'transmission', 'fluide', ARRAY['huile différentiel', '80W90'], true),
('Huile de boîtier de transfert', 'transmission', 'fluide', ARRAY['huile transfer'], false),
('Additif pour boîte automatique', 'transmission', 'fluide', ARRAY['conditionneur BVA'], false),

-- Capteurs
('Capteur de position de levier', 'transmission', 'capteur', ARRAY['capteur levier BVA'], false),
('Capteur de marche arrière', 'transmission', 'capteur', ARRAY['contacteur recul'], true),
('Capteur de point mort', 'transmission', 'capteur', ARRAY['contacteur point mort'], false),

-- Arbre de roue arrière
('Demi-arbre arrière gauche', 'transmission', 'arbre', ARRAY['demi-train AR G'], false),
('Demi-arbre arrière droit', 'transmission', 'arbre', ARRAY['demi-train AR D'], false),
('Soufflet de demi-arbre arrière', 'transmission', 'arbre', ARRAY['soufflet protection AR'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Boîte de vitesses manuelle',
  'Boîte de vitesses automatique',
  'Kit embrayage complet',
  'Disque d''embrayage',
  'Mécanisme d''embrayage',
  'Butée d''embrayage',
  'Volant moteur bi-masse',
  'Différentiel arrière',
  'Arbre de transmission',
  'Support moteur avant',
  'Levier de vitesses',
  'Huile de boîte automatique'
);
