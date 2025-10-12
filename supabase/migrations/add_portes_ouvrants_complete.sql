-- Ajout complet portes, hayon et ouvrants

-- ========================================
-- PORTES / HAYON / OUVRANTS
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Portes
('Porte avant gauche', 'carrosserie', 'porte', ARRAY['porte AV G'], true),
('Porte avant droite', 'carrosserie', 'porte', ARRAY['porte AV D'], true),
('Porte arrière gauche', 'carrosserie', 'porte', ARRAY['porte AR G'], true),
('Porte arrière droite', 'carrosserie', 'porte', ARRAY['porte AR D'], true),
('Peau de porte avant gauche', 'carrosserie', 'porte', ARRAY['tôle porte AV G'], false),
('Peau de porte avant droite', 'carrosserie', 'porte', ARRAY['tôle porte AV D'], false),

-- Charnières de porte
('Charnière de porte avant gauche supérieure', 'carrosserie', 'fixation', ARRAY['charnière haute AV G'], false),
('Charnière de porte avant gauche inférieure', 'carrosserie', 'fixation', ARRAY['charnière basse AV G'], false),
('Charnière de porte avant droite supérieure', 'carrosserie', 'fixation', ARRAY['charnière haute AV D'], false),
('Charnière de porte avant droite inférieure', 'carrosserie', 'fixation', ARRAY['charnière basse AV D'], false),
('Limiteur de porte avant gauche', 'carrosserie', 'fixation', ARRAY['butée porte AV G'], true),
('Limiteur de porte avant droit', 'carrosserie', 'fixation', ARRAY['butée porte AV D'], true),

-- Serrures et verrous
('Serrure de porte avant gauche', 'carrosserie', 'serrure', ARRAY['gâche porte AV G'], true),
('Serrure de porte avant droite', 'carrosserie', 'serrure', ARRAY['gâche porte AV D'], true),
('Serrure de porte arrière gauche', 'carrosserie', 'serrure', ARRAY['gâche porte AR G'], false),
('Serrure de porte arrière droite', 'carrosserie', 'serrure', ARRAY['gâche porte AR D'], false),
('Barillet de porte avant gauche', 'carrosserie', 'serrure', ARRAY['cylindre porte AV G'], true),
('Barillet de porte avant droit', 'carrosserie', 'serrure', ARRAY['cylindre porte AV D'], true),
('Câble de serrure de porte', 'carrosserie', 'serrure', ARRAY['tringlerie serrure'], false),
('Gâche de porte', 'carrosserie', 'serrure', ARRAY['pêne porte'], false),

-- Poignées
('Poignée extérieure de porte avant gauche', 'carrosserie', 'poignee', ARRAY['poignée ext AV G'], true),
('Poignée extérieure de porte avant droite', 'carrosserie', 'poignee', ARRAY['poignée ext AV D'], true),
('Poignée extérieure de porte arrière gauche', 'carrosserie', 'poignee', ARRAY['poignée ext AR G'], false),
('Poignée extérieure de porte arrière droite', 'carrosserie', 'poignee', ARRAY['poignée ext AR D'], false),
('Poignée intérieure de porte avant gauche', 'carrosserie', 'poignee', ARRAY['poignée int AV G'], false),
('Poignée intérieure de porte avant droite', 'carrosserie', 'poignee', ARRAY['poignée int AV D'], false),
('Poignée intérieure de porte arrière gauche', 'carrosserie', 'poignee', ARRAY['poignée int AR G'], false),
('Poignée intérieure de porte arrière droite', 'carrosserie', 'poignee', ARRAY['poignée int AR D'], false),

-- Lève-vitres
('Lève-vitre électrique avant gauche', 'carrosserie', 'leve-vitre', ARRAY['moteur vitre AV G'], true),
('Lève-vitre électrique avant droit', 'carrosserie', 'leve-vitre', ARRAY['moteur vitre AV D'], true),
('Lève-vitre électrique arrière gauche', 'carrosserie', 'leve-vitre', ARRAY['moteur vitre AR G'], false),
('Lève-vitre électrique arrière droit', 'carrosserie', 'leve-vitre', ARRAY['moteur vitre AR D'], false),
('Mécanisme de lève-vitre avant gauche', 'carrosserie', 'leve-vitre', ARRAY['rail vitre AV G'], true),
('Mécanisme de lève-vitre avant droit', 'carrosserie', 'leve-vitre', ARRAY['rail vitre AV D'], true),
('Moteur de lève-vitre avant gauche', 'carrosserie', 'leve-vitre', ARRAY['servo vitre AV G'], true),
('Moteur de lève-vitre avant droit', 'carrosserie', 'leve-vitre', ARRAY['servo vitre AV D'], true),
('Contacteur de lève-vitre avant gauche', 'carrosserie', 'commande', ARRAY['bouton vitre AV G'], true),
('Contacteur de lève-vitre avant droit', 'carrosserie', 'commande', ARRAY['bouton vitre AV D'], true),
('Câble de lève-vitre', 'carrosserie', 'leve-vitre', ARRAY['tringlerie vitre'], false),

-- Vitres
('Vitre de porte avant gauche', 'vitrage', 'vitre', ARRAY['glace AV G'], true),
('Vitre de porte avant droite', 'vitrage', 'vitre', ARRAY['glace AV D'], true),
('Vitre de porte arrière gauche', 'vitrage', 'vitre', ARRAY['glace AR G'], false),
('Vitre de porte arrière droite', 'vitrage', 'vitre', ARRAY['glace AR D'], false),
('Déflecteur de vitre avant gauche', 'carrosserie', 'aerodynamisme', ARRAY['bavette vitre AV G'], false),
('Déflecteur de vitre avant droit', 'carrosserie', 'aerodynamisme', ARRAY['bavette vitre AV D'], false),
('Joint de vitre avant gauche', 'carrosserie', 'joint', ARRAY['joint glace AV G'], false),
('Joint de vitre avant droit', 'carrosserie', 'joint', ARRAY['joint glace AV D'], false),

-- Rétroviseurs extérieurs
('Rétroviseur extérieur gauche', 'carrosserie', 'retroviseur', ARRAY['rétro ext G'], true),
('Rétroviseur extérieur droit', 'carrosserie', 'retroviseur', ARRAY['rétro ext D'], true),
('Glace de rétroviseur gauche', 'vitrage', 'retroviseur', ARRAY['miroir rétro G'], true),
('Glace de rétroviseur droit', 'vitrage', 'retroviseur', ARRAY['miroir rétro D'], true),
('Coque de rétroviseur gauche', 'carrosserie', 'retroviseur', ARRAY['coque rétro G'], true),
('Coque de rétroviseur droit', 'carrosserie', 'retroviseur', ARRAY['coque rétro D'], true),
('Moteur de rétroviseur électrique gauche', 'carrosserie', 'retroviseur', ARRAY['servo rétro G'], false),
('Moteur de rétroviseur électrique droit', 'carrosserie', 'retroviseur', ARRAY['servo rétro D'], false),
('Support de rétroviseur gauche', 'carrosserie', 'retroviseur', ARRAY['pied rétro G'], false),
('Support de rétroviseur droit', 'carrosserie', 'retroviseur', ARRAY['pied rétro D'], false),
('Clignotant de rétroviseur gauche', 'eclairage', 'clignotant', ARRAY['répétiteur rétro G'], true),
('Clignotant de rétroviseur droit', 'eclairage', 'clignotant', ARRAY['répétiteur rétro D'], true),

-- Hayon et coffre
('Hayon', 'carrosserie', 'hayon', ARRAY['coffre arrière'], true),
('Vérins de hayon', 'carrosserie', 'hayon', ARRAY['amortisseurs hayon'], true),
('Serrure de hayon', 'carrosserie', 'serrure', ARRAY['gâche hayon'], true),
('Poignée de hayon', 'carrosserie', 'poignee', ARRAY['poignée coffre'], true),
('Contacteur de hayon', 'electronique', 'contacteur', ARRAY['switch hayon'], false),
('Moteur de hayon électrique', 'carrosserie', 'hayon', ARRAY['servo hayon'], false),
('Vitre de hayon', 'vitrage', 'vitre', ARRAY['lunette AR'], true),

-- Capot
('Capot avant', 'carrosserie', 'capot', ARRAY['capot moteur'], true),
('Charnière de capot gauche', 'carrosserie', 'fixation', ARRAY['fixation capot G'], false),
('Charnière de capot droite', 'carrosserie', 'fixation', ARRAY['fixation capot D'], false),
('Vérin de capot gauche', 'carrosserie', 'capot', ARRAY['amortisseur capot G'], true),
('Vérin de capot droit', 'carrosserie', 'capot', ARRAY['amortisseur capot D'], true),
('Serrure de capot', 'carrosserie', 'serrure', ARRAY['gâche capot'], true),
('Câble de capot', 'carrosserie', 'capot', ARRAY['tringlerie capot'], true),
('Contacteur de capot', 'electronique', 'contacteur', ARRAY['switch capot'], false),

-- Trappe à essence
('Trappe à essence', 'carburant', 'trappe', ARRAY['volet carburant'], true),
('Bouchon de réservoir avec trappe', 'carburant', 'trappe', ARRAY['bouchon avec volet'], false),
('Câble de trappe à essence', 'carburant', 'trappe', ARRAY['câble ouverture'], false),
('Moteur de trappe à essence électrique', 'carburant', 'trappe', ARRAY['servo trappe'], false),

-- Joints et protections
('Joint de porte avant gauche', 'carrosserie', 'joint', ARRAY['joint étanchéité AV G'], true),
('Joint de porte avant droite', 'carrosserie', 'joint', ARRAY['joint étanchéité AV D'], true),
('Joint de porte arrière gauche', 'carrosserie', 'joint', ARRAY['joint étanchéité AR G'], false),
('Joint de porte arrière droite', 'carrosserie', 'joint', ARRAY['joint étanchéité AR D'], false),
('Joint de hayon', 'carrosserie', 'joint', ARRAY['joint coffre'], true),
('Joint de capot', 'carrosserie', 'joint', ARRAY['joint capot moteur'], false),
('Baguette de protection de porte gauche', 'carrosserie', 'protection', ARRAY['protection latérale G'], false),
('Baguette de protection de porte droite', 'carrosserie', 'protection', ARRAY['protection latérale D'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Porte avant gauche',
  'Porte avant droite',
  'Serrure de porte avant gauche',
  'Serrure de porte avant droite',
  'Poignée extérieure de porte avant gauche',
  'Lève-vitre électrique avant gauche',
  'Lève-vitre électrique avant droit',
  'Rétroviseur extérieur gauche',
  'Rétroviseur extérieur droit',
  'Glace de rétroviseur gauche',
  'Glace de rétroviseur droit',
  'Hayon',
  'Capot avant',
  'Vitre de porte avant gauche',
  'Vitre de porte avant droite'
);
