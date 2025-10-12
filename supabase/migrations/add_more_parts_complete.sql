-- Ajout de pièces supplémentaires pour compléter le catalogue

-- ========================================
-- SUSPENSION (pièces détaillées)
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Barre stabilisatrice avant', 'suspension', 'mecanique', ARRAY['barre anti-roulis AV'], true),
('Barre stabilisatrice arrière', 'suspension', 'mecanique', ARRAY['barre anti-roulis AR'], true),
('Biellette de barre stabilisatrice', 'suspension', 'liaison', ARRAY['biellette anti-roulis'], true),
('Bras de suspension avant', 'suspension', 'mecanique', ARRAY['triangle AV'], true),
('Bras de suspension arrière', 'suspension', 'mecanique', ARRAY['triangle AR'], true),
('Butée de suspension', 'suspension', 'amortissement', ARRAY['tampon suspension'], false),
('Coupelle d''amortisseur', 'suspension', 'fixation', ARRAY['support amortisseur'], true),
('Kit de rehausse', 'suspension', 'modification', ARRAY['kit surélévation'], false),
('Palier de roue', 'suspension', 'roulement', ARRAY['moyeu roue'], true),
('Ressort de suspension avant', 'suspension', 'amortissement', ARRAY['ressort AV'], true),
('Ressort de suspension arrière', 'suspension', 'amortissement', ARRAY['ressort AR'], true),
('Rotule de suspension', 'suspension', 'liaison', ARRAY['rotule triangle'], true),
('Silent-bloc de bras', 'suspension', 'liaison', ARRAY['silent-bloc triangle'], true),
('Support de combiné fileté', 'suspension', 'fixation', ARRAY['support coilover'], false),
('Traverse avant', 'suspension', 'structure', ARRAY['berceau AV'], false),
('Traverse arrière', 'suspension', 'structure', ARRAY['berceau AR'], false),

-- ========================================
-- DIRECTION (pièces complètes)
-- ========================================
('Biellette de direction', 'direction', 'mecanique', ARRAY['bielle direction'], true),
('Colonne de direction', 'direction', 'mecanique', ARRAY['arbre direction'], true),
('Crémaillère de direction', 'direction', 'mecanique', ARRAY['boîtier direction'], true),
('Flexible de direction assistée', 'direction', 'hydraulique', ARRAY['durite DA'], false),
('Joint de cardan de direction', 'direction', 'liaison', ARRAY['cardan colonne'], false),
('Liquide de direction assistée', 'direction', 'fluide', ARRAY['huile DA'], false),
('Pompe de direction assistée', 'direction', 'hydraulique', ARRAY['pompe DA'], true),
('Réservoir de direction assistée', 'direction', 'hydraulique', ARRAY['vase DA'], false),
('Rotule de direction', 'direction', 'liaison', ARRAY['rotule axiale'], true),
('Soufflet de crémaillère', 'direction', 'protection', ARRAY['soufflet direction'], true),
('Support de crémaillère', 'direction', 'fixation', ARRAY['silent-bloc crémaillère'], false),
('Timonerie de direction', 'direction', 'mecanique', ARRAY['tringlerie'], false),

-- ========================================
-- ROUES ET PNEUMATIQUES
-- ========================================
('Bouchon de valve', 'roues', 'accessoire', ARRAY['capuchon valve'], false),
('Cache moyeu', 'roues', 'esthetique', ARRAY['cache centre roue'], false),
('Écrou antivol', 'roues', 'securite', ARRAY['écrou de roue sécurisé'], true),
('Écrou de roue', 'roues', 'fixation', ARRAY['boulon roue'], true),
('Enjoliveur de roue', 'roues', 'esthetique', ARRAY['enjoliveur'], false),
('Jante acier', 'roues', 'structure', ARRAY['jante tôle'], true),
('Jante alliage', 'roues', 'structure', ARRAY['jante alu'], true),
('Kit de réparation pneu', 'roues', 'reparation', ARRAY['kit anti-crevaison'], false),
('Pneumatique avant', 'roues', 'pneu', ARRAY['pneu AV'], true),
('Pneumatique arrière', 'roues', 'pneu', ARRAY['pneu AR'], true),
('Roue de secours', 'roues', 'securite', ARRAY['galette'], true),
('Valve de roue', 'roues', 'accessoire', ARRAY['valve pneu'], false),

-- ========================================
-- CLIMATISATION (pièces détaillées)
-- ========================================
('Bouteille déshydratante', 'climatisation', 'traitement', ARRAY['filtre déshydrateur'], true),
('Capteur de température d''habitacle', 'climatisation', 'regulation', ARRAY['sonde température'], false),
('Commande de climatisation', 'climatisation', 'commande', ARRAY['bouton clim'], false),
('Compresseur de climatisation', 'climatisation', 'compression', ARRAY['compresseur AC'], true),
('Condenseur de climatisation', 'climatisation', 'echange', ARRAY['radiateur clim'], true),
('Détendeur de climatisation', 'climatisation', 'regulation', ARRAY['valve détente'], false),
('Évaporateur de climatisation', 'climatisation', 'echange', ARRAY['évapo'], true),
('Filtre d''habitacle', 'climatisation', 'filtration', ARRAY['filtre à pollen'], true),
('Gaz réfrigérant', 'climatisation', 'fluide', ARRAY['R134a', 'R1234yf'], false),
('Mano-détendeur', 'climatisation', 'diagnostic', ARRAY['manomètre'], false),
('Poulie de compresseur', 'climatisation', 'transmission', ARRAY['poulie AC'], false),
('Pressostat de climatisation', 'climatisation', 'regulation', ARRAY['capteur pression'], false),
('Sonde de température évaporateur', 'climatisation', 'regulation', ARRAY['capteur évapo'], false),
('Tuyau haute pression clim', 'climatisation', 'circulation', ARRAY['durite HP'], false),
('Tuyau basse pression clim', 'climatisation', 'circulation', ARRAY['durite BP'], false),
('Ventilateur de climatisation', 'climatisation', 'ventilation', ARRAY['pulseur clim'], true),

-- ========================================
-- ÉCHAPPEMENT (pièces complètes)
-- ========================================
('Bride d''échappement', 'echappement', 'fixation', ARRAY['collier échappement'], false),
('Catalyseur', 'echappement', 'depollution', ARRAY['pot catalytique'], true),
('Collecteur d''échappement', 'echappement', 'evacuation', ARRAY['collecteur'], true),
('Embout d''échappement', 'echappement', 'sortie', ARRAY['sortie échappement'], false),
('Filtre à particules FAP', 'echappement', 'depollution', ARRAY['DPF'], true),
('Joint de collecteur', 'echappement', 'etancheite', ARRAY['joint manifold'], false),
('Ligne d''échappement complète', 'echappement', 'systeme', ARRAY['ligne complète'], true),
('Pâte d''échappement', 'echappement', 'reparation', ARRAY['mastic échappement'], false),
('Sonde lambda amont', 'echappement', 'mesure', ARRAY['sonde O2 avant'], true),
('Sonde lambda aval', 'echappement', 'mesure', ARRAY['sonde O2 après'], true),
('Silencieux arrière', 'echappement', 'acoustique', ARRAY['pot arrière'], true),
('Silencieux intermédiaire', 'echappement', 'acoustique', ARRAY['pot central'], false),
('Support d''échappement', 'echappement', 'fixation', ARRAY['silent-bloc échappement'], false),
('Tube intermédiaire', 'echappement', 'evacuation', ARRAY['tube central'], false),
('Vanne EGR', 'echappement', 'recirculation', ARRAY['valve EGR'], true),

-- ========================================
-- ÉCLAIRAGE (pièces détaillées)
-- ========================================
('Ampoule H1', 'eclairage', 'source', ARRAY['lampe H1'], true),
('Ampoule H4', 'eclairage', 'source', ARRAY['lampe H4'], true),
('Ampoule H7', 'eclairage', 'source', ARRAY['lampe H7'], true),
('Ballast xénon', 'eclairage', 'alimentation', ARRAY['module xénon'], false),
('Bloc optique avant droit', 'eclairage', 'optique', ARRAY['phare AV D'], true),
('Bloc optique avant gauche', 'eclairage', 'optique', ARRAY['phare AV G'], true),
('Cabochon de feu', 'eclairage', 'protection', ARRAY['glace feu'], false),
('Caméra de recul', 'eclairage', 'aide', ARRAY['caméra arrière'], true),
('Éclairage de plaque', 'eclairage', 'signalisation', ARRAY['feu plaque'], false),
('Feu antibrouillard avant droit', 'eclairage', 'brouillard', ARRAY['antibrouillard AV D'], false),
('Feu antibrouillard avant gauche', 'eclairage', 'brouillard', ARRAY['antibrouillard AV G'], false),
('Feu antibrouillard arrière', 'eclairage', 'brouillard', ARRAY['antibrouillard AR'], false),
('Feu arrière droit', 'eclairage', 'signalisation', ARRAY['feu AR D'], true),
('Feu arrière gauche', 'eclairage', 'signalisation', ARRAY['feu AR G'], true),
('Feu de recul', 'eclairage', 'signalisation', ARRAY['feu marche arrière'], false),
('Feu de stop additionnel', 'eclairage', 'signalisation', ARRAY['3ème stop'], false),
('Kit LED', 'eclairage', 'modification', ARRAY['éclairage LED'], false),
('Kit xénon', 'eclairage', 'modification', ARRAY['kit HID'], false),
('Lentille de phare', 'eclairage', 'optique', ARRAY['glace phare'], false),
('Module LED', 'eclairage', 'source', ARRAY['ampoule LED'], true),
('Projecteur antibrouillard', 'eclairage', 'brouillard', ARRAY['phare brouillard'], false),
('Réflecteur de phare', 'eclairage', 'optique', ARRAY['cuvette phare'], false),

-- ========================================
-- ÉLECTRICITÉ (pièces détaillées)
-- ========================================
('Alternateur', 'electricite', 'charge', ARRAY['génératrice'], true),
('Batterie', 'electricite', 'stockage', ARRAY['accumulateur'], true),
('Boîtier de préchauffage', 'electricite', 'demarrage', ARRAY['relais bougies'], false),
('Bougie d''allumage', 'electricite', 'allumage', ARRAY['bougie'], true),
('Bougie de préchauffage', 'electricite', 'demarrage', ARRAY['bougie diesel'], true),
('Câble de batterie', 'electricite', 'liaison', ARRAY['cosse batterie'], false),
('Câble de démarreur', 'electricite', 'demarrage', ARRAY['fil démarreur'], false),
('Capteur ABS', 'electricite', 'freinage', ARRAY['capteur roue'], true),
('Capteur d''arbre à cames', 'electricite', 'gestion moteur', ARRAY['capteur AAC'], true),
('Capteur de pression d''huile', 'electricite', 'mesure', ARRAY['mano huile'], false),
('Capteur de régime moteur', 'electricite', 'gestion moteur', ARRAY['capteur PMH'], true),
('Capteur de température d''eau', 'electricite', 'mesure', ARRAY['sonde température'], true),
('Capteur MAP', 'electricite', 'gestion moteur', ARRAY['capteur pression admission'], false),
('Capteur papillon', 'electricite', 'gestion moteur', ARRAY['potentiomètre papillon'], false),
('Chargeur de batterie', 'electricite', 'entretien', ARRAY['mainteneur charge'], false),
('Cosse de batterie', 'electricite', 'connexion', ARRAY['borne batterie'], false),
('Démarreur', 'electricite', 'demarrage', ARRAY['lanceur'], true),
('Débitmètre d''air', 'electricite', 'mesure', ARRAY['MAF'], true),
('Faisceau d''allumage', 'electricite', 'allumage', ARRAY['câbles bougies'], false),
('Faisceau de moteur', 'electricite', 'cablage', ARRAY['faisceau électrique moteur'], false),
('Fusible', 'electricite', 'protection', ARRAY['coupe-circuit'], true),
('Klaxon', 'electricite', 'signalisation', ARRAY['avertisseur'], false),
('Lève-vitre électrique avant droit', 'electricite', 'confort', ARRAY['moteur vitre AV D'], true),
('Lève-vitre électrique avant gauche', 'electricite', 'confort', ARRAY['moteur vitre AV G'], true),
('Lève-vitre électrique arrière droit', 'electricite', 'confort', ARRAY['moteur vitre AR D'], false),
('Lève-vitre électrique arrière gauche', 'electricite', 'confort', ARRAY['moteur vitre AR G'], false),
('Moteur d''essuie-glace avant', 'electricite', 'nettoyage', ARRAY['moteur essuie-glace AV'], true),
('Moteur d''essuie-glace arrière', 'electricite', 'nettoyage', ARRAY['moteur essuie-glace AR'], false),
('Pompe de lave-glace', 'electricite', 'nettoyage', ARRAY['pompe lave-vitre'], false),
('Poulie d''alternateur', 'electricite', 'transmission', ARRAY['poulie génératrice'], false),
('Régulateur d''alternateur', 'electricite', 'regulation', ARRAY['régulateur tension'], false),
('Relais', 'electricite', 'commande', ARRAY['contacteur électrique'], false),
('Solénoïde de démarreur', 'electricite', 'demarrage', ARRAY['contacteur démarreur'], false),

-- ========================================
-- VITRAGE (pièces complètes)
-- ========================================
('Custode arrière droite', 'vitrage', 'vitre', ARRAY['vitre latérale AR D'], false),
('Custode arrière gauche', 'vitrage', 'vitre', ARRAY['vitre latérale AR G'], false),
('Joint de pare-brise', 'vitrage', 'etancheite', ARRAY['joint windshield'], true),
('Joint de vitre de porte', 'vitrage', 'etancheite', ARRAY['joint lève-vitre'], false),
('Lunette arrière', 'vitrage', 'vitre', ARRAY['vitre AR'], true),
('Mécanisme de lève-vitre avant droit', 'vitrage', 'mecanique', ARRAY['lève-vitre manuel AV D'], false),
('Mécanisme de lève-vitre avant gauche', 'vitrage', 'mecanique', ARRAY['lève-vitre manuel AV G'], false),
('Pare-brise', 'vitrage', 'vitre', ARRAY['windshield'], true),
('Toit ouvrant', 'vitrage', 'confort', ARRAY['sunroof'], true),
('Vitre de custode', 'vitrage', 'vitre', ARRAY['triangle vitre'], false),
('Vitre de porte avant droite', 'vitrage', 'vitre', ARRAY['vitre AV D'], true),
('Vitre de porte avant gauche', 'vitrage', 'vitre', ARRAY['vitre AV G'], true),
('Vitre de porte arrière droite', 'vitrage', 'vitre', ARRAY['vitre AR D'], true),
('Vitre de porte arrière gauche', 'vitrage', 'vitre', ARRAY['vitre AR G'], true),

-- ========================================
-- ACCESSOIRES ET ÉQUIPEMENTS
-- ========================================
('Antenne radio', 'accessoires', 'communication', ARRAY['antenne FM'], false),
('Attelage', 'accessoires', 'remorquage', ARRAY['boule attelage'], true),
('Bac de coffre', 'accessoires', 'protection', ARRAY['tapis coffre'], false),
('Barres de toit', 'accessoires', 'transport', ARRAY['galerie'], true),
('Chaînes à neige', 'accessoires', 'securite', ARRAY['chaînes'], false),
('Cric', 'accessoires', 'outillage', ARRAY['vérin'], false),
('Déflecteur de capot', 'accessoires', 'protection', ARRAY['protège capot'], false),
('Déflecteur de toit', 'accessoires', 'aero', ARRAY['spoiler toit'], false),
('Extincteur', 'accessoires', 'securite', ARRAY['extincteur auto'], false),
('Housse de siège', 'accessoires', 'protection', ARRAY['couvre siège'], false),
('Porte-vélos', 'accessoires', 'transport', ARRAY['support vélo'], false),
('Tapis de sol', 'accessoires', 'protection', ARRAY['moquette'], true),
('Triangle de signalisation', 'accessoires', 'securite', ARRAY['triangle'], false),
('Trousse de secours', 'accessoires', 'securite', ARRAY['kit premiers soins'], false),

-- ========================================
-- CARBURANT ET INJECTION
-- ========================================
('Bouchon de réservoir', 'carburant', 'fermeture', ARRAY['bouchon essence'], true),
('Calculateur d''injection', 'carburant', 'gestion', ARRAY['ECU'], true),
('Canalisation de carburant', 'carburant', 'alimentation', ARRAY['durite essence'], false),
('Filtre à carburant', 'carburant', 'filtration', ARRAY['filtre essence'], true),
('Injecteur diesel', 'carburant', 'injection', ARRAY['injecteur gasoil'], true),
('Injecteur essence', 'carburant', 'injection', ARRAY['injecteur'], true),
('Jauge à carburant', 'carburant', 'mesure', ARRAY['sonde niveau essence'], true),
('Pompe à carburant', 'carburant', 'alimentation', ARRAY['pompe essence'], true),
('Pompe d''amorçage diesel', 'carburant', 'alimentation', ARRAY['pompe gavage'], false),
('Rampe d''injection', 'carburant', 'distribution', ARRAY['rail injection'], true),
('Réservoir de carburant', 'carburant', 'stockage', ARRAY['réservoir essence'], true),
('Robinet d''essence', 'carburant', 'regulation', ARRAY['vanne essence'], false),
('Trappe à carburant', 'carburant', 'acces', ARRAY['volet essence'], true),
('Vanne de carburant', 'carburant', 'regulation', ARRAY['électrovanne'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts
SET is_popular = true
WHERE name IN (
  -- Suspension
  'Barre stabilisatrice avant',
  'Barre stabilisatrice arrière',
  'Biellette de barre stabilisatrice',
  'Bras de suspension avant',
  'Bras de suspension arrière',
  'Coupelle d''amortisseur',
  'Palier de roue',
  'Ressort de suspension avant',
  'Ressort de suspension arrière',
  'Rotule de suspension',
  'Silent-bloc de bras',

  -- Direction
  'Biellette de direction',
  'Colonne de direction',
  'Crémaillère de direction',
  'Pompe de direction assistée',
  'Rotule de direction',
  'Soufflet de crémaillère',

  -- Roues
  'Écrou antivol',
  'Écrou de roue',
  'Jante acier',
  'Jante alliage',
  'Pneumatique avant',
  'Pneumatique arrière',
  'Roue de secours',

  -- Climatisation
  'Bouteille déshydratante',
  'Compresseur de climatisation',
  'Condenseur de climatisation',
  'Évaporateur de climatisation',
  'Filtre d''habitacle',
  'Ventilateur de climatisation',

  -- Échappement
  'Catalyseur',
  'Collecteur d''échappement',
  'Filtre à particules FAP',
  'Ligne d''échappement complète',
  'Sonde lambda amont',
  'Sonde lambda aval',
  'Silencieux arrière',
  'Vanne EGR',

  -- Éclairage
  'Ampoule H1',
  'Ampoule H4',
  'Ampoule H7',
  'Bloc optique avant droit',
  'Bloc optique avant gauche',
  'Caméra de recul',
  'Feu arrière droit',
  'Feu arrière gauche',
  'Module LED',

  -- Électricité
  'Alternateur',
  'Batterie',
  'Bougie d''allumage',
  'Bougie de préchauffage',
  'Capteur ABS',
  'Capteur d''arbre à cames',
  'Capteur de régime moteur',
  'Capteur de température d''eau',
  'Démarreur',
  'Débitmètre d''air',
  'Fusible',
  'Lève-vitre électrique avant droit',
  'Lève-vitre électrique avant gauche',
  'Moteur d''essuie-glace avant',

  -- Vitrage
  'Joint de pare-brise',
  'Lunette arrière',
  'Pare-brise',
  'Toit ouvrant',
  'Vitre de porte avant droite',
  'Vitre de porte avant gauche',
  'Vitre de porte arrière droite',
  'Vitre de porte arrière gauche',

  -- Accessoires
  'Attelage',
  'Barres de toit',
  'Tapis de sol',

  -- Carburant
  'Bouchon de réservoir',
  'Calculateur d''injection',
  'Filtre à carburant',
  'Injecteur diesel',
  'Injecteur essence',
  'Jauge à carburant',
  'Pompe à carburant',
  'Rampe d''injection',
  'Réservoir de carburant',
  'Trappe à carburant'
);
