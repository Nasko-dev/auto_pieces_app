-- Ajout complet fixations, quincaillerie et consommables

-- ========================================
-- FIXATIONS / QUINCAILLERIE / CONSOMMABLES
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Vis et boulons
('Vis de roue', 'roues', 'fixation', ARRAY['boulon roue'], true),
('Écrou de roue', 'roues', 'fixation', ARRAY['écrou jante'], true),
('Écrou antivol de roue', 'roues', 'fixation', ARRAY['écrou sécurité'], true),
('Clé antivol de roue', 'roues', 'fixation', ARRAY['adaptateur antivol'], false),
('Boulon de roue conique', 'roues', 'fixation', ARRAY['vis conique'], false),
('Boulon de roue sphérique', 'roues', 'fixation', ARRAY['vis sphérique'], false),

-- Colliers
('Collier de serrage', 'accessoires', 'fixation', ARRAY['collier durite'], true),
('Collier de serrage inox', 'accessoires', 'fixation', ARRAY['collier acier'], false),
('Collier plastique', 'accessoires', 'fixation', ARRAY['collier rilsan'], false),
('Collier de fixation', 'accessoires', 'fixation', ARRAY['collier maintien'], false),

-- Clips et agrafes
('Clip de fixation', 'accessoires', 'fixation', ARRAY['agrafe'], true),
('Clip de pare-chocs', 'carrosserie', 'fixation', ARRAY['agrafe pare-chocs'], true),
('Clip de passage de roue', 'carrosserie', 'fixation', ARRAY['agrafe passage roue'], false),
('Clip de garniture', 'interieur', 'fixation', ARRAY['agrafe habillage'], false),
('Rivet plastique', 'accessoires', 'fixation', ARRAY['rivet expansion'], false),
('Rivet aveugle', 'accessoires', 'fixation', ARRAY['rivet pop'], false),

-- Rondelles et écrous
('Rondelle plate', 'accessoires', 'fixation', ARRAY['washer'], false),
('Rondelle Grower', 'accessoires', 'fixation', ARRAY['rondelle ressort'], false),
('Rondelle frein', 'accessoires', 'fixation', ARRAY['rondelle dentelée'], false),
('Écrou autofreiné', 'accessoires', 'fixation', ARRAY['écrou nylstop'], false),
('Écrou borgne', 'accessoires', 'fixation', ARRAY['écrou aveugle'], false),

-- Joints universels
('Joint torique', 'accessoires', 'joint', ARRAY['O-ring'], true),
('Joint plat', 'accessoires', 'joint', ARRAY['joint papier'], false),
('Joint fibre', 'accessoires', 'joint', ARRAY['joint carton'], false),
('Pâte à joint', 'accessoires', 'produit', ARRAY['mastic joint'], true),
('Silicone haute température', 'accessoires', 'produit', ARRAY['silicone rouge'], true),
('Silicone pour joint de culasse', 'moteur', 'produit', ARRAY['silicone noir'], false),

-- Graisse et lubrifiants
('Graisse multifonction', 'accessoires', 'lubrifiant', ARRAY['graisse universelle'], true),
('Graisse cuivrée', 'accessoires', 'lubrifiant', ARRAY['copper grease'], true),
('Graisse au lithium', 'accessoires', 'lubrifiant', ARRAY['graisse bleue'], false),
('Graisse silicone', 'accessoires', 'lubrifiant', ARRAY['graisse caoutchouc'], false),
('Graisse pour cardans', 'transmission', 'lubrifiant', ARRAY['graisse CV'], true),
('Spray dégrippant', 'accessoires', 'lubrifiant', ARRAY['WD-40'], true),
('Spray silicone', 'accessoires', 'lubrifiant', ARRAY['silicone spray'], false),
('Huile pénétrante', 'accessoires', 'lubrifiant', ARRAY['dégrippant'], false),

-- Frein-filet et colle
('Frein-filet moyen', 'accessoires', 'produit', ARRAY['Loctite bleu'], true),
('Frein-filet fort', 'accessoires', 'produit', ARRAY['Loctite rouge'], false),
('Colle cyanoacrylate', 'accessoires', 'produit', ARRAY['super glue'], false),
('Colle époxy', 'accessoires', 'produit', ARRAY['résine époxy'], false),
('Colle pare-brise', 'vitrage', 'produit', ARRAY['mastic pare-brise'], false),

-- Produits d'entretien moteur
('Nettoyant frein', 'accessoires', 'nettoyant', ARRAY['brake cleaner'], true),
('Nettoyant carburateur', 'moteur', 'nettoyant', ARRAY['carb cleaner'], true),
('Nettoyant injecteurs', 'carburant', 'additif', ARRAY['additif injection'], true),
('Dégraissant moteur', 'accessoires', 'nettoyant', ARRAY['nettoyant bloc'], true),
('Nettoyant vanne EGR', 'moteur', 'nettoyant', ARRAY['spray EGR'], false),

-- Produits d'étanchéité
('Mastic d''étanchéité', 'accessoires', 'produit', ARRAY['mastic carrosserie'], false),
('Produit anticorrosion', 'accessoires', 'produit', ARRAY['antirouille'], true),
('Peinture antirouille', 'accessoires', 'peinture', ARRAY['rustol'], false),
('Sous-couche antirouille', 'accessoires', 'peinture', ARRAY['apprêt'], false),

-- Ruban et adhésif
('Ruban adhésif carrosserie', 'carrosserie', 'adhesif', ARRAY['double face carrosserie'], true),
('Chatterton', 'accessoires', 'adhesif', ARRAY['ruban isolant'], true),
('Scotch de protection', 'accessoires', 'adhesif', ARRAY['ruban masquage'], false),
('Bande d''étanchéité', 'accessoires', 'adhesif', ARRAY['butyl'], false),

-- Gaines et protections
('Gaine thermorétractable', 'electricite', 'protection', ARRAY['gaine thermo'], true),
('Gaine annelée', 'electricite', 'protection', ARRAY['gaine cable'], false),
('Chatterton isolant', 'electricite', 'protection', ARRAY['ruban électrique'], true),
('Mousse isolante', 'accessoires', 'isolation', ARRAY['mousse phonique'], false),

-- Produits pour pare-brise
('Liquide lave-glace concentré', 'accessoires', 'fluide', ARRAY['concentré lave-vitre'], true),
('Traitement déperlant', 'accessoires', 'produit', ARRAY['rain repellent'], false),
('Kit de réparation pare-brise', 'vitrage', 'kit', ARRAY['kit impact'], true),

-- Nettoyants intérieur
('Nettoyant plastique intérieur', 'accessoires', 'nettoyant', ARRAY['rénovateur plastique'], true),
('Nettoyant tissus', 'accessoires', 'nettoyant', ARRAY['shampoing sièges'], true),
('Nettoyant cuir', 'accessoires', 'nettoyant', ARRAY['lait cuir'], false),
('Polish tableau de bord', 'accessoires', 'nettoyant', ARRAY['brillant plastique'], false),

-- Nettoyants extérieur
('Shampoing carrosserie', 'accessoires', 'nettoyant', ARRAY['lavage auto'], true),
('Polish carrosserie', 'accessoires', 'produit', ARRAY['rénovateur peinture'], false),
('Cire de protection', 'accessoires', 'produit', ARRAY['wax'], false),
('Nettoyant jantes', 'accessoires', 'nettoyant', ARRAY['décapant jantes'], true),
('Nettoyant goudron', 'accessoires', 'nettoyant', ARRAY['détachant'], false),
('Rénovateur plastique extérieur', 'accessoires', 'produit', ARRAY['noir pare-chocs'], true),

-- Produits spéciaux
('Pâte à polir', 'accessoires', 'produit', ARRAY['compound'], false),
('Anti-buée', 'accessoires', 'produit', ARRAY['anti-fog'], false),
('Dégivreur', 'accessoires', 'produit', ARRAY['spray dégivrage'], true),
('Démonte-pneu', 'accessoires', 'produit', ARRAY['lubrifiant montage'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Vis de roue',
  'Écrou de roue',
  'Écrou antivol de roue',
  'Collier de serrage',
  'Clip de pare-chocs',
  'Joint torique',
  'Pâte à joint',
  'Graisse multifonction',
  'Graisse cuivrée',
  'Spray dégrippant',
  'Frein-filet moyen',
  'Nettoyant frein',
  'Nettoyant carburateur',
  'Produit anticorrosion',
  'Shampoing carrosserie',
  'Nettoyant jantes'
);
