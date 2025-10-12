-- Ajout final ultra complet de toutes les pièces manquantes

-- ========================================
-- PIÈCES DIVERSES FINALES
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Accessoires divers
('Porte-skis intérieur', 'accessoires', 'transport', ARRAY['fixation ski intérieur'], false),
('Porte-skis sur attelage', 'accessoires', 'transport', ARRAY['porte-ski attelage'], false),
('Coffre de toit 300L', 'accessoires', 'transport', ARRAY['coffre toit petit'], false),
('Coffre de toit 500L', 'accessoires', 'transport', ARRAY['coffre toit grand'], true),
('Sac de toit', 'accessoires', 'transport', ARRAY['sac souple toit'], false),
('Porte-surf', 'accessoires', 'transport', ARRAY['fixation planche'], false),
('Porte-kayak', 'accessoires', 'transport', ARRAY['fixation kayak'], false),
('Panier de toit', 'accessoires', 'transport', ARRAY['galerie panier'], false),
('Filet de coffre', 'accessoires', 'rangement', ARRAY['filet séparation coffre'], false),
('Bac de coffre sur mesure', 'accessoires', 'protection', ARRAY['tapis coffre moulé'], true),
('Organisateur de coffre pliable', 'accessoires', 'rangement', ARRAY['caisse rangement'], false),
('Sangle d''arrimage', 'accessoires', 'arrimage', ARRAY['sangle fixation'], false),
('Filet d''arrimage', 'accessoires', 'arrimage', ARRAY['filet élastique'], false),
('Crochet d''arrimage coffre', 'accessoires', 'arrimage', ARRAY['anneau fixation'], false),

-- Équipement hiver
('Chaînes neige 205', 'accessoires', 'hiver', ARRAY['chaînes 205'], true),
('Chaînes neige 215', 'accessoires', 'hiver', ARRAY['chaînes 215'], true),
('Chaussettes neige', 'accessoires', 'hiver', ARRAY['textiles neige'], true),
('Pelle à neige pliable', 'accessoires', 'hiver', ARRAY['pelle neige'], false),
('Grattoir à glace', 'accessoires', 'hiver', ARRAY['gratte-givre'], true),
('Bombe dégivrage serrure', 'accessoires', 'hiver', ARRAY['dégivrant serrure'], false),
('Liquide dégivrage -60°', 'accessoires', 'hiver', ARRAY['dégivrant pare-brise'], false),
('Housse anti-givre pare-brise', 'accessoires', 'hiver', ARRAY['protection pare-brise'], false),

-- Sécurité routière
('Triangle de présignalisation', 'accessoires', 'securite', ARRAY['triangle signalisation'], true),
('Gilet de sécurité jaune', 'accessoires', 'securite', ARRAY['gilet haute visibilité'], true),
('Gilet de sécurité orange', 'accessoires', 'securite', ARRAY['gilet fluo'], true),
('Trousse de premiers secours', 'accessoires', 'securite', ARRAY['kit secours'], true),
('Extincteur 1kg', 'accessoires', 'securite', ARRAY['extincteur auto'], true),
('Extincteur 2kg', 'accessoires', 'securite', ARRAY['extincteur voiture'], false),
('Marteau brise-vitre', 'accessoires', 'securite', ARRAY['coupe-ceinture'], false),
('Lampe de poche LED', 'accessoires', 'securite', ARRAY['torche LED'], false),
('Balise lumineuse clignotante', 'accessoires', 'securite', ARRAY['gyrophare'], false),

-- Confort conducteur
('Coussin lombaire', 'accessoires', 'confort', ARRAY['soutien lombaire'], false),
('Coussin de siège rafraîchissant', 'accessoires', 'confort', ARRAY['coussin ventilé'], false),
('Housse de volant cuir', 'accessoires', 'confort', ARRAY['couvre-volant cuir'], true),
('Housse de volant chauffante', 'accessoires', 'confort', ARRAY['volant chauffant USB'], false),
('Repose-bras universel', 'accessoires', 'confort', ARRAY['accoudoir universel'], false),
('Pare-soleil latéral', 'accessoires', 'confort', ARRAY['protection soleil vitre'], true),
('Rideau pare-soleil arrière', 'accessoires', 'confort', ARRAY['store lunette'], false),

-- Multimédia et connectivité
('Adaptateur Bluetooth audio', 'electronique', 'multimedia', ARRAY['récepteur Bluetooth'], true),
('Transmetteur FM Bluetooth', 'electronique', 'multimedia', ARRAY['adaptateur FM'], true),
('Kit mains libres Bluetooth', 'electronique', 'multimedia', ARRAY['kit Bluetooth voiture'], true),
('Support smartphone magnétique', 'accessoires', 'multimedia', ARRAY['fixation téléphone aimant'], true),
('Support smartphone grille', 'accessoires', 'multimedia', ARRAY['fixation téléphone aération'], true),
('Support smartphone pare-brise', 'accessoires', 'multimedia', ARRAY['fixation téléphone ventouse'], true),
('Chargeur USB double', 'electronique', 'multimedia', ARRAY['adaptateur USB 12V'], true),
('Chargeur sans fil voiture', 'electronique', 'multimedia', ARRAY['chargeur induction auto'], true),
('Câble auxiliaire 3.5mm', 'electronique', 'multimedia', ARRAY['câble AUX'], true),
('Caméra de tableau de bord', 'electronique', 'multimedia', ARRAY['dashcam'], true),
('Caméra double avant-arrière', 'electronique', 'multimedia', ARRAY['dashcam double'], false),

-- Entretien et outils
('Kit outils de base', 'accessoires', 'outillage', ARRAY['trousse outils'], false),
('Clé à choc', 'accessoires', 'outillage', ARRAY['clé à impact'], false),
('Clé en croix', 'accessoires', 'outillage', ARRAY['croix démonte-roue'], true),
('Chandelles 2T', 'accessoires', 'outillage', ARRAY['béquilles 2 tonnes'], false),
('Chandelles 3T', 'accessoires', 'outillage', ARRAY['béquilles 3 tonnes'], false),
('Cales de roue', 'accessoires', 'securite', ARRAY['sabots roue'], false),
('Bac de vidange', 'accessoires', 'outillage', ARRAY['récupérateur huile'], false),
('Entonnoir huile', 'accessoires', 'outillage', ARRAY['entonnoir moteur'], false),
('Clé filtre à huile', 'accessoires', 'outillage', ARRAY['clé filtre'], false),
('Pompe de vidange', 'accessoires', 'outillage', ARRAY['pompe extraction huile'], false),
('Compresseur 12V', 'accessoires', 'entretien', ARRAY['gonfleur 12V'], true),
('Manomètre pneu digital', 'accessoires', 'controle', ARRAY['jauge pression digitale'], true),
('Kit réparation pneu tubeless', 'accessoires', 'reparation', ARRAY['kit mèche'], true),
('Démonte-pneu manuel', 'accessoires', 'outillage', ARRAY['levier pneu'], false),
('Gonfleur spray anti-crevaison', 'accessoires', 'reparation', ARRAY['bombe crevaison'], true),

-- Protection et esthétique
('Film protection de peinture', 'carrosserie', 'protection', ARRAY['PPF transparent'], false),
('Covering noir mat', 'carrosserie', 'esthetique', ARRAY['film vinyle noir'], false),
('Covering carbone', 'carrosserie', 'esthetique', ARRAY['film carbone'], false),
('Baguette de protection portière', 'carrosserie', 'protection', ARRAY['protège-porte'], true),
('Protège pare-chocs avant', 'carrosserie', 'protection', ARRAY['protection pare-chocs AV'], false),
('Protège pare-chocs arrière', 'carrosserie', 'protection', ARRAY['protection pare-chocs AR'], true),
('Bande de protection seuil coffre', 'carrosserie', 'protection', ARRAY['protège seuil'], true),
('Cache plaque immatriculation', 'carrosserie', 'esthetique', ARRAY['porte-plaque'], false),
('Vis antivol plaque', 'carrosserie', 'securite', ARRAY['vis sécurité plaque'], false),

-- Climatisation et air
('Kit recharge climatisation', 'climatisation', 'entretien', ARRAY['recharge clim DIY'], true),
('Détecteur fuite climatisation', 'climatisation', 'diagnostic', ARRAY['traceur UV clim'], false),
('Huile UV traçante', 'climatisation', 'diagnostic', ARRAY['additif UV'], false),
('Bouchon de valve clim', 'climatisation', 'accessoire', ARRAY['capuchon valve AC'], false),
('Robinet de service clim', 'climatisation', 'entretien', ARRAY['valve recharge'], false),

-- Consommables spéciaux
('Plaquettes frein céramique avant', 'freinage', 'performance', ARRAY['plaquettes céramique AV'], false),
('Plaquettes frein céramique arrière', 'freinage', 'performance', ARRAY['plaquettes céramique AR'], false),
('Disques frein carbone avant', 'freinage', 'performance', ARRAY['disques carbone AV'], false),
('Disques frein carbone arrière', 'freinage', 'performance', ARRAY['disques carbone AR'], false),
('Liquide frein haute performance', 'freinage', 'performance', ARRAY['DOT 5.1 racing'], false),
('Huile moteur compétition', 'moteur', 'performance', ARRAY['huile racing'], false),
('Essence compétition', 'carburant', 'performance', ARRAY['essence racing'], false),

-- Électrique spécifique
('Prolongateur de charge Type 2', 'electricite', 'accessoire', ARRAY['rallonge charge'], false),
('Câble de charge domestique', 'electricite', 'accessoire', ARRAY['câble 220V'], true),
('Wallbox 7kW', 'electricite', 'charge', ARRAY['borne murale 7kW'], true),
('Wallbox 11kW', 'electricite', 'charge', ARRAY['borne murale 11kW'], true),
('Wallbox 22kW', 'electricite', 'charge', ARRAY['borne murale 22kW'], false),
('Adaptateur Type 2 vers Type 1', 'electricite', 'accessoire', ARRAY['adaptateur charge'], false),
('Protection batterie 12V auxiliaire', 'electricite', 'protection', ARRAY['isolateur batterie'], false)

ON CONFLICT (name) DO NOTHING;
