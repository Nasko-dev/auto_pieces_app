-- Ajout complet accessoires et divers

-- ========================================
-- ACCESSOIRES & DIVERS
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Pneumatiques
('Pneu été', 'roues', 'pneumatique', ARRAY['pneu summer'], true),
('Pneu hiver', 'roues', 'pneumatique', ARRAY['pneu winter'], true),
('Pneu 4 saisons', 'roues', 'pneumatique', ARRAY['pneu all season'], true),
('Pneu sport', 'roues', 'pneumatique', ARRAY['pneu performance'], false),
('Pneu renforcé', 'roues', 'pneumatique', ARRAY['pneu XL'], false),
('Pneu runflat', 'roues', 'pneumatique', ARRAY['pneu anti-crevaison'], false),

-- Jantes
('Jante aluminium', 'roues', 'jante', ARRAY['jante alu'], true),
('Jante tôle', 'roues', 'jante', ARRAY['jante acier'], true),
('Enjoliveur', 'roues', 'enjoliveur', ARRAY['cache jante'], true),
('Centre de roue', 'roues', 'jante', ARRAY['cache moyeu'], false),
('Valve de pneu', 'roues', 'valve', ARRAY['valve chambre air'], true),
('Bouchon de valve', 'roues', 'valve', ARRAY['capuchon valve'], false),
('Capteur TPMS', 'roues', 'capteur', ARRAY['capteur pression pneu'], true),

-- Équilibrage et montage
('Masses d''équilibrage', 'roues', 'equilibrage', ARRAY['plombs jante'], true),
('Pâte de montage pneu', 'roues', 'produit', ARRAY['lubrifiant montage'], false),

-- Chaînes et équipements hiver
('Chaînes à neige', 'accessoires', 'hiver', ARRAY['chaînes'], true),
('Chaussettes à neige', 'accessoires', 'hiver', ARRAY['textiles neige'], false),
('Raclette à givre', 'accessoires', 'hiver', ARRAY['grattoir'], true),
('Balai à neige', 'accessoires', 'hiver', ARRAY['brosse neige'], false),

-- Attelage et remorquage
('Attelage', 'accessoires', 'attelage', ARRAY['boule attelage'], true),
('Rotule d''attelage', 'accessoires', 'attelage', ARRAY['boule remorque'], true),
('Faisceau électrique d''attelage', 'accessoires', 'attelage', ARRAY['prise remorque'], true),
('Module attelage', 'electronique', 'attelage', ARRAY['boîtier remorque'], false),
('Câble de remorquage', 'accessoires', 'remorquage', ARRAY['sangle remorquage'], true),
('Barre de remorquage', 'accessoires', 'remorquage', ARRAY['triangle remorquage'], false),

-- Barres de toit et transport
('Barre de toit', 'accessoires', 'transport', ARRAY['galerie'], true),
('Coffre de toit', 'accessoires', 'transport', ARRAY['coffre galerie'], true),
('Porte-vélos sur attelage', 'accessoires', 'transport', ARRAY['support vélo'], false),
('Porte-vélos sur hayon', 'accessoires', 'transport', ARRAY['rack vélo'], false),
('Porte-skis', 'accessoires', 'transport', ARRAY['support ski'], false),

-- Housses et protections
('Housse de voiture', 'accessoires', 'protection', ARRAY['bâche auto'], false),
('Housse de siège', 'accessoires', 'protection', ARRAY['couvre siège'], true),
('Pare-soleil avant', 'accessoires', 'protection', ARRAY['pare-soleil pare-brise'], true),
('Pare-soleil latéral', 'accessoires', 'protection', ARRAY['pare-soleil vitre'], false),
('Protection de coffre', 'accessoires', 'protection', ARRAY['bac coffre'], true),
('Grille de séparation', 'accessoires', 'protection', ARRAY['filet chien'], false),

-- Tapis et accessoires sol
('Tapis caoutchouc avant', 'accessoires', 'tapis', ARRAY['tapis sol AV'], true),
('Tapis caoutchouc arrière', 'accessoires', 'tapis', ARRAY['tapis sol AR'], false),
('Tapis velours', 'accessoires', 'tapis', ARRAY['tapis textile'], false),
('Tapis tout temps', 'accessoires', 'tapis', ARRAY['tapis hiver'], true),

-- Sécurité et signalisation
('Triangle de signalisation', 'accessoires', 'securite', ARRAY['triangle panne'], true),
('Gilet de sécurité', 'accessoires', 'securite', ARRAY['gilet jaune'], true),
('Extincteur', 'accessoires', 'securite', ARRAY['extincteur auto'], false),
('Trousse de secours', 'accessoires', 'securite', ARRAY['kit premiers soins'], false),
('Kit éthylotest', 'accessoires', 'securite', ARRAY['alcootest'], false),
('Disque de stationnement', 'accessoires', 'securite', ARRAY['disque zone bleue'], false),

-- Chargeurs et électronique
('Chargeur de batterie', 'electricite', 'chargeur', ARRAY['booster batterie'], true),
('Câbles de démarrage', 'electricite', 'cable', ARRAY['pinces démarrage'], true),
('Convertisseur 12V/220V', 'electricite', 'convertisseur', ARRAY['onduleur voiture'], false),
('Chargeur USB double', 'electronique', 'chargeur', ARRAY['adaptateur USB'], true),
('Support téléphone', 'accessoires', 'support', ARRAY['support GPS'], true),
('Dashcam', 'electronique', 'camera', ARRAY['caméra embarquée'], false),

-- Éclairage additionnel
('Lampe baladeuse', 'accessoires', 'eclairage', ARRAY['lampe atelier'], false),
('Lampe LED rechargeable', 'accessoires', 'eclairage', ARRAY['lampe torche'], false),

-- Rangement
('Organisateur de coffre', 'accessoires', 'rangement', ARRAY['bac rangement'], false),
('Sac de rangement', 'accessoires', 'rangement', ARRAY['sac coffre'], false),
('Filet de rangement', 'accessoires', 'rangement', ARRAY['filet élastique'], false),

-- Confort
('Coussin lombaire', 'accessoires', 'confort', ARRAY['support dos'], false),
('Coussin chauffant 12V', 'accessoires', 'confort', ARRAY['housse chauffante'], false),
('Ventilateur 12V', 'accessoires', 'confort', ARRAY['ventilateur portable'], false),
('Glacière 12V', 'accessoires', 'confort', ARRAY['réfrigérateur portable'], false),

-- Nettoyage et entretien
('Aspirateur 12V', 'accessoires', 'nettoyage', ARRAY['aspirateur voiture'], false),
('Éponge de lavage', 'accessoires', 'nettoyage', ARRAY['éponge auto'], true),
('Chiffon microfibre', 'accessoires', 'nettoyage', ARRAY['microfibre'], true),
('Brosse de nettoyage', 'accessoires', 'nettoyage', ARRAY['brosse jantes'], false),
('Seau de lavage', 'accessoires', 'nettoyage', ARRAY['seau auto'], false),

-- Vitres et visibilité
('Film teinté', 'vitrage', 'accessoire', ARRAY['film vitre'], false),
('Produit anti-pluie', 'accessoires', 'produit', ARRAY['traitement pare-brise'], false),

-- Plaques et stickers
('Plaque d''immatriculation', 'accessoires', 'plaque', ARRAY['plaque minéralogique'], true),
('Support de plaque', 'accessoires', 'plaque', ARRAY['cadre plaque'], false),
('Vignette Crit''Air', 'accessoires', 'vignette', ARRAY['pastille pollution'], true),
('Vignette assurance', 'accessoires', 'vignette', ARRAY['vignette pare-brise'], false),

-- Parfums et désodorisants
('Parfum d''habitacle', 'accessoires', 'parfum', ARRAY['désodorisant'], true),
('Diffuseur de parfum', 'accessoires', 'parfum', ARRAY['clip parfum'], false),

-- Divers carrosserie
('Antenne', 'carrosserie', 'antenne', ARRAY['antenne radio'], true),
('Antenne courte', 'carrosserie', 'antenne', ARRAY['antenne shark'], false),
('Antenne aileron de requin', 'carrosserie', 'antenne', ARRAY['shark fin'], false),
('Becquet', 'carrosserie', 'aerodynamisme', ARRAY['aileron'], false),
('Spoiler avant', 'carrosserie', 'aerodynamisme', ARRAY['lèvre avant'], false),
('Bas de caisse', 'carrosserie', 'aerodynamisme', ARRAY['jupes latérales'], false),
('Pare-chocs avant', 'carrosserie', 'pare-chocs', ARRAY['bouclier AV'], true),
('Pare-chocs arrière', 'carrosserie', 'pare-chocs', ARRAY['bouclier AR'], true),
('Grille de calandre', 'carrosserie', 'grille', ARRAY['calandre'], true),
('Aile avant gauche', 'carrosserie', 'aile', ARRAY['aile AV G'], true),
('Aile avant droite', 'carrosserie', 'aile', ARRAY['aile AV D'], true),
('Aile arrière gauche', 'carrosserie', 'aile', ARRAY['aile AR G'], false),
('Aile arrière droite', 'carrosserie', 'aile', ARRAY['aile AR D'], false),

-- Pare-brise et vitrage
('Pare-brise', 'vitrage', 'pare-brise', ARRAY['pare-brise avant'], true),
('Lunette arrière', 'vitrage', 'lunette', ARRAY['vitre AR'], true),
('Vitre latérale avant gauche', 'vitrage', 'vitre', ARRAY['vitre custode AV G'], false),
('Vitre latérale avant droite', 'vitrage', 'vitre', ARRAY['vitre custode AV D'], false),
('Joint de pare-brise', 'vitrage', 'joint', ARRAY['joint pare-brise'], true),
('Joint de lunette', 'vitrage', 'joint', ARRAY['joint vitre AR'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Pneu été',
  'Pneu hiver',
  'Jante aluminium',
  'Capteur TPMS',
  'Chaînes à neige',
  'Attelage',
  'Barre de toit',
  'Tapis caoutchouc avant',
  'Triangle de signalisation',
  'Gilet de sécurité',
  'Chargeur de batterie',
  'Support téléphone',
  'Plaque d''immatriculation',
  'Pare-brise',
  'Pare-chocs avant',
  'Aile avant gauche'
);
