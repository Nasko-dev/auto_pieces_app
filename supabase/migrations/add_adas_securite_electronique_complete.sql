-- Ajout complet ADAS, sécurité et électronique avancée

-- ========================================
-- ADAS / SÉCURITÉ / ÉLECTRONIQUE AVANCÉE
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Radars et capteurs ADAS
('Radar avant longue portée', 'electronique', 'adas', ARRAY['radar ACC'], true),
('Radar avant courte portée gauche', 'electronique', 'adas', ARRAY['radar angle G'], false),
('Radar avant courte portée droit', 'electronique', 'adas', ARRAY['radar angle D'], false),
('Radar arrière gauche', 'electronique', 'adas', ARRAY['radar BSD G'], false),
('Radar arrière droit', 'electronique', 'adas', ARRAY['radar BSD D'], false),
('Radar de recul', 'electronique', 'adas', ARRAY['radar parking'], true),

-- Caméras ADAS
('Caméra avant multifonction', 'electronique', 'adas', ARRAY['caméra pare-brise'], true),
('Caméra de recul', 'electronique', 'adas', ARRAY['caméra arrière'], true),
('Caméra latérale gauche', 'electronique', 'adas', ARRAY['caméra angle mort G'], false),
('Caméra latérale droite', 'electronique', 'adas', ARRAY['caméra angle mort D'], false),
('Caméra 360', 'electronique', 'adas', ARRAY['caméra surround view'], false),
('Caméra de surveillance intérieure', 'electronique', 'adas', ARRAY['caméra habitacle'], false),

-- Capteurs de stationnement
('Capteur de stationnement avant gauche', 'electronique', 'parking', ARRAY['capteur parking AV G'], true),
('Capteur de stationnement avant droit', 'electronique', 'parking', ARRAY['capteur parking AV D'], true),
('Capteur de stationnement avant central gauche', 'electronique', 'parking', ARRAY['capteur AV centre G'], false),
('Capteur de stationnement avant central droit', 'electronique', 'parking', ARRAY['capteur AV centre D'], false),
('Capteur de stationnement arrière gauche', 'electronique', 'parking', ARRAY['capteur parking AR G'], true),
('Capteur de stationnement arrière droit', 'electronique', 'parking', ARRAY['capteur parking AR D'], true),
('Capteur de stationnement arrière central gauche', 'electronique', 'parking', ARRAY['capteur AR centre G'], false),
('Capteur de stationnement arrière central droit', 'electronique', 'parking', ARRAY['capteur AR centre D'], false),
('Module de capteurs de stationnement', 'electronique', 'parking', ARRAY['calculateur parking'], false),

-- Airbags
('Airbag conducteur', 'interieur', 'securite', ARRAY['airbag volant'], true),
('Airbag passager', 'interieur', 'securite', ARRAY['airbag tableau bord'], true),
('Airbag latéral avant gauche', 'interieur', 'securite', ARRAY['airbag siège G'], true),
('Airbag latéral avant droit', 'interieur', 'securite', ARRAY['airbag siège D'], true),
('Airbag rideau gauche', 'interieur', 'securite', ARRAY['airbag tête G'], false),
('Airbag rideau droit', 'interieur', 'securite', ARRAY['airbag tête D'], false),
('Airbag de genoux', 'interieur', 'securite', ARRAY['knee airbag'], false),
('Calculateur d''airbag', 'electronique', 'securite', ARRAY['boîtier airbag'], true),
('Contacteur tournant airbag', 'electronique', 'securite', ARRAY['ressort spiral'], true),

-- Surveillance et détection
('Détecteur d''angle mort gauche', 'electronique', 'adas', ARRAY['BSD G'], false),
('Détecteur d''angle mort droit', 'electronique', 'adas', ARRAY['BSD D'], false),
('Capteur de somnolence', 'electronique', 'adas', ARRAY['détecteur fatigue'], false),
('Capteur de pluie', 'electronique', 'capteur', ARRAY['détecteur pluie'], true),
('Capteur de luminosité', 'electronique', 'capteur', ARRAY['capteur jour/nuit'], false),
('Capteur solaire', 'electronique', 'capteur', ARRAY['sonde ensoleillement'], false),

-- Régulateurs et assistances
('Module de régulateur de vitesse adaptatif', 'electronique', 'adas', ARRAY['ACC'], false),
('Module d''aide au stationnement', 'electronique', 'adas', ARRAY['park assist'], false),
('Module de maintien de voie', 'electronique', 'adas', ARRAY['LKA'], false),
('Module de reconnaissance de panneaux', 'electronique', 'adas', ARRAY['TSR'], false),
('Module de freinage d''urgence', 'electronique', 'adas', ARRAY['AEB'], false),

-- Multimedia et connectivité
('Autoradio', 'electronique', 'multimedia', ARRAY['poste radio'], true),
('Écran tactile multimédia', 'electronique', 'multimedia', ARRAY['écran central'], true),
('GPS de navigation', 'electronique', 'multimedia', ARRAY['système navigation'], false),
('Module Bluetooth', 'electronique', 'connectivite', ARRAY['kit mains libres'], false),
('Antenne GPS', 'electronique', 'antenne', ARRAY['antenne navigation'], false),
('Antenne radio', 'electronique', 'antenne', ARRAY['antenne FM'], true),
('Amplificateur audio', 'electronique', 'multimedia', ARRAY['ampli son'], false),
('Haut-parleur avant gauche', 'electronique', 'audio', ARRAY['HP AV G'], false),
('Haut-parleur avant droit', 'electronique', 'audio', ARRAY['HP AV D'], false),
('Haut-parleur arrière gauche', 'electronique', 'audio', ARRAY['HP AR G'], false),
('Haut-parleur arrière droit', 'electronique', 'audio', ARRAY['HP AR D'], false),
('Caisson de basses', 'electronique', 'audio', ARRAY['subwoofer'], false),

-- Alarme et antivol
('Sirène d''alarme', 'electronique', 'alarme', ARRAY['avertisseur alarme'], false),
('Module d''alarme', 'electronique', 'alarme', ARRAY['centrale alarme'], false),
('Capteur volumétrique', 'electronique', 'alarme', ARRAY['détecteur présence'], false),
('Capteur d''inclinaison', 'electronique', 'alarme', ARRAY['détecteur remorquage'], false),
('Télécommande d''alarme', 'electronique', 'alarme', ARRAY['bip alarme'], false),

-- Télécommande et clés
('Clé de contact', 'electronique', 'cle', ARRAY['clé standard'], true),
('Clé télécommande', 'electronique', 'cle', ARRAY['clé plip'], true),
('Clé main libre', 'electronique', 'cle', ARRAY['carte mains libres'], true),
('Pile de télécommande CR2032', 'electronique', 'pile', ARRAY['pile clé'], true),
('Pile de télécommande CR2025', 'electronique', 'pile', ARRAY['pile clé 2025'], false),
('Coque de clé', 'electronique', 'cle', ARRAY['boîtier clé'], true),

-- Affichage tête haute
('Affichage tête haute', 'electronique', 'affichage', ARRAY['HUD', 'head-up display'], false),
('Verre d''affichage tête haute', 'electronique', 'affichage', ARRAY['vitre HUD'], false),

-- Essuie-glaces
('Balai d''essuie-glace avant gauche', 'accessoires', 'essuie-glace', ARRAY['balai AV G'], true),
('Balai d''essuie-glace avant droit', 'accessoires', 'essuie-glace', ARRAY['balai AV D'], true),
('Balai d''essuie-glace arrière', 'accessoires', 'essuie-glace', ARRAY['balai AR'], true),
('Moteur d''essuie-glace avant', 'accessoires', 'essuie-glace', ARRAY['moteur essuie-glace AV'], true),
('Moteur d''essuie-glace arrière', 'accessoires', 'essuie-glace', ARRAY['moteur essuie-glace AR'], true),
('Mécanisme d''essuie-glace', 'accessoires', 'essuie-glace', ARRAY['tringlerie essuie-glace'], false),
('Bras d''essuie-glace avant gauche', 'accessoires', 'essuie-glace', ARRAY['bras AV G'], false),
('Bras d''essuie-glace avant droit', 'accessoires', 'essuie-glace', ARRAY['bras AV D'], false),
('Bras d''essuie-glace arrière', 'accessoires', 'essuie-glace', ARRAY['bras AR'], false),

-- Lave-glace
('Pompe de lave-glace', 'accessoires', 'lave-glace', ARRAY['pompe lave-vitre'], true),
('Réservoir de lave-glace', 'accessoires', 'lave-glace', ARRAY['bocal lave-vitre'], true),
('Gicleur de lave-glace avant gauche', 'accessoires', 'lave-glace', ARRAY['jet lave-vitre AV G'], true),
('Gicleur de lave-glace avant droit', 'accessoires', 'lave-glace', ARRAY['jet lave-vitre AV D'], true),
('Gicleur de lave-glace arrière', 'accessoires', 'lave-glace', ARRAY['jet lave-vitre AR'], true),
('Bouchon de réservoir de lave-glace', 'accessoires', 'lave-glace', ARRAY['bouchon bocal'], false),
('Liquide lave-glace été', 'accessoires', 'fluide', ARRAY['lave-vitre été'], true),
('Liquide lave-glace hiver', 'accessoires', 'fluide', ARRAY['lave-vitre -20°C'], true),

-- Électronique divers
('Module de confort', 'electronique', 'module', ARRAY['boîtier confort'], false),
('Calculateur de carrosserie', 'electronique', 'calculateur', ARRAY['BCM'], false),
('Gateway', 'electronique', 'calculateur', ARRAY['passerelle réseau'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Radar avant longue portée',
  'Caméra avant multifonction',
  'Caméra de recul',
  'Capteur de stationnement avant gauche',
  'Capteur de stationnement arrière gauche',
  'Airbag conducteur',
  'Airbag passager',
  'Calculateur d''airbag',
  'Autoradio',
  'Écran tactile multimédia',
  'Clé télécommande',
  'Balai d''essuie-glace avant gauche',
  'Balai d''essuie-glace avant droit',
  'Pompe de lave-glace',
  'Liquide lave-glace été'
);
