-- Script pour insérer les pièces détachées avec leurs catégories

-- Fonction temporaire pour insérer les pièces
DO $$
BEGIN
  -- CATÉGORIE MOTEUR
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Moteur', 'moteur', 'bloc_moteur', ARRAY['moteur complet', 'bloc'], true),
  ('Bloc moteur', 'moteur', 'bloc_moteur', ARRAY['bloc', 'carter moteur'], false),
  ('Culasse', 'moteur', 'haut_moteur', ARRAY['tête de cylindre'], true),
  ('Vilebrequin', 'moteur', 'bas_moteur', ARRAY['arbre moteur'], false),
  ('Bielles', 'moteur', 'bas_moteur', ARRAY['bielle de piston'], false),
  ('Pistons', 'moteur', 'bas_moteur', ARRAY['piston moteur'], false),
  ('Segments', 'moteur', 'bas_moteur', ARRAY['segments de piston'], false),
  ('Soupapes', 'moteur', 'haut_moteur', ARRAY['soupape admission', 'soupape échappement'], false),
  ('Arbre à cames', 'moteur', 'distribution', ARRAY['camshaft', 'AAC'], false),
  ('Courroie de distribution', 'moteur', 'distribution', ARRAY['courroie timing'], true),
  ('Chaîne de distribution', 'moteur', 'distribution', ARRAY['chaîne timing'], false),
  ('Pompe à eau', 'moteur', 'refroidissement', ARRAY['pompe de refroidissement'], true),
  ('Thermostat', 'moteur', 'refroidissement', ARRAY['thermostat moteur'], false),
  ('Radiateur', 'moteur', 'refroidissement', ARRAY['radiateur de refroidissement'], true),
  ('Ventilateur de refroidissement', 'moteur', 'refroidissement', ARRAY['ventilateur radiateur'], false),
  ('Durite de refroidissement', 'moteur', 'refroidissement', ARRAY['durite', 'tuyau'], false),
  ('Réservoir expansion', 'moteur', 'refroidissement', ARRAY['vase d''expansion'], false),
  ('Pompe à huile', 'moteur', 'lubrification', ARRAY['pompe huile moteur'], false),
  ('Carter d''huile', 'moteur', 'lubrification', ARRAY['bac à huile'], false),
  ('Joint de culasse', 'moteur', 'joints', ARRAY['joint de tête'], true),
  ('Filtre à huile', 'moteur', 'filtres', ARRAY['filtre huile'], true),
  ('Filtre à air', 'moteur', 'filtres', ARRAY['filtre air moteur'], true),
  ('Filtre à carburant', 'moteur', 'filtres', ARRAY['filtre essence', 'filtre gasoil'], true),
  ('Injecteur', 'moteur', 'injection', ARRAY['injecteur essence', 'injecteur diesel'], true),
  ('Pompe à injection', 'moteur', 'injection', ARRAY['pompe haute pression'], false),
  ('Turbocompresseur', 'moteur', 'suralimentation', ARRAY['turbo'], true),
  ('Compresseur', 'moteur', 'suralimentation', ARRAY['compresseur volumétrique'], false),
  ('Intercooler', 'moteur', 'suralimentation', ARRAY['échangeur air'], false),
  ('Collecteur d''admission', 'moteur', 'admission', ARRAY['pipe admission'], false),
  ('Collecteur d''échappement', 'moteur', 'echappement', ARRAY['tubulure échappement'], false),
  ('Catalyseur', 'moteur', 'echappement', ARRAY['pot catalytique'], true),
  ('Pot d''échappement', 'moteur', 'echappement', ARRAY['silencieux arrière'], true),
  ('Silencieux', 'moteur', 'echappement', ARRAY['pot intermédiaire'], false),
  ('Ligne d''échappement', 'moteur', 'echappement', ARRAY['échappement complet'], false),
  ('Sonde lambda', 'moteur', 'capteurs', ARRAY['sonde O2'], false),
  ('Bobine d''allumage', 'moteur', 'allumage', ARRAY['bobine'], true),
  ('Bougie d''allumage', 'moteur', 'allumage', ARRAY['bougie'], true),
  ('Bougie de préchauffage', 'moteur', 'allumage', ARRAY['bougie de chauffe'], false),
  ('Alternateur', 'moteur', 'electrique', ARRAY['génératrice'], true),
  ('Démarreur', 'moteur', 'electrique', ARRAY['starter'], true),
  ('Batterie', 'moteur', 'electrique', ARRAY['accumulateur'], true),
  ('Courroie accessoire', 'moteur', 'courroies', ARRAY['courroie alternateur'], false),
  ('Poulie', 'moteur', 'courroies', ARRAY['poulie damper'], false),
  ('Galet tendeur', 'moteur', 'courroies', ARRAY['tendeur courroie'], false),
  ('Support moteur', 'moteur', 'supports', ARRAY['silent bloc moteur'], false);

  -- CATÉGORIE TRANSMISSION
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Boîte de vitesses', 'transmission', 'boite', ARRAY['boîte', 'BV'], true),
  ('Embrayage', 'transmission', 'embrayage', ARRAY['kit embrayage'], true),
  ('Disque d''embrayage', 'transmission', 'embrayage', ARRAY['disque'], false),
  ('Mécanisme d''embrayage', 'transmission', 'embrayage', ARRAY['plateau'], false),
  ('Butée d''embrayage', 'transmission', 'embrayage', ARRAY['butée'], false),
  ('Volant moteur', 'transmission', 'embrayage', ARRAY['volant bi-masse'], false),
  ('Arbre de transmission', 'transmission', 'transmission', ARRAY['arbre'], false),
  ('Cardan', 'transmission', 'transmission', ARRAY['joint de cardan'], true),
  ('Joint de cardan', 'transmission', 'transmission', ARRAY['croisillon'], false),
  ('Différentiel', 'transmission', 'transmission', ARRAY['pont arrière'], false),
  ('Pont', 'transmission', 'transmission', ARRAY['pont avant'], false),
  ('Demi-train', 'transmission', 'transmission', ARRAY['demi arbre'], false),
  ('Soufflet de cardan', 'transmission', 'transmission', ARRAY['soufflet transmission'], false);

  -- CATÉGORIE FREINAGE
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Plaquettes de frein', 'freinage', 'freins', ARRAY['plaquettes'], true),
  ('Disque de frein', 'freinage', 'freins', ARRAY['disques'], true),
  ('Tambour de frein', 'freinage', 'freins', ARRAY['tambours'], false),
  ('Mâchoires de frein', 'freinage', 'freins', ARRAY['mâchoires'], false),
  ('Étrier de frein', 'freinage', 'freins', ARRAY['étrier'], true),
  ('Maître-cylindre', 'freinage', 'hydraulique', ARRAY['maître cylindre frein'], false),
  ('Cylindre de roue', 'freinage', 'hydraulique', ARRAY['cylindre'], false),
  ('Servo-frein', 'freinage', 'assistance', ARRAY['servofrein'], false),
  ('ABS', 'freinage', 'electronique', ARRAY['bloc ABS'], false),
  ('Capteur ABS', 'freinage', 'electronique', ARRAY['capteur vitesse roue'], false),
  ('Liquide de frein', 'freinage', 'fluides', ARRAY['DOT 4', 'DOT 5'], false),
  ('Flexible de frein', 'freinage', 'hydraulique', ARRAY['durite frein'], false),
  ('Frein à main', 'freinage', 'stationnement', ARRAY['frein parking'], false),
  ('Câble de frein à main', 'freinage', 'stationnement', ARRAY['câble frein'], false);

  -- CATÉGORIE DIRECTION
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Volant', 'direction', 'commande', ARRAY['volant direction'], false),
  ('Colonne de direction', 'direction', 'commande', ARRAY['colonne'], false),
  ('Crémaillère', 'direction', 'mecanisme', ARRAY['crémaillère direction'], true),
  ('Boîtier de direction', 'direction', 'mecanisme', ARRAY['boîtier'], false),
  ('Biellette de direction', 'direction', 'timonerie', ARRAY['biellette'], true),
  ('Rotule de direction', 'direction', 'timonerie', ARRAY['rotule'], true),
  ('Soufflet de crémaillère', 'direction', 'protection', ARRAY['soufflet'], false),
  ('Pompe de direction assistée', 'direction', 'assistance', ARRAY['pompe DA'], false),
  ('Réservoir LDR', 'direction', 'assistance', ARRAY['réservoir direction'], false),
  ('Liquide de direction', 'direction', 'fluides', ARRAY['LDR'], false);

  -- CATÉGORIE SUSPENSION
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Amortisseur', 'suspension', 'amortisseurs', ARRAY['amortisseurs'], true),
  ('Ressort', 'suspension', 'ressorts', ARRAY['ressort suspension'], false),
  ('Coupelle d''amortisseur', 'suspension', 'amortisseurs', ARRAY['coupelle'], false),
  ('Butée de compression', 'suspension', 'amortisseurs', ARRAY['butée'], false),
  ('Bras de suspension', 'suspension', 'bras', ARRAY['bras'], false),
  ('Triangle de suspension', 'suspension', 'bras', ARRAY['triangle'], true),
  ('Silent-bloc', 'suspension', 'articulations', ARRAY['silent bloc'], false),
  ('Rotule de suspension', 'suspension', 'articulations', ARRAY['rotule'], false),
  ('Barre stabilisatrice', 'suspension', 'stabilisation', ARRAY['barre anti-roulis'], false),
  ('Biellette de barre stabilisatrice', 'suspension', 'stabilisation', ARRAY['biellette'], false),
  ('Jambe de force', 'suspension', 'amortisseurs', ARRAY['jambe McPherson'], false),
  ('Combiné fileté', 'suspension', 'sport', ARRAY['coilovers'], false);

  -- CATÉGORIE ROUES
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Jante', 'roues', 'jantes', ARRAY['jantes alu', 'jantes tôle'], true),
  ('Pneu', 'roues', 'pneus', ARRAY['pneus'], true),
  ('Chambre à air', 'roues', 'pneus', ARRAY['chambre'], false),
  ('Valve', 'roues', 'pneus', ARRAY['valve pneu'], false),
  ('Enjoliveur', 'roues', 'accessoires', ARRAY['enjoliveurs'], false),
  ('Cache moyeu', 'roues', 'accessoires', ARRAY['cache'], false),
  ('Écrou de roue', 'roues', 'fixation', ARRAY['écrous'], false),
  ('Boulon de roue', 'roues', 'fixation', ARRAY['boulons'], false),
  ('Roulement de roue', 'roues', 'roulement', ARRAY['roulement'], true),
  ('Moyeu', 'roues', 'roulement', ARRAY['moyeu roue'], false);

  -- CATÉGORIE CARROSSERIE
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Pare-chocs avant', 'carrosserie', 'pare_chocs', ARRAY['PC avant'], true),
  ('Pare-chocs arrière', 'carrosserie', 'pare_chocs', ARRAY['PC arrière'], true),
  ('Aile avant', 'carrosserie', 'toles', ARRAY['aile AVG', 'aile AVD'], true),
  ('Aile arrière', 'carrosserie', 'toles', ARRAY['aile ARG', 'aile ARD'], true),
  ('Portière', 'carrosserie', 'ouvrants', ARRAY['porte'], true),
  ('Capot', 'carrosserie', 'ouvrants', ARRAY['capot moteur'], true),
  ('Coffre', 'carrosserie', 'ouvrants', ARRAY['malle'], false),
  ('Hayon', 'carrosserie', 'ouvrants', ARRAY['porte arrière'], true),
  ('Toit ouvrant', 'carrosserie', 'toit', ARRAY['toit panoramique'], false),
  ('Becquet', 'carrosserie', 'aerodynamique', ARRAY['aileron'], false),
  ('Spoiler', 'carrosserie', 'aerodynamique', ARRAY['lame'], false),
  ('Calandre', 'carrosserie', 'facade', ARRAY['grille calandre'], true),
  ('Grille de radiateur', 'carrosserie', 'facade', ARRAY['grille'], false),
  ('Rétroviseur', 'carrosserie', 'retroviseurs', ARRAY['rétro'], true),
  ('Coque de rétroviseur', 'carrosserie', 'retroviseurs', ARRAY['coque rétro'], false),
  ('Glace de rétroviseur', 'carrosserie', 'retroviseurs', ARRAY['miroir'], false),
  ('Vitre avant', 'carrosserie', 'vitrage', ARRAY['vitre AVG', 'vitre AVD'], false),
  ('Vitre arrière', 'carrosserie', 'vitrage', ARRAY['vitre ARG', 'vitre ARD'], false),
  ('Vitre latérale', 'carrosserie', 'vitrage', ARRAY['vitre porte'], false),
  ('Pare-brise', 'carrosserie', 'vitrage', ARRAY['pare brise'], true),
  ('Lunette arrière', 'carrosserie', 'vitrage', ARRAY['vitre arrière'], false),
  ('Joint de vitre', 'carrosserie', 'joints', ARRAY['joint'], false),
  ('Mécanisme lève-vitre', 'carrosserie', 'mecanismes', ARRAY['lève vitre'], true),
  ('Poignée de portière', 'carrosserie', 'accessoires', ARRAY['poignée'], false),
  ('Serrure de portière', 'carrosserie', 'securite', ARRAY['serrure'], false),
  ('Barillet de serrure', 'carrosserie', 'securite', ARRAY['barillet'], false),
  ('Cylindre de serrure', 'carrosserie', 'securite', ARRAY['cylindre'], false);

  -- CATÉGORIE ÉCLAIRAGE
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Phare avant', 'eclairage', 'phares', ARRAY['optique avant'], true),
  ('Feu arrière', 'eclairage', 'feux', ARRAY['feu AR'], true),
  ('Clignotant', 'eclairage', 'feux', ARRAY['cligno'], false),
  ('Feu de brouillard', 'eclairage', 'feux', ARRAY['antibrouillard'], false),
  ('Feu de recul', 'eclairage', 'feux', ARRAY['feu marche arrière'], false),
  ('Feu stop', 'eclairage', 'feux', ARRAY['stop'], false),
  ('Veilleuse', 'eclairage', 'feux', ARRAY['feu position'], false),
  ('Ampoule', 'eclairage', 'ampoules', ARRAY['ampoules'], true),
  ('LED', 'eclairage', 'ampoules', ARRAY['ampoule LED'], false),
  ('Xenon', 'eclairage', 'ampoules', ARRAY['kit xenon'], false),
  ('Projecteur', 'eclairage', 'phares', ARRAY['bloc optique'], false),
  ('Réflecteur', 'eclairage', 'accessoires', ARRAY['catadioptre'], false),
  ('Optique', 'eclairage', 'phares', ARRAY['bloc phare'], false);

  -- CATÉGORIE INTÉRIEUR
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Siège avant', 'interieur', 'sieges', ARRAY['siège conducteur', 'siège passager'], true),
  ('Siège arrière', 'interieur', 'sieges', ARRAY['banquette arrière'], true),
  ('Banquette', 'interieur', 'sieges', ARRAY['banquette'], false),
  ('Appui-tête', 'interieur', 'sieges', ARRAY['appuie tête'], false),
  ('Ceinture de sécurité', 'interieur', 'securite', ARRAY['ceinture'], true),
  ('Enrouleur de ceinture', 'interieur', 'securite', ARRAY['enrouleur'], false),
  ('Tableau de bord', 'interieur', 'habitacle', ARRAY['planche de bord'], true),
  ('Compteur', 'interieur', 'instrumentation', ARRAY['compteur vitesse'], false),
  ('Combiné d''instruments', 'interieur', 'instrumentation', ARRAY['combiné'], false),
  ('Autoradio', 'interieur', 'multimedia', ARRAY['radio', 'poste'], true),
  ('GPS', 'interieur', 'multimedia', ARRAY['navigation'], false),
  ('Écran multimédia', 'interieur', 'multimedia', ARRAY['écran tactile'], false),
  ('Haut-parleur', 'interieur', 'multimedia', ARRAY['HP', 'enceinte'], false),
  ('Antenne', 'interieur', 'multimedia', ARRAY['antenne radio'], false),
  ('Console centrale', 'interieur', 'habitacle', ARRAY['console'], false),
  ('Boîte à gants', 'interieur', 'rangement', ARRAY['boite gants'], false),
  ('Vide-poches', 'interieur', 'rangement', ARRAY['vide poche'], false),
  ('Tapis de sol', 'interieur', 'protection', ARRAY['tapis'], false),
  ('Moquette', 'interieur', 'revetement', ARRAY['moquette sol'], false),
  ('Garniture de portière', 'interieur', 'habillage', ARRAY['panneau porte'], false),
  ('Poignée intérieure', 'interieur', 'accessoires', ARRAY['poignée'], false),
  ('Commutateur', 'interieur', 'commandes', ARRAY['commodo'], false),
  ('Bouton', 'interieur', 'commandes', ARRAY['boutons'], false),
  ('Manette', 'interieur', 'commandes', ARRAY['manette'], false),
  ('Levier de vitesse', 'interieur', 'commandes', ARRAY['levier'], true),
  ('Pommeau de levier', 'interieur', 'commandes', ARRAY['pommeau'], false),
  ('Frein à main', 'interieur', 'commandes', ARRAY['frein main'], false),
  ('Pédale', 'interieur', 'commandes', ARRAY['pédales'], false),
  ('Accélérateur', 'interieur', 'commandes', ARRAY['pédale accélérateur'], false),
  ('Embrayage', 'interieur', 'commandes', ARRAY['pédale embrayage'], false),
  ('Frein', 'interieur', 'commandes', ARRAY['pédale frein'], false);

  -- CATÉGORIE CLIMATISATION
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Compresseur de climatisation', 'climatisation', 'systeme', ARRAY['compresseur clim'], true),
  ('Condenseur', 'climatisation', 'systeme', ARRAY['condenseur clim'], false),
  ('Évaporateur', 'climatisation', 'systeme', ARRAY['évaporateur clim'], false),
  ('Détendeur', 'climatisation', 'systeme', ARRAY['détendeur clim'], false),
  ('Filtre déshydratant', 'climatisation', 'filtres', ARRAY['bouteille déshydratante'], false),
  ('Flexible de climatisation', 'climatisation', 'conduites', ARRAY['durite clim'], false),
  ('Gaz réfrigérant', 'climatisation', 'fluides', ARRAY['R134a', 'R1234yf'], false),
  ('Ventilateur d''habitacle', 'climatisation', 'ventilation', ARRAY['ventilo habitacle'], false),
  ('Pulseur d''air', 'climatisation', 'ventilation', ARRAY['pulseur'], true),
  ('Résistance de chauffage', 'climatisation', 'chauffage', ARRAY['résistance'], false),
  ('Radiateur de chauffage', 'climatisation', 'chauffage', ARRAY['radiateur chauffage'], false),
  ('Filtre d''habitacle', 'climatisation', 'filtres', ARRAY['filtre pollen'], true),
  ('Bouche d''aération', 'climatisation', 'ventilation', ARRAY['aérateur'], false),
  ('Grille d''aération', 'climatisation', 'ventilation', ARRAY['grille aération'], false);

  -- CATÉGORIE ÉLECTRONIQUE
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Calculateur', 'electronique', 'gestion', ARRAY['ECU', 'UCE'], true),
  ('ECU', 'electronique', 'gestion', ARRAY['calculateur moteur'], false),
  ('BCM', 'electronique', 'gestion', ARRAY['boîtier confort'], false),
  ('Faisceau électrique', 'electronique', 'cablage', ARRAY['faisceau'], false),
  ('Connecteur', 'electronique', 'cablage', ARRAY['prise'], false),
  ('Fusible', 'electronique', 'protection', ARRAY['fusibles'], true),
  ('Relais', 'electronique', 'protection', ARRAY['relais'], false),
  ('Capteur', 'electronique', 'capteurs', ARRAY['sonde'], false),
  ('Sonde', 'electronique', 'capteurs', ARRAY['capteur'], false),
  ('Actionneur', 'electronique', 'actionneurs', ARRAY['actuateur'], false),
  ('Moteur électrique', 'electronique', 'actionneurs', ARRAY['servomoteur'], false),
  ('Centrale clignotante', 'electronique', 'modules', ARRAY['centrale cligno'], false),
  ('Régulateur de tension', 'electronique', 'modules', ARRAY['régulateur'], false),
  ('Commande électronique', 'electronique', 'modules', ARRAY['module'], false);

  -- CATÉGORIE ACCESSOIRES
  INSERT INTO parts (name, category, subcategory, synonyms, is_popular) VALUES
  ('Essuie-glace', 'accessoires', 'essuyage', ARRAY['essuie glaces'], true),
  ('Balai d''essuie-glace', 'accessoires', 'essuyage', ARRAY['balais'], true),
  ('Moteur d''essuie-glace', 'accessoires', 'essuyage', ARRAY['moteur essuie'], false),
  ('Pompe de lave-glace', 'accessoires', 'lavage', ARRAY['pompe lave glace'], false),
  ('Réservoir lave-glace', 'accessoires', 'lavage', ARRAY['réservoir'], false),
  ('Gicleur', 'accessoires', 'lavage', ARRAY['gicleur lave glace'], false),
  ('Klaxon', 'accessoires', 'avertisseur', ARRAY['avertisseur sonore'], false),
  ('Avertisseur sonore', 'accessoires', 'avertisseur', ARRAY['klaxon'], false),
  ('Rétroviseur intérieur', 'accessoires', 'retroviseurs', ARRAY['rétro intérieur'], false),
  ('Pare-soleil', 'accessoires', 'protection', ARRAY['pare soleil'], false),
  ('Plafonnier', 'accessoires', 'eclairage', ARRAY['éclairage plafonnier'], false),
  ('Éclairage intérieur', 'accessoires', 'eclairage', ARRAY['lampe intérieur'], false),
  ('Prise 12V', 'accessoires', 'alimentation', ARRAY['prise allume cigare'], false),
  ('Allume-cigare', 'accessoires', 'alimentation', ARRAY['allume cigare'], false),
  ('Cendrier', 'accessoires', 'confort', ARRAY['cendriers'], false),
  ('Attelage', 'accessoires', 'remorquage', ARRAY['crochet attelage'], true),
  ('Crochet d''attelage', 'accessoires', 'remorquage', ARRAY['attelage'], false),
  ('Faisceau d''attelage', 'accessoires', 'remorquage', ARRAY['faisceau'], false),
  ('Galerie de toit', 'accessoires', 'portage', ARRAY['galerie'], false),
  ('Barres de toit', 'accessoires', 'portage', ARRAY['barres'], false);

  -- Marquer les pièces les plus recherchées comme populaires
  UPDATE parts SET is_popular = true WHERE name IN (
    'Plaquettes de frein', 'Disque de frein', 'Filtre à huile', 
    'Filtre à air', 'Batterie', 'Alternateur', 'Démarreur',
    'Embrayage', 'Amortisseur', 'Rétroviseur', 'Phare avant'
  );

END $$;