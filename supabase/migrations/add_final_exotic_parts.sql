-- Ajout final de toutes les pièces exotiques et spécifiques

-- ========================================
-- INTÉRIEUR (pièces ultra spécifiques)
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Accoudoir central avant', 'interieur', 'confort', ARRAY['repose-bras avant'], true),
('Accoudoir central arrière', 'interieur', 'confort', ARRAY['repose-bras arrière'], false),
('Bac de rangement de portière', 'interieur', 'rangement', ARRAY['vide-poche porte'], false),
('Bandeau de commande centrale', 'interieur', 'commande', ARRAY['console centrale'], false),
('Cache airbag conducteur', 'interieur', 'securite', ARRAY['trappe airbag volant'], true),
('Cache allume-cigare', 'interieur', 'habillage', ARRAY['bouchon 12V'], false),
('Cache pédalier', 'interieur', 'habillage', ARRAY['protection pédale'], false),
('Cache vis de siège', 'interieur', 'habillage', ARRAY['bouchon vis siège'], false),
('Cendrier', 'interieur', 'accessoire', ARRAY['cendrier amovible'], false),
('Crochet de coffre', 'interieur', 'rangement', ARRAY['attache coffre'], false),
('Dosseret de siège avant', 'interieur', 'confort', ARRAY['appui dos AV'], false),
('Filet de coffre', 'interieur', 'rangement', ARRAY['filet séparation'], false),
('Housse de levier', 'interieur', 'habillage', ARRAY['cache levier vitesse'], false),
('Insert de porte bois', 'interieur', 'decoration', ARRAY['garniture bois porte'], false),
('Insert de tableau de bord', 'interieur', 'decoration', ARRAY['garniture déco TB'], false),
('Pédalier sport', 'interieur', 'performance', ARRAY['pédales alu'], false),
('Poche de dossier', 'interieur', 'rangement', ARRAY['filet siège'], false),
('Porte-gobelet avant', 'interieur', 'confort', ARRAY['support verre AV'], true),
('Porte-gobelet arrière', 'interieur', 'confort', ARRAY['support verre AR'], false),
('Range CD', 'interieur', 'multimedia', ARRAY['porte CD'], false),
('Repose-pied conducteur', 'interieur', 'confort', ARRAY['cale-pied'], false),
('Revêtement de coffre', 'interieur', 'habillage', ARRAY['moquette coffre'], false),
('Sangle de fixation coffre', 'interieur', 'arrimage', ARRAY['courroie fixation'], false),
('Séparateur de coffre', 'interieur', 'rangement', ARRAY['cloison coffre'], false),
('Tablette arrière', 'interieur', 'rangement', ARRAY['plage arrière'], true),
('Tirette d''ouverture capot', 'interieur', 'commande', ARRAY['poignée capot'], false),
('Tirette d''ouverture trappe', 'interieur', 'commande', ARRAY['poignée trappe essence'], false),
('Vide-poche central', 'interieur', 'rangement', ARRAY['bac rangement'], false),

-- ========================================
-- CARROSSERIE (pièces rares)
-- ========================================
('Amortisseur de capot gauche', 'carrosserie', 'assistance', ARRAY['vérin capot G'], false),
('Amortisseur de capot droit', 'carrosserie', 'assistance', ARRAY['vérin capot D'], false),
('Antenne de toit', 'carrosserie', 'communication', ARRAY['antenne aileron'], false),
('Baguette chromée de porte', 'carrosserie', 'decoration', ARRAY['liseré chrome'], false),
('Baguette de bas de caisse', 'carrosserie', 'decoration', ARRAY['jonc soubassement'], false),
('Baguette de vitre', 'carrosserie', 'etancheite', ARRAY['jonc vitre'], false),
('Bande anti-encastrement', 'carrosserie', 'securite', ARRAY['barre protection AR'], false),
('Cache attelage', 'carrosserie', 'protection', ARRAY['bouchon attelage'], false),
('Cache borne positive', 'carrosserie', 'protection', ARRAY['couvercle borne batterie'], false),
('Cache écrou d''antenne', 'carrosserie', 'esthetique', ARRAY['bouchon antenne'], false),
('Caméra de rétroviseur', 'carrosserie', 'vision', ARRAY['caméra rétro'], false),
('Capteur de recul', 'carrosserie', 'aide', ARRAY['radar recul'], true),
('Charnière de capot droite', 'carrosserie', 'fixation', ARRAY['paumelle capot D'], false),
('Charnière de capot gauche', 'carrosserie', 'fixation', ARRAY['paumelle capot G'], false),
('Charnière de coffre', 'carrosserie', 'fixation', ARRAY['paumelle coffre'], false),
('Charnière de porte avant droite', 'carrosserie', 'fixation', ARRAY['paumelle AV D'], false),
('Charnière de porte avant gauche', 'carrosserie', 'fixation', ARRAY['paumelle AV G'], false),
('Clignotant de rétroviseur droit', 'carrosserie', 'signalisation', ARRAY['répétiteur rétro D'], true),
('Clignotant de rétroviseur gauche', 'carrosserie', 'signalisation', ARRAY['répétiteur rétro G'], true),
('Enjoliveur de grille', 'carrosserie', 'decoration', ARRAY['liseré calandre'], false),
('Étrier de fixation échappement', 'carrosserie', 'fixation', ARRAY['collier échappement châssis'], false),
('Feu latéral droit', 'carrosserie', 'signalisation', ARRAY['clignotant latéral D'], false),
('Feu latéral gauche', 'carrosserie', 'signalisation', ARRAY['clignotant latéral G'], false),
('Glace de rétroviseur chauffante', 'carrosserie', 'confort', ARRAY['miroir dégivrant'], true),
('Joint d''aile', 'carrosserie', 'etancheite', ARRAY['joint passage roue'], false),
('Joint de coffre', 'carrosserie', 'etancheite', ARRAY['joint malle'], true),
('Joint de porte avant droit', 'carrosserie', 'etancheite', ARRAY['joint porte AV D'], false),
('Joint de porte avant gauche', 'carrosserie', 'etancheite', ARRAY['joint porte AV G'], false),
('Logo de calandre', 'carrosserie', 'decoration', ARRAY['badge grille'], true),
('Marche-pied droit', 'carrosserie', 'accessoire', ARRAY['marchepied D'], false),
('Marche-pied gauche', 'carrosserie', 'accessoire', ARRAY['marchepied G'], false),
('Monogramme de hayon', 'carrosserie', 'decoration', ARRAY['sigle coffre'], false),
('Moteur de rétroviseur droit', 'carrosserie', 'confort', ARRAY['actionneur rétro D'], true),
('Moteur de rétroviseur gauche', 'carrosserie', 'confort', ARRAY['actionneur rétro G'], true),
('Œil de remorquage avant', 'carrosserie', 'accessoire', ARRAY['anneau remorquage AV'], false),
('Œil de remorquage arrière', 'carrosserie', 'accessoire', ARRAY['anneau remorquage AR'], false),
('Phare antibrouillard avant droit', 'carrosserie', 'eclairage', ARRAY['antibrouillard AV D'], true),
('Phare antibrouillard avant gauche', 'carrosserie', 'eclairage', ARRAY['antibrouillard AV G'], true),
('Protection sous moteur', 'carrosserie', 'protection', ARRAY['carter protection'], true),
('Répétiteur latéral droit', 'carrosserie', 'signalisation', ARRAY['clignotant aile D'], false),
('Répétiteur latéral gauche', 'carrosserie', 'signalisation', ARRAY['clignotant aile G'], false),
('Résistance de rétroviseur', 'carrosserie', 'chauffage', ARRAY['élément chauffant rétro'], false),
('Sigle de custode', 'carrosserie', 'decoration', ARRAY['monogramme montant'], false),
('Spoiler avant', 'carrosserie', 'aero', ARRAY['lèvre AV'], false),
('Support d''antenne', 'carrosserie', 'fixation', ARRAY['pied antenne'], false),
('Tapis de coffre moulé', 'carrosserie', 'protection', ARRAY['bac coffre'], false),
('Verrou de capot', 'carrosserie', 'securite', ARRAY['crochet capot'], false),

-- ========================================
-- MOTEUR (pièces très rares)
-- ========================================
('Bougie à incandescence', 'moteur', 'demarrage', ARRAY['bougie préchauffage diesel'], true),
('Cache bobine d''allumage', 'moteur', 'protection', ARRAY['couvercle bobine'], false),
('Capteur de cliquetis', 'moteur', 'gestion moteur', ARRAY['capteur détonation'], false),
('Capteur de phase', 'moteur', 'gestion moteur', ARRAY['capteur AAC position'], false),
('Carter de filtre à air', 'moteur', 'admission', ARRAY['boîte filtre air'], true),
('Collecteur d''huile', 'moteur', 'lubrification', ARRAY['carter huile aluminium'], false),
('Conduit d''air', 'moteur', 'admission', ARRAY['gaine admission'], false),
('Courroie d''accessoires', 'moteur', 'transmission', ARRAY['courroie alternateur'], true),
('Couvercle de filtre à huile', 'moteur', 'filtration', ARRAY['cloche filtre'], false),
('Durite d''arrivée turbo', 'moteur', 'turbo', ARRAY['tuyau admission turbo'], false),
('Joint de bride turbo', 'moteur', 'etancheite', ARRAY['joint downpipe'], false),
('Joint de cache culbuteur', 'moteur', 'etancheite', ARRAY['joint couvre culasse'], false),
('Joint de soupape', 'moteur', 'etancheite', ARRAY['joint queue soupape'], false),
('Manocontact d''huile', 'moteur', 'mesure', ARRAY['capteur pression huile'], true),
('Pompe à huile', 'moteur', 'lubrification', ARRAY['pompe graissage'], true),
('Poulie de pompe à eau', 'moteur', 'refroidissement', ARRAY['poulie water pump'], false),
('Sonde de température d''huile', 'moteur', 'mesure', ARRAY['capteur température huile'], false),
('Support de turbo', 'moteur', 'fixation', ARRAY['bride turbo'], false),
('Vase d''expansion d''eau', 'moteur', 'refroidissement', ARRAY['bocal liquide refroidissement'], true),
('Ventilateur de refroidissement', 'moteur', 'refroidissement', ARRAY['électro-ventilateur'], true),

-- ========================================
-- TRANSMISSION (pièces spécifiques)
-- ========================================
('Actionneur de boîte robotisée', 'transmission', 'boite', ARRAY['vérin boîte robot'], false),
('Butée d''embrayage hydraulique', 'transmission', 'embrayage', ARRAY['butée CSC'], true),
('Capteur de vitesse de boîte', 'transmission', 'mesure', ARRAY['capteur régime BV'], false),
('Carter d''embrayage', 'transmission', 'protection', ARRAY['cloche embrayage'], false),
('Cylindre émetteur d''embrayage', 'transmission', 'hydraulique', ARRAY['maître-cylindre embrayage'], true),
('Filtre d''huile de pont', 'transmission', 'entretien', ARRAY['filtre différentiel'], false),
('Joint de cache sélecteur', 'transmission', 'etancheite', ARRAY['joint cache levier'], false),
('Joint spy d''arbre primaire', 'transmission', 'etancheite', ARRAY['joint spi entrée BV'], true),
('Joint spy d''arbre secondaire', 'transmission', 'etancheite', ARRAY['joint spi sortie BV'], true),
('Kit d''embrayage renforcé', 'transmission', 'performance', ARRAY['kit embrayage sport'], false),
('Palier de butée', 'transmission', 'embrayage', ARRAY['roulement butée'], false),
('Sélecteur de vitesses électronique', 'transmission', 'commande', ARRAY['actionneur BV'], false),
('Support de cardan', 'transmission', 'fixation', ARRAY['palier cardan'], false),

-- ========================================
-- FREINAGE (pièces avancées)
-- ========================================
('Bloc ABS', 'freinage', 'electronique', ARRAY['groupe hydraulique ABS'], true),
('Capteur d''usure de plaquettes avant', 'freinage', 'mesure', ARRAY['témoin usure AV'], false),
('Capteur d''usure de plaquettes arrière', 'freinage', 'mesure', ARRAY['témoin usure AR'], false),
('Compensateur de freinage', 'freinage', 'regulation', ARRAY['correcteur charge'], false),
('Durite maître-cylindre', 'freinage', 'hydraulique', ARRAY['flexible MC'], false),
('Étrier flottant', 'freinage', 'mecanique', ARRAY['étrier coulissant'], false),
('Kit de purge de freins', 'freinage', 'entretien', ARRAY['kit bleeding'], false),
('Plaquettes de frein à main', 'freinage', 'stationnement', ARRAY['mâchoires FDM'], true),
('Régulateur de pression de freinage', 'freinage', 'regulation', ARRAY['valve proportionnelle'], false),
('Témoin d''usure', 'freinage', 'mesure', ARRAY['capteur plaquettes'], false),

-- ========================================
-- SUSPENSION (pièces hydrauliques)
-- ========================================
('Accumulateur de suspension', 'suspension', 'hydraulique', ARRAY['sphère hydro'], false),
('Capteur de hauteur arrière', 'suspension', 'regulation', ARRAY['capteur assiette AR'], false),
('Capteur de hauteur avant', 'suspension', 'regulation', ARRAY['capteur assiette AV'], false),
('Compresseur de suspension', 'suspension', 'pneumatique', ARRAY['pompe air'], false),
('Électrovanne de suspension', 'suspension', 'regulation', ARRAY['valve suspension'], false),
('Kit de rehausse avant', 'suspension', 'modification', ARRAY['spacer AV'], false),
('Kit de rehausse arrière', 'suspension', 'modification', ARRAY['spacer AR'], false),
('Réservoir de LHM', 'suspension', 'hydraulique', ARRAY['bocal LHM'], false),

-- ========================================
-- DIRECTION (pièces électriques)
-- ========================================
('Capteur de couple de direction', 'direction', 'assistance', ARRAY['capteur effort volant'], false),
('Direction assistée électrique', 'direction', 'assistance', ARRAY['DAE'], true),
('Moteur de direction assistée', 'direction', 'assistance', ARRAY['moteur DAE'], true),
('Réservoir de LHM direction', 'direction', 'hydraulique', ARRAY['bocal DA'], false),

-- ========================================
-- ROUES (pièces spécifiques)
-- ========================================
('Adaptateur de jante', 'roues', 'fixation', ARRAY['entretoise roue'], false),
('Bague de centrage', 'roues', 'fixation', ARRAY['centreur jante'], false),
('Capteur de pression de pneu', 'roues', 'mesure', ARRAY['TPMS'], true),
('Centreur de roue', 'roues', 'fixation', ARRAY['bague centrage'], false),
('Clé antivol de roue', 'roues', 'securite', ARRAY['extracteur antivol'], false),
('Joint de valve', 'roues', 'etancheite', ARRAY['joint valve tubeless'], false),
('Kit de montage pneu', 'roues', 'reparation', ARRAY['kit démonte-pneu'], false),
('Prolongateur de valve', 'roues', 'accessoire', ARRAY['extension valve'], false),
('Valve tubeless', 'roues', 'accessoire', ARRAY['valve sans chambre'], false),

-- ========================================
-- ÉCLAIRAGE (pièces LED et modernes)
-- ========================================
('Ampoule LED H7', 'eclairage', 'source', ARRAY['LED H7'], true),
('Bandeau LED de jour', 'eclairage', 'jour', ARRAY['DRL'], true),
('Bloc feu LED arrière', 'eclairage', 'signalisation', ARRAY['feu LED AR'], true),
('Éclairage de seuil de porte', 'eclairage', 'confort', ARRAY['led seuil'], false),
('Éclairage de sol', 'eclairage', 'ambiance', ARRAY['led pied'], false),
('Éclairage intérieur LED', 'eclairage', 'habitacle', ARRAY['plafonnier LED'], false),
('Kit LED d''habitacle', 'eclairage', 'ambiance', ARRAY['éclairage intérieur LED'], false),
('Module de feu diurne', 'eclairage', 'jour', ARRAY['feu jour'], true),
('Optique LED avant', 'eclairage', 'optique', ARRAY['phare LED'], true),
('Projecteur LED antibrouillard', 'eclairage', 'brouillard', ARRAY['antibrouillard LED'], false),

-- ========================================
-- ÉLECTRICITÉ (pièces modernes)
-- ========================================
('Amplificateur d''antenne', 'electricite', 'multimedia', ARRAY['booster antenne'], false),
('Boîtier de servitude intelligent', 'electricite', 'gestion', ARRAY['BSI'], false),
('Capteur de niveau d''AdBlue', 'electricite', 'mesure', ARRAY['sonde AdBlue'], false),
('Capteur pluie-lumière', 'electricite', 'confort', ARRAY['capteur combiné'], true),
('Chargeur de batterie auxiliaire', 'electricite', 'charge', ARRAY['chargeur seconde batterie'], false),
('Convertisseur DC-DC', 'electricite', 'transformation', ARRAY['convertisseur tension'], false),
('Module de confort', 'electricite', 'confort', ARRAY['centrale confort'], false),
('Pompe AdBlue', 'electricite', 'antipollution', ARRAY['pompe urée'], false),
('Réservoir AdBlue', 'electricite', 'antipollution', ARRAY['réservoir urée'], true),
('Transformateur d''allumage', 'electricite', 'allumage', ARRAY['bobine allumage'], true),
('Unité de contrôle moteur', 'electricite', 'gestion moteur', ARRAY['calculateur moteur'], true),

-- ========================================
-- VITRAGE (détaillé)
-- ========================================
('Capteur de pluie sur pare-brise', 'vitrage', 'confort', ARRAY['capteur pluie'], true),
('Dégivreur de lunette arrière', 'vitrage', 'chauffage', ARRAY['résistance lunette'], true),
('Joint de lunette avant', 'vitrage', 'etancheite', ARRAY['joint pare-brise'], true),
('Mécanisme de toit ouvrant', 'vitrage', 'mecanique', ARRAY['moteur sunroof'], false),
('Panneau de toit panoramique', 'vitrage', 'vitre', ARRAY['toit vitré'], false),
('Store de toit ouvrant', 'vitrage', 'protection', ARRAY['rideau sunroof'], false),

-- ========================================
-- CLIMATISATION (détails finaux)
-- ========================================
('Capteur de qualité d''air habitacle', 'climatisation', 'regulation', ARRAY['capteur air'], false),
('Déshydrateur de climatisation', 'climatisation', 'traitement', ARRAY['filtre déshydrateur clim'], true),
('Détecteur de fuite clim', 'climatisation', 'diagnostic', ARRAY['traceur UV'], false),
('Moteur de volet de ventilation', 'climatisation', 'regulation', ARRAY['actionneur volet'], false),
('Ventilateur de condenseur', 'climatisation', 'refroidissement', ARRAY['motoventilateur clim'], true),

-- ========================================
-- ÉCHAPPEMENT (pièces performance)
-- ========================================
('Catalyseur sport', 'echappement', 'performance', ARRAY['cata 200 cellules'], false),
('Décatalyseur', 'echappement', 'performance', ARRAY['suppression cata'], false),
('Échappement sport', 'echappement', 'performance', ARRAY['ligne sport'], false),
('Silencieux à valves', 'echappement', 'performance', ARRAY['échappement variable'], false),
('Sortie d''échappement chromée', 'echappement', 'esthetique', ARRAY['embout chromé'], false),
('Tube de dégazage', 'echappement', 'modification', ARRAY['tube event'], false),

-- ========================================
-- CARBURANT (détaillé)
-- ========================================
('Capteur de niveau AdBlue', 'carburant', 'mesure', ARRAY['sonde urée'], false),
('Clapet anti-retour carburant', 'carburant', 'regulation', ARRAY['valve retour'], false),
('Conduit de vapeur d''essence', 'carburant', 'evacuation', ARRAY['tuyau vapeur'], false),
('Crépine de pompe à essence', 'carburant', 'filtration', ARRAY['tamis pompe'], false),
('Module de pompe à carburant', 'carburant', 'alimentation', ARRAY['ensemble pompe'], true),
('Pot à charbon actif', 'carburant', 'antipollution', ARRAY['canister'], false),
('Soupape de surpression', 'carburant', 'regulation', ARRAY['limiteur pression'], false),

-- ========================================
-- ACCESSOIRES (ultra détaillé)
-- ========================================
('Adaptateur prise allume-cigare', 'accessoires', 'multimedia', ARRAY['multiprise 12V'], false),
('Antivol de volant', 'accessoires', 'securite', ARRAY['canne antivol'], false),
('Béquille de levage', 'accessoires', 'outillage', ARRAY['chandelle'], false),
('Booster de batterie', 'accessoires', 'demarrage', ARRAY['démarreur portable'], false),
('Brosse à neige', 'accessoires', 'entretien', ARRAY['balai déneigement'], false),
('Câbles de démarrage', 'accessoires', 'demarrage', ARRAY['pinces batterie'], true),
('Centrale multimédia', 'accessoires', 'multimedia', ARRAY['GPS caméra'], false),
('Chargeur USB voiture', 'accessoires', 'multimedia', ARRAY['adaptateur USB'], false),
('Coffre de toit', 'accessoires', 'transport', ARRAY['malle toit'], false),
('Dashcam', 'accessoires', 'securite', ARRAY['caméra embarquée'], false),
('Diffuseur de parfum', 'accessoires', 'confort', ARRAY['désodorisant'], false),
('Housse de volant', 'accessoires', 'confort', ARRAY['couvre volant'], false),
('Kit embrayage hydraulique', 'accessoires', 'reparation', ARRAY['kit purge embrayage'], false),
('Kit first aid', 'accessoires', 'securite', ARRAY['trousse pharmacie'], false),
('Malle de transport', 'accessoires', 'rangement', ARRAY['coffre rangement'], false),
('Organisateur de coffre', 'accessoires', 'rangement', ARRAY['bac compartiments'], false),
('Porte-ski', 'accessoires', 'transport', ARRAY['fixation ski'], false),
('Rampe de levage', 'accessoires', 'outillage', ARRAY['pont roulant'], false),
('Remorque', 'accessoires', 'transport', ARRAY['attelage remorque'], false),
('Support tablette', 'accessoires', 'multimedia', ARRAY['fixation iPad'], false),
('Tendeur élastique', 'accessoires', 'arrimage', ARRAY['sangle élastique'], false),
('Transmetteur FM', 'accessoires', 'multimedia', ARRAY['adaptateur Bluetooth FM'], false)

ON CONFLICT (name) DO NOTHING;

-- Marquer toutes les pièces populaires
UPDATE public.parts
SET is_popular = true
WHERE name IN (
  'Accoudoir central avant',
  'Cache airbag conducteur',
  'Porte-gobelet avant',
  'Tablette arrière',
  'Capteur de recul',
  'Clignotant de rétroviseur droit',
  'Clignotant de rétroviseur gauche',
  'Glace de rétroviseur chauffante',
  'Joint de coffre',
  'Logo de calandre',
  'Moteur de rétroviseur droit',
  'Moteur de rétroviseur gauche',
  'Phare antibrouillard avant droit',
  'Phare antibrouillard avant gauche',
  'Protection sous moteur',
  'Bougie à incandescence',
  'Carter de filtre à air',
  'Courroie d''accessoires',
  'Manocontact d''huile',
  'Pompe à huile',
  'Vase d''expansion d''eau',
  'Ventilateur de refroidissement',
  'Butée d''embrayage hydraulique',
  'Cylindre émetteur d''embrayage',
  'Joint spy d''arbre primaire',
  'Joint spy d''arbre secondaire',
  'Bloc ABS',
  'Plaquettes de frein à main',
  'Direction assistée électrique',
  'Moteur de direction assistée',
  'Capteur de pression de pneu',
  'Ampoule LED H7',
  'Bandeau LED de jour',
  'Bloc feu LED arrière',
  'Module de feu diurne',
  'Optique LED avant',
  'Capteur pluie-lumière',
  'Réservoir AdBlue',
  'Transformateur d''allumage',
  'Unité de contrôle moteur',
  'Capteur de pluie sur pare-brise',
  'Dégivreur de lunette arrière',
  'Joint de lunette avant',
  'Déshydrateur de climatisation',
  'Ventilateur de condenseur',
  'Module de pompe à carburant',
  'Câbles de démarrage'
);
