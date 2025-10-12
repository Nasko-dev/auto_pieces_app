-- Ajout des pièces d'intérieur détaillées manquantes
-- Basé sur la liste fournie, en excluant les pièces déjà existantes

INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES

-- ========================================
-- TABLEAU DE BORD
-- ========================================
('Garniture de tableau de bord', 'interieur', 'tableau_de_bord', ARRAY['habillage TB'], true),
('Cache inférieur de volant', 'interieur', 'tableau_de_bord', ARRAY['cache sous volant'], false),
('Cache supérieur de volant', 'interieur', 'tableau_de_bord', ARRAY['casquette volant'], false),
('Haut-parleur tableau de bord', 'interieur', 'audio', ARRAY['HP tableau bord'], false),
('Aérateurs centraux', 'interieur', 'climatisation', ARRAY['bouches centrales', 'aerateurs milieu'], true),
('Aérateurs latéraux', 'interieur', 'climatisation', ARRAY['bouches latérales'], false),
('Commande de chauffage', 'interieur', 'climatisation', ARRAY['commande climatisation'], true),
('Commande ventilation', 'interieur', 'climatisation', ARRAY['réglage ventilation'], false),
('Commande multimédia', 'interieur', 'electronique', ARRAY['bouton media'], false),
('Interrupteur feux de détresse', 'interieur', 'commande', ARRAY['warning', 'bouton warning'], true),
('Interrupteur ESP', 'interieur', 'electronique', ARRAY['bouton ESP'], false),
('Interrupteur Start-Stop', 'interieur', 'electronique', ARRAY['bouton Start Stop'], false),
('Porte-gobelet', 'interieur', 'accessoire', ARRAY['porte-boisson'], false),
('Console centrale avant', 'interieur', 'habillage', ARRAY['console AV'], true),
('Console centrale arrière', 'interieur', 'habillage', ARRAY['console AR'], false),
('Accoudoir central avant', 'interieur', 'confort', ARRAY['accoudoir AV'], true),
('Couvercle d''accoudoir', 'interieur', 'habillage', ARRAY['trappe accoudoir'], false),
('Fermeture de boîte à gants', 'interieur', 'accessoire', ARRAY['serrure boite gants'], false),
('Éclairage boîte à gants', 'interieur', 'eclairage', ARRAY['lampe boite gants'], false),
('Soufflet de levier de vitesse', 'interieur', 'habillage', ARRAY['cache levier vitesse'], true),
('Sélecteur de vitesse', 'interieur', 'transmission', ARRAY['levier BVA'], false),
('Cache levier de vitesse', 'interieur', 'habillage', ARRAY['enjoliveur levier'], false),
('Cache frein à main', 'interieur', 'habillage', ARRAY['soufflet frein main'], false),
('Cache tunnel central', 'interieur', 'habillage', ARRAY['habillage tunnel'], false),
('Support console', 'interieur', 'structure', ARRAY['cadre console'], false),
('Trappe compartiment console', 'interieur', 'accessoire', ARRAY['cache console'], false),
('Prise auxiliaire', 'interieur', 'multimedia', ARRAY['AUX', 'HDMI'], false),
('Module climatisation automatique', 'interieur', 'climatisation', ARRAY['clim auto'], false),
('Bouton démarrage', 'interieur', 'electronique', ARRAY['Start Stop'], true),
('Cache sous volant', 'interieur', 'habillage', ARRAY['cache inf volant'], false),
('Pédale d''accélérateur', 'interieur', 'commande', ARRAY['pédale gaz'], true),
('Pédale de frein', 'interieur', 'commande', ARRAY['pédale frein'], true),
('Pédale d''embrayage', 'interieur', 'commande', ARRAY['pédale embrayage'], true),
('Repose-pied conducteur', 'interieur', 'confort', ARRAY['cale-pied'], false),

-- ========================================
-- VOLANT ET DIRECTION
-- ========================================
('Cache airbag volant', 'interieur', 'securite', ARRAY['trappe airbag'], true),
('Airbag conducteur', 'interieur', 'securite', ARRAY['airbag volant'], true),
('Moyeu de volant', 'interieur', 'direction', ARRAY['hub volant'], false),
('Capteur d''angle volant', 'interieur', 'electronique', ARRAY['capteur angle direction'], false),
('Commandes au volant', 'interieur', 'multimedia', ARRAY['boutons volant'], true),
('Commodo gauche', 'interieur', 'commande', ARRAY['clignotants', 'phares'], true),
('Commodo droit', 'interieur', 'commande', ARRAY['essuie-glace'], true),
('Cardan de colonne', 'interieur', 'direction', ARRAY['UJ colonne'], false),
('Serrure de contact', 'interieur', 'securite', ARRAY['neiman'], true),
('Bague collectrice', 'interieur', 'electronique', ARRAY['spiral airbag', 'contacteur tournant'], false),

-- ========================================
-- PORTES
-- ========================================
('Garniture intérieure de porte', 'interieur', 'habillage', ARRAY['panneau porte'], true),
('Bouton de verrouillage', 'interieur', 'securite', ARRAY['verrou porte'], false),
('Bouton de rétro électrique', 'interieur', 'commande', ARRAY['commande retroviseur'], false),
('Tweeter', 'interieur', 'audio', ARRAY['haut-parleur aigu'], false),
('Panneau complet de porte', 'interieur', 'habillage', ARRAY['garniture porte complète'], true),
('Mécanisme de vitre', 'interieur', 'mecanisme', ARRAY['lève-vitre'], true),
('Charnières de porte', 'carrosserie', 'fixation', ARRAY['gonds porte'], false),
('Butée de porte', 'carrosserie', 'accessoire', ARRAY['limiteur porte'], false),
('Gâche de porte', 'carrosserie', 'serrurerie', ARRAY['gâche serrure'], false),
('Cache de montant', 'interieur', 'habillage', ARRAY['garniture montant'], false),
('Éclairage de porte', 'interieur', 'eclairage', ARRAY['témoin porte'], false),
('Grille haut-parleur', 'interieur', 'audio', ARRAY['cache HP'], false),
('Isolation phonique de porte', 'interieur', 'confort', ARRAY['mousse porte'], false),
('Film pare-eau de porte', 'interieur', 'etancheite', ARRAY['membrane porte'], false),
('Cache miroir intérieur', 'interieur', 'habillage', ARRAY['cache rétro intérieur'], false),

-- ========================================
-- SIÈGES
-- ========================================
('Siège passager', 'interieur', 'sieges', ARRAY['siège AV droit'], true),
('Siège conducteur', 'interieur', 'sieges', ARRAY['siège AV gauche'], true),
('Assise siège passager', 'interieur', 'sieges', ARRAY['assise AV droite'], false),
('Banquette arrière complète', 'interieur', 'sieges', ARRAY['banquette AR'], true),
('Dossier banquette arrière', 'interieur', 'sieges', ARRAY['dossier AR'], true),
('Assise banquette arrière', 'interieur', 'sieges', ARRAY['assise AR'], false),
('Appuie-tête avant', 'interieur', 'sieges', ARRAY['têtière AV'], true),
('Appuie-tête arrière', 'interieur', 'sieges', ARRAY['têtière AR'], false),
('Accoudoir central arrière', 'interieur', 'confort', ARRAY['accoudoir AR'], false),
('Poignée réglage dossier', 'interieur', 'mecanisme', ARRAY['manette dossier'], false),
('Poignée avance recul', 'interieur', 'mecanisme', ARRAY['levier siège'], false),
('Réglage lombaire', 'interieur', 'confort', ARRAY['soutien lombaire'], false),
('Réglage hauteur siège', 'interieur', 'mecanisme', ARRAY['vérin hauteur'], false),
('Commande électrique de siège', 'interieur', 'electronique', ARRAY['moteur siège électrique'], false),
('Glissière de siège', 'interieur', 'mecanisme', ARRAY['rail siège'], true),
('Cache rail de siège', 'interieur', 'habillage', ARRAY['cache glissière'], false),
('Airbag latéral siège', 'interieur', 'securite', ARRAY['airbag thorax'], true),
('Garniture plastique siège', 'interieur', 'habillage', ARRAY['cache siège'], false),
('Capteur de présence passager', 'interieur', 'electronique', ARRAY['détecteur occupation'], false),
('Capteur ceinture de sécurité', 'interieur', 'electronique', ARRAY['contacteur ceinture'], false),
('Housse de siège tissu', 'interieur', 'habillage', ARRAY['revêtement siège'], false),
('Housse de siège cuir', 'interieur', 'habillage', ARRAY['sellerie cuir'], false),

-- ========================================
-- TOIT ET MONTANTS
-- ========================================
('Poignée de maintien', 'interieur', 'accessoire', ARRAY['poignée plafond'], false),
('Pare-soleil conducteur', 'interieur', 'confort', ARRAY['pare-soleil gauche'], true),
('Pare-soleil passager', 'interieur', 'confort', ARRAY['pare-soleil droit'], true),
('Plafonnier avant', 'interieur', 'eclairage', ARRAY['éclairage AV'], true),
('Plafonnier arrière', 'interieur', 'eclairage', ARRAY['éclairage AR'], false),
('Éclairage d''ambiance', 'interieur', 'eclairage', ARRAY['éclairage d''ambiance'], false),
('Éclairage de lecture', 'interieur', 'eclairage', ARRAY['liseuse'], false),
('Microphone plafonnier', 'interieur', 'multimedia', ARRAY['micro bluetooth'], false),
('Garniture montant D', 'interieur', 'habillage', ARRAY['cache montant D'], false),
('Joint supérieur de porte', 'carrosserie', 'etancheite', ARRAY['joint haut porte'], false),
('Grille haut-parleur arrière', 'interieur', 'audio', ARRAY['cache HP AR'], false),

-- ========================================
-- COFFRE
-- ========================================
('Garniture de coffre', 'interieur', 'habillage', ARRAY['habillage coffre'], true),
('Moquette de coffre', 'interieur', 'habillage', ARRAY['tapis coffre'], true),
('Tablette arrière', 'interieur', 'accessoire', ARRAY['cache-bagages'], true),
('Poignée intérieure de coffre', 'interieur', 'accessoire', ARRAY['poignée ouverture int'], false),
('Poignée extérieure de coffre', 'carrosserie', 'accessoire', ARRAY['poignée ouverture ext'], true),
('Éclairage de coffre', 'interieur', 'eclairage', ARRAY['lampe coffre'], false),
('Crochet d''arrimage', 'interieur', 'accessoire', ARRAY['anneau fixation'], false),
('Cache compartiment roue de secours', 'interieur', 'habillage', ARRAY['trappe roue secours'], false),
('Moquette compartiment roue', 'interieur', 'habillage', ARRAY['tapis roue secours'], false),
('Support cric', 'interieur', 'accessoire', ARRAY['logement cric'], false),
('Trousse à outils', 'accessoires', 'secours', ARRAY['kit outils'], false),
('Garniture latérale de coffre', 'interieur', 'habillage', ARRAY['panneau lat coffre'], false),
('Trappe de coffre', 'interieur', 'accessoire', ARRAY['accès rangement'], false),
('Bouton d''ouverture coffre', 'interieur', 'commande', ARRAY['commande hayon'], false),
('Moteur ouverture coffre', 'interieur', 'electronique', ARRAY['vérin électrique'], false),
('Vérin de coffre', 'carrosserie', 'mecanisme', ARRAY['amortisseur hayon'], true),
('Joints de coffre', 'carrosserie', 'etancheite', ARRAY['joint hayon'], true),
('Serrure de coffre', 'carrosserie', 'serrurerie', ARRAY['serrure hayon'], true)

ON CONFLICT (name) DO NOTHING;

-- Marquer les pièces les plus recherchées comme populaires
UPDATE public.parts
SET is_popular = true
WHERE name IN (
  'Garniture de tableau de bord',
  'Aérateurs centraux',
  'Commande de chauffage',
  'Interrupteur feux de détresse',
  'Console centrale avant',
  'Accoudoir central avant',
  'Soufflet de levier de vitesse',
  'Bouton démarrage',
  'Pédale d''accélérateur',
  'Pédale de frein',
  'Pédale d''embrayage',
  'Cache airbag volant',
  'Airbag conducteur',
  'Commandes au volant',
  'Commodo gauche',
  'Commodo droit',
  'Serrure de contact',
  'Garniture intérieure de porte',
  'Panneau complet de porte',
  'Mécanisme de vitre',
  'Siège passager',
  'Siège conducteur',
  'Banquette arrière complète',
  'Dossier banquette arrière',
  'Appuie-tête avant',
  'Glissière de siège',
  'Airbag latéral siège',
  'Pare-soleil conducteur',
  'Pare-soleil passager',
  'Plafonnier avant',
  'Garniture de coffre',
  'Moquette de coffre',
  'Tablette arrière',
  'Poignée extérieure de coffre',
  'Vérin de coffre',
  'Joints de coffre',
  'Serrure de coffre'
);
