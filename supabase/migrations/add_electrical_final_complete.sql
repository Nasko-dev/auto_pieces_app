-- Ajout final complet des pièces électriques et électroniques

-- ========================================
-- ÉLECTRICITÉ & DÉMARRAGE (ultra complet)
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Alternateur', 'electricite', 'charge', ARRAY['générateur'], true),
('Alternateur reconditionné', 'electricite', 'charge', ARRAY['alternateur échange standard'], true),
('Poulie d''alternateur', 'electricite', 'transmission', ARRAY['poulie génératrice'], false),
('Régulateur d''alternateur', 'electricite', 'regulation', ARRAY['régulateur tension'], false),
('Démarreur', 'electricite', 'demarrage', ARRAY['lanceur'], true),
('Démarreur reconditionné', 'electricite', 'demarrage', ARRAY['démarreur échange standard'], true),
('Solénoïde de démarreur', 'electricite', 'demarrage', ARRAY['contacteur démarreur'], false),
('Pignon de démarreur', 'electricite', 'demarrage', ARRAY['bendix'], false),
('Batterie', 'electricite', 'stockage', ARRAY['accumulateur'], true),
('Batterie 12V', 'electricite', 'stockage', ARRAY['batterie 12 volts'], true),
('Batterie START-STOP', 'electricite', 'stockage', ARRAY['batterie AGM'], true),
('Câble batterie positif', 'electricite', 'liaison', ARRAY['câble plus batterie'], true),
('Câble batterie négatif', 'electricite', 'liaison', ARRAY['câble masse batterie'], true),
('Câble de masse moteur', 'electricite', 'liaison', ARRAY['tresse masse'], true),
('Support batterie', 'electricite', 'fixation', ARRAY['fixation batterie'], false),
('Fusible principal', 'electricite', 'protection', ARRAY['fusible batterie'], true),
('Calculateur moteur ECU', 'electronique', 'gestion moteur', ARRAY['boîtier injection'], true),
('Calculateur reprogrammé', 'electronique', 'performance', ARRAY['ECU mappé'], false),
('Relais de préchauffage', 'electricite', 'demarrage', ARRAY['boîtier préchauffage diesel'], true),
('Bougie d''allumage essence', 'electricite', 'allumage', ARRAY['spark plug'], true),
('Bougie de préchauffage diesel', 'electricite', 'demarrage', ARRAY['bougie diesel'], true),
('Bobine d''allumage', 'electricite', 'allumage', ARRAY['transformateur allumage'], true),
('Bobine crayon individuelle', 'electricite', 'allumage', ARRAY['bobine crayon'], true),
('Faisceau d''allumage', 'electricite', 'allumage', ARRAY['câbles haute tension'], true),
('Câbles de bougies', 'electricite', 'allumage', ARRAY['fils haute tension'], true),
('Relais démarreur', 'electricite', 'commande', ARRAY['relais contacteur démarreur'], false),
('Relais injection', 'electricite', 'commande', ARRAY['relais pompe carburant'], false),
('Faisceau moteur principal', 'electricite', 'cablage', ARRAY['câblage moteur complet'], true),
('Connecteurs moteur', 'electricite', 'connexion', ARRAY['prises électriques moteur'], false),
('Faisceau de porte moteur', 'electricite', 'cablage', ARRAY['passage porte moteur'], false),

-- ========================================
-- CAPTEURS MOTEUR (complet)
-- ========================================
('Capteur vilebrequin PMH', 'electricite', 'mesure', ARRAY['capteur régime'], true),
('Capteur arbre à cames', 'electricite', 'mesure', ARRAY['capteur AAC'], true),
('Capteur de cliquetis', 'electricite', 'mesure', ARRAY['knock sensor'], true),
('Capteur de température eau', 'electricite', 'mesure', ARRAY['sonde température liquide'], true),
('Capteur de pression huile', 'electricite', 'mesure', ARRAY['manocontact huile'], true),
('Capteur de pression admission', 'electricite', 'mesure', ARRAY['MAP sensor'], true),
('Capteur PMH', 'electricite', 'mesure', ARRAY['capteur point mort haut'], true),
('Capteur pédale accélérateur', 'electricite', 'mesure', ARRAY['potentiomètre pédale'], true),
('Capteur pédale embrayage', 'electricite', 'mesure', ARRAY['contacteur pédale embrayage'], false),
('Sonde lambda amont', 'electricite', 'mesure', ARRAY['sonde O2 avant'], true),
('Sonde lambda aval', 'electricite', 'mesure', ARRAY['sonde O2 arrière'], true),
('Actionneur ralenti', 'electricite', 'regulation', ARRAY['IAC valve'], false),
('Capteur niveau huile', 'electricite', 'mesure', ARRAY['sonde niveau huile moteur'], false),
('Capteur température air admission', 'electricite', 'mesure', ARRAY['IAT sensor'], true),
('Capteur de pression turbo', 'electricite', 'mesure', ARRAY['MAP turbo'], false),

-- ========================================
-- ÉLECTRONIQUE DE GESTION (avancé)
-- ========================================
('Boîtier fusibles compartiment moteur', 'electronique', 'distribution', ARRAY['boîte fusibles moteur'], true),
('Boîtier fusibles habitacle', 'electronique', 'distribution', ARRAY['boîte fusibles intérieur'], true),
('Relais de ventilateur', 'electronique', 'commande', ARRAY['relais motoventilateur'], false),
('Module de commande pompe carburant', 'electronique', 'gestion', ARRAY['relais pompe essence'], false),
('Module ABS ESP', 'electronique', 'securite', ARRAY['calculateur ABS'], true),
('Faisceau moteur complet', 'electricite', 'cablage', ARRAY['câblage électrique moteur'], true),
('Faisceau boîte de vitesses', 'electricite', 'cablage', ARRAY['câblage BV'], false),
('Relais principaux moteur', 'electronique', 'commande', ARRAY['relais alimentation'], false),
('Boîtier électronique gestion moteur', 'electronique', 'gestion', ARRAY['ECM'], true),
('Unité de commande turbo', 'electronique', 'turbo', ARRAY['actuateur turbo électrique'], false),
('Boîtier papillon électrique', 'electronique', 'admission', ARRAY['throttle body électronique'], true),
('Capteur MAP MAF', 'electricite', 'mesure', ARRAY['débitmètre air'], true),
('Capteur de température air', 'electricite', 'mesure', ARRAY['sonde air admission'], false),
('Module de préchauffage', 'electronique', 'demarrage', ARRAY['unité préchauffage'], false),
('Calculateur injection diesel', 'electronique', 'gestion', ARRAY['ECU diesel'], true),
('Calculateur injection essence', 'electronique', 'gestion', ARRAY['ECU essence'], true),

-- ========================================
-- ÉQUIPEMENTS ÉLECTRIQUES DIVERS
-- ========================================
('Contacteur de démarrage', 'electricite', 'commande', ARRAY['neiman'], true),
('Antidémarrage transpondeur', 'electronique', 'securite', ARRAY['immobiliseur'], true),
('Clé avec transpondeur', 'electronique', 'securite', ARRAY['clé codée'], true),
('Lecteur de clé', 'electronique', 'securite', ARRAY['antenne transpondeur'], false),
('Module confort BSI', 'electronique', 'gestion', ARRAY['boîtier servitude'], true),
('Unité centrale habitacle', 'electronique', 'gestion', ARRAY['UCH'], true),
('Boîtier de jonction', 'electronique', 'distribution', ARRAY['boîte jonction électrique'], false),
('Disjoncteur principal', 'electricite', 'protection', ARRAY['coupe-circuit'], false),
('Shunt de mesure batterie', 'electricite', 'mesure', ARRAY['capteur courant batterie'], false),
('Chargeur de batterie embarqué', 'electricite', 'charge', ARRAY['onduleur batterie'], false),

-- ========================================
-- ÉCLAIRAGE & SIGNALISATION (électrique)
-- ========================================
('Contacteur feux stop', 'electricite', 'commande', ARRAY['contacteur pédale frein'], true),
('Interrupteur feux de recul', 'electricite', 'commande', ARRAY['contacteur marche arrière'], false),
('Centrale clignotante', 'electricite', 'commande', ARRAY['relais clignotants'], false),
('Module éclairage adaptatif', 'electronique', 'eclairage', ARRAY['AFS module'], false),
('Capteur de pluie pare-brise', 'electronique', 'confort', ARRAY['détecteur pluie'], true),
('Capteur de luminosité', 'electronique', 'confort', ARRAY['cellule photoélectrique'], true),
('Correcteur de phare moteur', 'electricite', 'eclairage', ARRAY['vérin phare'], true),
('Ballast xénon gauche', 'electricite', 'eclairage', ARRAY['ballast G'], false),
('Ballast xénon droit', 'electricite', 'eclairage', ARRAY['ballast D'], false),
('Ampoule xénon D1S', 'eclairage', 'source', ARRAY['lampe xénon D1S'], false),
('Ampoule xénon D2S', 'eclairage', 'source', ARRAY['lampe xénon D2S'], false),
('Ampoule xénon D3S', 'eclairage', 'source', ARRAY['lampe xénon D3S'], false),

-- ========================================
-- CONFORT & ACCESSOIRES ÉLECTRIQUES
-- ========================================
('Moteur lève-vitre avant gauche', 'electricite', 'confort', ARRAY['moteur vitre AV G'], true),
('Moteur lève-vitre avant droit', 'electricite', 'confort', ARRAY['moteur vitre AV D'], true),
('Moteur lève-vitre arrière gauche', 'electricite', 'confort', ARRAY['moteur vitre AR G'], false),
('Moteur lève-vitre arrière droit', 'electricite', 'confort', ARRAY['moteur vitre AR D'], false),
('Mécanisme lève-vitre avant gauche', 'electricite', 'confort', ARRAY['lève-vitre électrique AV G'], true),
('Mécanisme lève-vitre avant droit', 'electricite', 'confort', ARRAY['lève-vitre électrique AV D'], true),
('Interrupteur lève-vitre avant gauche', 'electricite', 'commande', ARRAY['bouton vitre AV G'], false),
('Interrupteur lève-vitre avant droit', 'electricite', 'commande', ARRAY['bouton vitre AV D'], false),
('Moteur essuie-glace avant', 'electricite', 'nettoyage', ARRAY['moteur balai AV'], true),
('Moteur essuie-glace arrière', 'electricite', 'nettoyage', ARRAY['moteur balai AR'], true),
('Pompe lave-glace', 'electricite', 'nettoyage', ARRAY['pompe gicleur'], true),
('Commodo gauche', 'electricite', 'commande', ARRAY['commande clignotants'], true),
('Commodo droit', 'electricite', 'commande', ARRAY['commande essuie-glace'], true),
('Commandes au volant', 'electronique', 'commande', ARRAY['boutons volant'], true),
('Module régulateur de vitesse', 'electronique', 'aide', ARRAY['cruise control'], true),
('Moteur de rétroviseur gauche', 'electricite', 'confort', ARRAY['actionneur rétro G'], true),
('Moteur de rétroviseur droit', 'electricite', 'confort', ARRAY['actionneur rétro D'], true),
('Résistance dégivrage rétroviseur', 'electricite', 'confort', ARRAY['chauffage rétro'], false),
('Résistance dégivrage lunette', 'electricite', 'confort', ARRAY['fils chauffants lunette AR'], true),

-- ========================================
-- CLIMATISATION ÉLECTRIQUE
-- ========================================
('Résistance pulseur habitacle', 'electricite', 'climatisation', ARRAY['résistance ventilation'], true),
('Moteur pulseur habitacle', 'electricite', 'climatisation', ARRAY['ventilateur habitacle'], true),
('Relais compresseur clim', 'electricite', 'climatisation', ARRAY['relais AC'], false),
('Capteur température habitacle', 'electronique', 'climatisation', ARRAY['sonde température intérieur'], false),
('Capteur ensoleillement', 'electronique', 'climatisation', ARRAY['capteur soleil'], false),
('Pressostat climatisation', 'electricite', 'climatisation', ARRAY['capteur pression clim'], false),
('Sonde évaporateur', 'electricite', 'climatisation', ARRAY['capteur température évapo'], false),

-- ========================================
-- SÉCURITÉ & AIRBAGS (électrique)
-- ========================================
('Contacteur tournant airbag', 'electricite', 'securite', ARRAY['spirale airbag'], true),
('Prétensionneur ceinture gauche', 'electricite', 'securite', ARRAY['prétensionneur G'], true),
('Prétensionneur ceinture droit', 'electricite', 'securite', ARRAY['prétensionneur D'], true),
('Capteur choc avant gauche', 'electronique', 'securite', ARRAY['capteur impact AV G'], false),
('Capteur choc avant droit', 'electronique', 'securite', ARRAY['capteur impact AV D'], false),
('Capteur choc latéral gauche', 'electronique', 'securite', ARRAY['capteur impact lat G'], false),
('Capteur choc latéral droit', 'electronique', 'securite', ARRAY['capteur impact lat D'], false),
('Centrale airbag', 'electronique', 'securite', ARRAY['calculateur airbag'], true),
('Faisceau airbag', 'electricite', 'cablage', ARRAY['câblage airbags'], false),

-- ========================================
-- AUDIO & MULTIMÉDIA
-- ========================================
('Autoradio', 'electronique', 'multimedia', ARRAY['poste radio'], true),
('Écran tactile multimédia', 'electronique', 'multimedia', ARRAY['écran central'], true),
('Amplificateur audio', 'electronique', 'audio', ARRAY['ampli'], false),
('Antenne radio toit', 'electronique', 'multimedia', ARRAY['antenne FM'], false),
('Microphone mains-libres', 'electronique', 'multimedia', ARRAY['micro Bluetooth'], false)

ON CONFLICT (name) DO NOTHING;

-- Marquer toutes les pièces populaires
UPDATE public.parts
SET is_popular = true
WHERE name IN (
  'Alternateur',
  'Alternateur reconditionné',
  'Démarreur',
  'Démarreur reconditionné',
  'Batterie',
  'Batterie 12V',
  'Batterie START-STOP',
  'Câble batterie positif',
  'Câble batterie négatif',
  'Câble de masse moteur',
  'Fusible principal',
  'Calculateur moteur ECU',
  'Relais de préchauffage',
  'Bougie d''allumage essence',
  'Bougie de préchauffage diesel',
  'Bobine d''allumage',
  'Bobine crayon individuelle',
  'Faisceau d''allumage',
  'Câbles de bougies',
  'Faisceau moteur principal',
  'Capteur vilebrequin PMH',
  'Capteur arbre à cames',
  'Capteur de cliquetis',
  'Capteur de température eau',
  'Capteur de pression huile',
  'Capteur de pression admission',
  'Capteur PMH',
  'Capteur pédale accélérateur',
  'Sonde lambda amont',
  'Sonde lambda aval',
  'Capteur température air admission',
  'Boîtier fusibles compartiment moteur',
  'Boîtier fusibles habitacle',
  'Module ABS ESP',
  'Faisceau moteur complet',
  'Boîtier électronique gestion moteur',
  'Boîtier papillon électrique',
  'Capteur MAP MAF',
  'Calculateur injection diesel',
  'Calculateur injection essence',
  'Contacteur de démarrage',
  'Antidémarrage transpondeur',
  'Clé avec transpondeur',
  'Module confort BSI',
  'Unité centrale habitacle',
  'Contacteur feux stop',
  'Capteur de pluie pare-brise',
  'Capteur de luminosité',
  'Correcteur de phare moteur',
  'Moteur lève-vitre avant gauche',
  'Moteur lève-vitre avant droit',
  'Mécanisme lève-vitre avant gauche',
  'Mécanisme lève-vitre avant droit',
  'Moteur essuie-glace avant',
  'Moteur essuie-glace arrière',
  'Pompe lave-glace',
  'Commodo gauche',
  'Commodo droit',
  'Commandes au volant',
  'Module régulateur de vitesse',
  'Moteur de rétroviseur gauche',
  'Moteur de rétroviseur droit',
  'Résistance dégivrage lunette',
  'Résistance pulseur habitacle',
  'Moteur pulseur habitacle',
  'Contacteur tournant airbag',
  'Prétensionneur ceinture gauche',
  'Prétensionneur ceinture droit',
  'Centrale airbag',
  'Autoradio',
  'Écran tactile multimédia'
);
