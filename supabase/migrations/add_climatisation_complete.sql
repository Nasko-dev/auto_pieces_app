-- Ajout complet climatisation

-- ========================================
-- CLIMATISATION
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Compresseur et circuit
('Compresseur de climatisation', 'climatisation', 'compresseur', ARRAY['compresseur clim'], true),
('Poulie de compresseur', 'climatisation', 'compresseur', ARRAY['poulie clim'], true),
('Embrayage de compresseur', 'climatisation', 'compresseur', ARRAY['embrayage magnétique'], true),
('Kit de réparation compresseur', 'climatisation', 'kit', ARRAY['kit joints compresseur'], false),

-- Condenseur et évaporateur
('Condenseur de climatisation', 'climatisation', 'condenseur', ARRAY['radiateur clim'], true),
('Évaporateur de climatisation', 'climatisation', 'evaporateur', ARRAY['évaporateur habitacle'], true),
('Support de condenseur', 'climatisation', 'fixation', ARRAY['fixation condenseur'], false),

-- Détendeur et filtre
('Détendeur de climatisation', 'climatisation', 'detendeur', ARRAY['vanne d''expansion'], true),
('Filtre déshydrateur', 'climatisation', 'filtre', ARRAY['bouteille filtrante'], true),
('Accumulateur de climatisation', 'climatisation', 'accumulateur', ARRAY['réservoir clim'], false),

-- Durites et tuyaux
('Durite de climatisation haute pression', 'climatisation', 'durite', ARRAY['durite HP clim'], true),
('Durite de climatisation basse pression', 'climatisation', 'durite', ARRAY['durite BP clim'], true),
('Tuyau rigide de climatisation', 'climatisation', 'durite', ARRAY['pipe clim'], false),
('Raccord de climatisation', 'climatisation', 'raccord', ARRAY['raccord rapide clim'], false),
('Joint de durite de climatisation', 'climatisation', 'joint', ARRAY['joint torique clim'], true),

-- Vannes et valves
('Vanne de service haute pression', 'climatisation', 'valve', ARRAY['valve HP'], false),
('Vanne de service basse pression', 'climatisation', 'valve', ARRAY['valve BP'], false),
('Clapet de climatisation', 'climatisation', 'valve', ARRAY['valve anti-retour clim'], false),

-- Capteurs et pressostat
('Pressostat de climatisation', 'climatisation', 'capteur', ARRAY['capteur pression clim'], true),
('Capteur de pression de climatisation', 'climatisation', 'capteur', ARRAY['sonde pression clim'], false),
('Capteur de température d''évaporateur', 'climatisation', 'capteur', ARRAY['sonde évaporateur'], false),
('Capteur de température extérieure', 'climatisation', 'capteur', ARRAY['sonde T° extérieure'], false),
('Capteur de qualité d''air', 'climatisation', 'capteur', ARRAY['capteur AQS'], false),

-- Ventilation
('Pulseur d''air habitacle', 'climatisation', 'ventilation', ARRAY['ventilateur habitacle'], true),
('Résistance de pulseur', 'climatisation', 'ventilation', ARRAY['résistance chauffage'], true),
('Module de puissance de ventilation', 'climatisation', 'ventilation', ARRAY['variateur ventilo'], false),
('Turbine de pulseur', 'climatisation', 'ventilation', ARRAY['roue ventilateur'], false),

-- Régulation
('Boîtier de climatisation manuelle', 'climatisation', 'commande', ARRAY['commande clim manuelle'], true),
('Boîtier de climatisation automatique', 'climatisation', 'commande', ARRAY['commande clim auto'], false),
('Calculateur de climatisation', 'climatisation', 'electronique', ARRAY['module clim'], false),
('Potentiomètre de température', 'climatisation', 'commande', ARRAY['molette température'], false),
('Volet de régulation de température', 'climatisation', 'volet', ARRAY['volet mixage'], false),
('Moteur de volet de climatisation', 'climatisation', 'volet', ARRAY['servo volet'], true),
('Volet de distribution d''air', 'climatisation', 'volet', ARRAY['volet répartition'], false),

-- Gaz et huile
('Gaz réfrigérant R134a', 'climatisation', 'gaz', ARRAY['fluide frigorigène R134a'], true),
('Gaz réfrigérant R1234yf', 'climatisation', 'gaz', ARRAY['fluide frigorigène R1234yf'], true),
('Huile de compresseur PAG', 'climatisation', 'huile', ARRAY['huile clim PAG'], true),
('Huile de compresseur PAO', 'climatisation', 'huile', ARRAY['huile clim PAO'], false),
('Traceur UV pour climatisation', 'climatisation', 'additif', ARRAY['colorant UV'], false),

-- Chauffage
('Radiateur de chauffage', 'climatisation', 'chauffage', ARRAY['échangeur chauffage'], true),
('Vanne de chauffage', 'climatisation', 'chauffage', ARRAY['robinet chauffage'], false),
('Durite de radiateur de chauffage', 'climatisation', 'durite', ARRAY['durite chauffage'], true),
('Raccord de chauffage', 'climatisation', 'raccord', ARRAY['té chauffage'], false),

-- Filtres
('Filtre d''habitacle', 'climatisation', 'filtre', ARRAY['filtre à pollen'], true),
('Filtre d''habitacle au charbon actif', 'climatisation', 'filtre', ARRAY['filtre antibactérien'], true),

-- Relais et fusibles
('Relais de climatisation', 'climatisation', 'relais', ARRAY['relais compresseur'], false),
('Fusible de climatisation', 'climatisation', 'fusible', ARRAY['fusible clim'], false),

-- Nettoyage et désinfection
('Bombe de nettoyage de climatisation', 'climatisation', 'produit', ARRAY['désinfectant clim'], true),
('Produit antibactérien climatisation', 'climatisation', 'produit', ARRAY['traitement clim'], false),

-- Climatisation arrière
('Évaporateur arrière', 'climatisation', 'evaporateur', ARRAY['évaporateur AR'], false),
('Pulseur arrière', 'climatisation', 'ventilation', ARRAY['ventilateur AR'], false),
('Commande de climatisation arrière', 'climatisation', 'commande', ARRAY['réglage clim AR'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Compresseur de climatisation',
  'Condenseur de climatisation',
  'Évaporateur de climatisation',
  'Détendeur de climatisation',
  'Filtre déshydrateur',
  'Pulseur d''air habitacle',
  'Résistance de pulseur',
  'Pressostat de climatisation',
  'Gaz réfrigérant R134a',
  'Gaz réfrigérant R1234yf',
  'Filtre d''habitacle',
  'Radiateur de chauffage',
  'Bombe de nettoyage de climatisation'
);
