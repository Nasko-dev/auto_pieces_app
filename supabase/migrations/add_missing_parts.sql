-- Ajout de pièces manquantes importantes dans la base de données

-- ========================================
-- MOTEUR (pièces manquantes)
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Arbre d''équilibrage', 'moteur', 'mecanique', ARRAY['balancier'], false),
('Bielle de connexion', 'moteur', 'mecanique', ARRAY['bielle moteur'], false),
('Bouchon d''huile', 'moteur', 'fluides', ARRAY['bouchon de vidange'], true),
('Bouchon de radiateur', 'moteur', 'refroidissement', ARRAY['bouchon vase expansion'], false),
('Cache courroie', 'moteur', 'protection', ARRAY['carter de courroie'], false),
('Cache culbuteurs', 'moteur', 'protection', ARRAY['couvre culbuteurs'], false),
('Clapet anti-retour', 'moteur', 'mecanique', ARRAY['valve anti-retour'], false),
('Culbuteur', 'moteur', 'distribution', ARRAY['poussoir'], false),
('Filtre à particules', 'moteur', 'echappement', ARRAY['FAP', 'DPF'], true),
('Jauge d''huile', 'moteur', 'controle', ARRAY['tige de niveau'], false),
('Joint de cache culbuteur', 'moteur', 'etancheite', ARRAY['joint couvre culasse'], false),
('Joint de carter', 'moteur', 'etancheite', ARRAY['joint carter huile'], false),
('Joint spy de vilebrequin', 'moteur', 'etancheite', ARRAY['joint spi vilo'], true),
('Kit de courroie accessoire', 'moteur', 'distribution', ARRAY['courroies accessoires'], false),
('Palier de vilebrequin', 'moteur', 'mecanique', ARRAY['coussinet'], false),
('Pipe d''admission', 'moteur', 'admission', ARRAY['tubulure admission'], true),
('Poulie de vilebrequin', 'moteur', 'distribution', ARRAY['poulie vilo'], false),
('Poulie de distribution', 'moteur', 'distribution', ARRAY['poulies arbre à cames'], false),
('Support de filtre à huile', 'moteur', 'filtration', ARRAY['porte filtre'], false),
('Tendeur automatique', 'moteur', 'distribution', ARRAY['tendeur courroie'], false),

-- ========================================
-- INTÉRIEUR (pièces détaillées manquantes)
-- ========================================
('Aerateur de tableau de bord', 'interieur', 'ventilation', ARRAY['bouche d''air', 'grille aération'], true),
('Applique de porte', 'interieur', 'habillage', ARRAY['garniture porte'], false),
('Baguette de seuil', 'interieur', 'protection', ARRAY['seuil de porte'], false),
('Bouton de commande', 'interieur', 'commande', ARRAY['interrupteur'], false),
('Cache airbag passager', 'interieur', 'securite', ARRAY['trappe airbag'], false),
('Cache colonne direction', 'interieur', 'habillage', ARRAY['garniture colonne'], false),
('Cache levier de vitesse', 'interieur', 'habillage', ARRAY['soufflet levier'], true),
('Cache pédale', 'interieur', 'habillage', ARRAY['couvre pédale'], false),
('Cache prise USB', 'interieur', 'accessoire', ARRAY['trappe USB'], false),
('Ciel de toit', 'interieur', 'habillage', ARRAY['pavillon'], true),
('Colonne centrale', 'interieur', 'structure', ARRAY['montant B'], false),
('Commande lève-vitre', 'interieur', 'commande', ARRAY['bouton vitre électrique'], true),
('Commande rétroviseur', 'interieur', 'commande', ARRAY['bouton rétro'], false),
('Commande siège chauffant', 'interieur', 'confort', ARRAY['bouton chauffage siège'], false),
('Console de toit', 'interieur', 'accessoire', ARRAY['plafonnier console'], false),
('Garniture montant A', 'interieur', 'habillage', ARRAY['habillage pied'], false),
('Garniture montant B', 'interieur', 'habillage', ARRAY['cache montant central'], false),
('Garniture montant C', 'interieur', 'habillage', ARRAY['cache montant arrière'], false),
('Garniture seuil de porte', 'interieur', 'habillage', ARRAY['baguette seuil'], false),
('Levier frein à main', 'interieur', 'commande', ARRAY['manette frein'], true),
('Miroir de courtoisie', 'interieur', 'accessoire', ARRAY['miroir pare-soleil'], false),
('Module airbag', 'interieur', 'securite', ARRAY['boîtier airbag'], true),
('Panneau de portière', 'interieur', 'habillage', ARRAY['garniture porte complète'], true),
('Pommeau de frein à main', 'interieur', 'habillage', ARRAY['poignée frein'], false),
('Poignée maintien', 'interieur', 'accessoire', ARRAY['poignée de toit'], false),
('Rail de siège', 'interieur', 'sieges', ARRAY['glissière siège'], true),
('Sélecteur de vitesse', 'interieur', 'transmission', ARRAY['levier boite auto'], false),
('Support GPS', 'interieur', 'accessoire', ARRAY['socle navigation'], false),
('Têtière', 'interieur', 'sieges', ARRAY['repose-tête'], false),
('Trappe à carburant intérieure', 'interieur', 'commande', ARRAY['tirette trappe'], false),

-- ========================================
-- CARROSSERIE (pièces manquantes)
-- ========================================
('Absorbeur de choc', 'carrosserie', 'protection', ARRAY['poutre choc'], true),
('Agrafe de pare-chocs', 'carrosserie', 'fixation', ARRAY['clip pare-chocs'], false),
('Arche de toit', 'carrosserie', 'structure', ARRAY['arceau'], false),
('Baguette de porte', 'carrosserie', 'protection', ARRAY['jonc porte'], false),
('Cache crochet remorquage', 'carrosserie', 'protection', ARRAY['trappe remorquage'], false),
('Cache phare', 'carrosserie', 'optique', ARRAY['enjoliveur phare'], false),
('Calandre supérieure', 'carrosserie', 'facade', ARRAY['grille haute'], false),
('Calandre inférieure', 'carrosserie', 'facade', ARRAY['grille basse'], true),
('Doublure d''aile', 'carrosserie', 'protection', ARRAY['passage roue'], false),
('Écope d''air', 'carrosserie', 'aero', ARRAY['prise d''air'], false),
('Élargisseur d''aile', 'carrosserie', 'protection', ARRAY['bavette d''aile'], false),
('Extension de pare-chocs', 'carrosserie', 'protection', ARRAY['lèvre pare-chocs'], false),
('Joint de becquet', 'carrosserie', 'etancheite', ARRAY['joint aileron'], false),
('Joint de capot', 'carrosserie', 'etancheite', ARRAY['joint de bonnet'], false),
('Joint de custode', 'carrosserie', 'etancheite', ARRAY['joint vitre latérale'], false),
('Joint de hayon', 'carrosserie', 'etancheite', ARRAY['joint coffre'], true),
('Longeron', 'carrosserie', 'structure', ARRAY['traverse châssis'], false),
('Montant de pare-brise', 'carrosserie', 'structure', ARRAY['pied de pare-brise'], false),
('Panneau de hayon', 'carrosserie', 'structure', ARRAY['tôle hayon'], false),
('Panneau latéral', 'carrosserie', 'structure', ARRAY['flanc'], false),
('Passage de roue avant', 'carrosserie', 'protection', ARRAY['doublure AV'], true),
('Passage de roue arrière', 'carrosserie', 'protection', ARRAY['doublure AR'], true),
('Renfort de pare-chocs', 'carrosserie', 'structure', ARRAY['poutre'], true),
('Support de calandre', 'carrosserie', 'fixation', ARRAY['cadre grille'], false),
('Traverse de capot', 'carrosserie', 'structure', ARRAY['renfort capot'], false),
('Traverse de pare-chocs', 'carrosserie', 'structure', ARRAY['support pare-chocs'], false),
('Traverse de plancher', 'carrosserie', 'structure', ARRAY['traverse soubassement'], false),

-- ========================================
-- TRANSMISSION (pièces manquantes)
-- ========================================
('Arbre primaire', 'transmission', 'boite', ARRAY['arbre d''entrée'], false),
('Arbre secondaire', 'transmission', 'boite', ARRAY['arbre de sortie'], false),
('Carter de boîte', 'transmission', 'protection', ARRAY['carter transmission'], false),
('Cloche d''embrayage', 'transmission', 'embrayage', ARRAY['volant récepteur'], false),
('Fourchette d''embrayage', 'transmission', 'embrayage', ARRAY['fourchette débrayage'], false),
('Joint de boîte de vitesses', 'transmission', 'etancheite', ARRAY['joint BV'], true),
('Kit soufflet de cardan', 'transmission', 'protection', ARRAY['soufflets cardans'], true),
('Moyeu de transmission', 'transmission', 'transmission', ARRAY['moyeu cardan'], false),
('Palier de boîte', 'transmission', 'boite', ARRAY['roulement BV'], false),
('Plateau de pression', 'transmission', 'embrayage', ARRAY['mécanisme embrayage'], true),
('Selecteur de vitesses', 'transmission', 'commande', ARRAY['fourchette vitesses'], false),
('Soufflet de levier de vitesses', 'transmission', 'protection', ARRAY['cache levier'], false),
('Support de boîte', 'transmission', 'fixation', ARRAY['silent-bloc BV'], false),
('Synchroniseur', 'transmission', 'boite', ARRAY['synchro'], false),

-- ========================================
-- FREINAGE (pièces manquantes détaillées)
-- ========================================
('Amplificateur de freinage', 'freinage', 'assistance', ARRAY['servo'], true),
('Câble de frein de stationnement', 'freinage', 'commande', ARRAY['câble frein main'], true),
('Capteur de frein', 'freinage', 'electronique', ARRAY['contacteur stop'], false),
('Chape de frein', 'freinage', 'fixation', ARRAY['support étrier'], false),
('Étrier de frein arrière', 'freinage', 'mecanique', ARRAY['étrier AR'], true),
('Étrier de frein avant', 'freinage', 'mecanique', ARRAY['étrier AV'], true),
('Flexible d''étrier', 'freinage', 'hydraulique', ARRAY['durite étrier'], false),
('Kit de mâchoires', 'freinage', 'mecanique', ARRAY['garnitures frein'], true),
('Levier de frein à main', 'freinage', 'commande', ARRAY['manette FDM'], false),
('Liquide de frein DOT4', 'freinage', 'fluide', ARRAY['DOT 4'], false),
('Plaquettes avant', 'freinage', 'mecanique', ARRAY['plaquettes AV'], true),
('Plaquettes arrière', 'freinage', 'mecanique', ARRAY['plaquettes AR'], true),
('Porte-plaquettes', 'freinage', 'fixation', ARRAY['support plaquettes'], false),
('Purgeur de frein', 'freinage', 'entretien', ARRAY['vis de purge'], false),
('Répartiteur de freinage', 'freinage', 'hydraulique', ARRAY['compensateur'], false),

-- ========================================
-- ÉLECTRONIQUE (pièces modernes manquantes)
-- ========================================
('Antenne GPS', 'electronique', 'multimedia', ARRAY['capteur GPS'], false),
('Boîtier télématique', 'electronique', 'communication', ARRAY['module télématique'], false),
('Capteur d''humidité', 'electronique', 'confort', ARRAY['capteur pluie'], false),
('Capteur d''usure plaquettes', 'electronique', 'freinage', ARRAY['témoin plaquettes'], false),
('Capteur de luminosité', 'electronique', 'eclairage', ARRAY['cellule photoélectrique'], false),
('Capteur de qualité d''air', 'electronique', 'climatisation', ARRAY['capteur pollution'], false),
('Chargeur sans fil', 'electronique', 'multimedia', ARRAY['charge induction'], false),
('Module Bluetooth', 'electronique', 'multimedia', ARRAY['kit mains libres'], false),
('Prise OBD', 'electronique', 'diagnostic', ARRAY['connecteur diagnostic'], false),
('Système de navigation', 'electronique', 'multimedia', ARRAY['GPS intégré'], true),
('Système Start-Stop', 'electronique', 'gestion moteur', ARRAY['module Start Stop'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour du compteur pour marquer certaines pièces comme populaires
UPDATE public.parts
SET is_popular = true
WHERE name IN (
  'Bouchon d''huile',
  'Filtre à particules',
  'Joint spy de vilebrequin',
  'Pipe d''admission',
  'Cache levier de vitesse',
  'Commande lève-vitre',
  'Module airbag',
  'Panneau de portière',
  'Rail de siège',
  'Calandre inférieure',
  'Joint de hayon',
  'Passage de roue avant',
  'Passage de roue arrière',
  'Renfort de pare-chocs',
  'Joint de boîte de vitesses',
  'Kit soufflet de cardan',
  'Plateau de pression',
  'Amplificateur de freinage',
  'Câble de frein de stationnement',
  'Étrier de frein arrière',
  'Étrier de frein avant',
  'Kit de mâchoires',
  'Plaquettes avant',
  'Plaquettes arrière',
  'Système de navigation'
);
