-- Ajout complet habitacle

-- ========================================
-- HABITACLE
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Sièges avant
('Siège avant gauche', 'interieur', 'siege', ARRAY['siège conducteur'], true),
('Siège avant droit', 'interieur', 'siege', ARRAY['siège passager'], true),
('Mécanisme de siège avant gauche', 'interieur', 'siege', ARRAY['rails siège AV G'], false),
('Mécanisme de siège avant droit', 'interieur', 'siege', ARRAY['rails siège AV D'], false),
('Moteur de siège électrique avant gauche', 'interieur', 'siege', ARRAY['servo siège G'], false),
('Moteur de siège électrique avant droit', 'interieur', 'siege', ARRAY['servo siège D'], false),
('Commande de siège électrique', 'interieur', 'commande', ARRAY['bouton réglage siège'], false),
('Airbag de siège avant gauche', 'interieur', 'securite', ARRAY['airbag latéral G'], false),
('Airbag de siège avant droit', 'interieur', 'securite', ARRAY['airbag latéral D'], false),

-- Sièges arrière
('Banquette arrière', 'interieur', 'siege', ARRAY['siège AR'], true),
('Dossier de banquette arrière', 'interieur', 'siege', ARRAY['dossier AR'], false),
('Assise de banquette arrière', 'interieur', 'siege', ARRAY['assise AR'], false),
('Accoudoir central arrière', 'interieur', 'siege', ARRAY['accoudoir AR'], false),

-- Ceintures de sécurité
('Ceinture de sécurité avant gauche', 'interieur', 'securite', ARRAY['ceinture AV G'], true),
('Ceinture de sécurité avant droite', 'interieur', 'securite', ARRAY['ceinture AV D'], true),
('Ceinture de sécurité arrière gauche', 'interieur', 'securite', ARRAY['ceinture AR G'], false),
('Ceinture de sécurité arrière droite', 'interieur', 'securite', ARRAY['ceinture AR D'], false),
('Ceinture de sécurité arrière centrale', 'interieur', 'securite', ARRAY['ceinture AR centre'], false),
('Enrouleur de ceinture avant gauche', 'interieur', 'securite', ARRAY['enrouleur AV G'], true),
('Enrouleur de ceinture avant droit', 'interieur', 'securite', ARRAY['enrouleur AV D'], true),
('Prétensionneur de ceinture avant gauche', 'interieur', 'securite', ARRAY['pretensionneur G'], false),
('Prétensionneur de ceinture avant droit', 'interieur', 'securite', ARRAY['pretensionneur D'], false),
('Boucle de ceinture', 'interieur', 'securite', ARRAY['attache ceinture'], false),

-- Tableau de bord
('Tableau de bord', 'interieur', 'planche-bord', ARRAY['planche de bord'], true),
('Compteur de vitesse', 'interieur', 'instrument', ARRAY['compteur'], true),
('Compte-tours', 'interieur', 'instrument', ARRAY['tachymètre'], false),
('Combiné d''instrumentation', 'interieur', 'instrument', ARRAY['cluster'], true),
('Écran multifonction', 'interieur', 'instrument', ARRAY['MID', 'afficheur'], false),
('Module airbag volant', 'interieur', 'securite', ARRAY['coussin volant'], true),
('Airbag passager', 'interieur', 'securite', ARRAY['airbag tableau de bord'], true),
('Cache airbag passager', 'interieur', 'habillage', ARRAY['trappe airbag'], false),
('Grille d''aération gauche', 'interieur', 'ventilation', ARRAY['diffuseur air G'], true),
('Grille d''aération droite', 'interieur', 'ventilation', ARRAY['diffuseur air D'], true),
('Grille d''aération centrale', 'interieur', 'ventilation', ARRAY['diffuseur air centre'], false),
('Boîte à gants', 'interieur', 'rangement', ARRAY['vide-poche'], true),
('Éclairage de tableau de bord', 'interieur', 'eclairage', ARRAY['LED tableau bord'], false),

-- Console centrale
('Console centrale', 'interieur', 'console', ARRAY['tunnel central'], true),
('Accoudoir central avant', 'interieur', 'console', ARRAY['accoudoir AV'], true),
('Vide-poche de console centrale', 'interieur', 'rangement', ARRAY['rangement console'], false),
('Support de gobelets', 'interieur', 'rangement', ARRAY['porte-gobelet'], false),
('Cendrier', 'interieur', 'rangement', ARRAY['bac à cendres'], false),
('Allume-cigare', 'interieur', 'accessoire', ARRAY['prise 12V'], true),
('Prise USB console', 'interieur', 'connectique', ARRAY['port USB'], false),

-- Garnitures et habillages
('Garniture de porte avant gauche', 'interieur', 'habillage', ARRAY['panneau porte AV G'], true),
('Garniture de porte avant droite', 'interieur', 'habillage', ARRAY['panneau porte AV D'], true),
('Garniture de porte arrière gauche', 'interieur', 'habillage', ARRAY['panneau porte AR G'], false),
('Garniture de porte arrière droite', 'interieur', 'habillage', ARRAY['panneau porte AR D'], false),
('Montant A habillé gauche', 'interieur', 'habillage', ARRAY['cache montant AV G'], false),
('Montant A habillé droit', 'interieur', 'habillage', ARRAY['cache montant AV D'], false),
('Montant B habillé gauche', 'interieur', 'habillage', ARRAY['cache montant central G'], false),
('Montant B habillé droit', 'interieur', 'habillage', ARRAY['cache montant central D'], false),
('Montant C habillé gauche', 'interieur', 'habillage', ARRAY['cache montant AR G'], false),
('Montant C habillé droit', 'interieur', 'habillage', ARRAY['cache montant AR D'], false),
('Bas de caisse intérieur gauche', 'interieur', 'habillage', ARRAY['seuil porte G'], false),
('Bas de caisse intérieur droit', 'interieur', 'habillage', ARRAY['seuil porte D'], false),

-- Plafond et pare-soleil
('Plafonnier', 'interieur', 'eclairage', ARRAY['éclairage intérieur'], true),
('Pare-soleil conducteur', 'interieur', 'pare-soleil', ARRAY['pare-soleil G'], true),
('Pare-soleil passager', 'interieur', 'pare-soleil', ARRAY['pare-soleil D'], true),
('Miroir de courtoisie', 'interieur', 'pare-soleil', ARRAY['miroir pare-soleil'], false),
('Ciel de toit', 'interieur', 'habillage', ARRAY['garnissage plafond'], false),
('Poignée de maintien avant gauche', 'interieur', 'equipement', ARRAY['poignée plafond AV G'], false),
('Poignée de maintien avant droite', 'interieur', 'equipement', ARRAY['poignée plafond AV D'], false),
('Poignée de maintien arrière gauche', 'interieur', 'equipement', ARRAY['poignée plafond AR G'], false),
('Poignée de maintien arrière droite', 'interieur', 'equipement', ARRAY['poignée plafond AR D'], false),

-- Moquette et tapis
('Moquette de sol', 'interieur', 'habillage', ARRAY['tapis sol'], true),
('Tapis de sol avant gauche', 'interieur', 'tapis', ARRAY['tapis AV G'], true),
('Tapis de sol avant droit', 'interieur', 'tapis', ARRAY['tapis AV D'], true),
('Tapis de sol arrière', 'interieur', 'tapis', ARRAY['tapis AR'], false),
('Passage de roue intérieur avant gauche', 'interieur', 'habillage', ARRAY['protection passage roue AV G'], false),
('Passage de roue intérieur avant droit', 'interieur', 'habillage', ARRAY['protection passage roue AV D'], false),

-- Coffre
('Garniture de coffre', 'interieur', 'coffre', ARRAY['habillage coffre'], false),
('Tablette arrière', 'interieur', 'coffre', ARRAY['plage arrière'], true),
('Cache-bagage', 'interieur', 'coffre', ARRAY['couvre-coffre'], false),
('Filet de coffre', 'interieur', 'coffre', ARRAY['filet séparation'], false),
('Crochet de coffre', 'interieur', 'coffre', ARRAY['accroche coffre'], false),

-- Accessoires intérieurs
('Rétroviseur intérieur', 'interieur', 'retroviseur', ARRAY['rétro central'], true),
('Rétroviseur intérieur jour/nuit', 'interieur', 'retroviseur', ARRAY['rétro électrochrome'], false),
('Contacteur de rétroviseur intérieur', 'interieur', 'electronique', ARRAY['bouton rétro'], false),
('Pédalier', 'interieur', 'pedale', ARRAY['ensemble pédales'], false),
('Repose-pied', 'interieur', 'pedale', ARRAY['cale-pied'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Siège avant gauche',
  'Siège avant droit',
  'Banquette arrière',
  'Ceinture de sécurité avant gauche',
  'Ceinture de sécurité avant droite',
  'Tableau de bord',
  'Combiné d''instrumentation',
  'Console centrale',
  'Garniture de porte avant gauche',
  'Garniture de porte avant droite',
  'Pare-soleil conducteur',
  'Pare-soleil passager',
  'Rétroviseur intérieur'
);
