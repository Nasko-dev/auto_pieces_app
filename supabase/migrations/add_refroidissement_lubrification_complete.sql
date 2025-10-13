-- Ajout complet refroidissement et lubrification

-- ========================================
-- REFROIDISSEMENT & LUBRIFICATION
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Radiateur et circuit de refroidissement
('Radiateur de refroidissement', 'moteur', 'refroidissement', ARRAY['radiateur moteur'], true),
('Radiateur d''huile moteur', 'moteur', 'lubrification', ARRAY['échangeur huile moteur'], true),
('Vase d''expansion', 'moteur', 'refroidissement', ARRAY['bocal liquide refroidissement'], true),
('Bouchon de vase d''expansion', 'moteur', 'refroidissement', ARRAY['bouchon bocal'], true),
('Bouchon de radiateur', 'moteur', 'refroidissement', ARRAY['bouchon pression'], false),
('Support de radiateur', 'moteur', 'fixation', ARRAY['fixation radiateur'], false),

-- Durites de refroidissement
('Durite de radiateur supérieure', 'moteur', 'refroidissement', ARRAY['durite haute radiateur'], true),
('Durite de radiateur inférieure', 'moteur', 'refroidissement', ARRAY['durite basse radiateur'], true),
('Durite de chauffage aller', 'moteur', 'refroidissement', ARRAY['durite chauffage AV'], true),
('Durite de chauffage retour', 'moteur', 'refroidissement', ARRAY['durite chauffage AR'], false),
('Durite de by-pass', 'moteur', 'refroidissement', ARRAY['durite dérivation'], false),
('Durite d''expansion', 'moteur', 'refroidissement', ARRAY['durite bocal'], false),
('Té de durite de refroidissement', 'moteur', 'refroidissement', ARRAY['raccord en T'], false),
('Collier de durite', 'moteur', 'fixation', ARRAY['collier serrage durite'], true),

-- Pompe à eau
('Pompe à eau', 'moteur', 'refroidissement', ARRAY['water pump'], true),
('Joint de pompe à eau', 'moteur', 'joint', ARRAY['joint water pump'], true),
('Poulie de pompe à eau', 'moteur', 'refroidissement', ARRAY['poulie pompe'], false),

-- Calorstat et thermostat
('Calorstat', 'moteur', 'refroidissement', ARRAY['thermostat', 'thermostat d''eau'], true),
('Boîtier de calorstat', 'moteur', 'refroidissement', ARRAY['corps thermostat'], true),
('Joint de boîtier de calorstat', 'moteur', 'joint', ARRAY['joint thermostat'], true),
('Capteur de température d''eau', 'moteur', 'capteur', ARRAY['sonde température LDR'], true),

-- Ventilateur
('Ventilateur de refroidissement', 'moteur', 'refroidissement', ARRAY['ventilo moteur'], true),
('Motoventilateur', 'moteur', 'refroidissement', ARRAY['groupe motoventilateur'], true),
('Moteur de ventilateur', 'moteur', 'refroidissement', ARRAY['moteur ventilo'], true),
('Pales de ventilateur', 'moteur', 'refroidissement', ARRAY['hélice ventilo'], false),
('Coupleur de ventilateur', 'moteur', 'refroidissement', ARRAY['visco coupleur'], false),
('Relais de ventilateur', 'moteur', 'electronique', ARRAY['relais ventilo'], false),
('Résistance de ventilateur', 'moteur', 'electronique', ARRAY['résistance ventilo'], true),
('Thermocontact de ventilateur', 'moteur', 'capteur', ARRAY['contacteur ventilo'], false),

-- Liquide de refroidissement
('Liquide de refroidissement concentré', 'moteur', 'fluide', ARRAY['antigel concentré'], true),
('Liquide de refroidissement prêt à l''emploi', 'moteur', 'fluide', ARRAY['LDR -25°C'], true),
('Liquide de refroidissement universel', 'moteur', 'fluide', ARRAY['antigel universel'], false),
('Additif étanchéité circuit refroidissement', 'moteur', 'additif', ARRAY['stop fuite LDR'], false),

-- Radiateur de chauffage
('Radiateur de chauffage', 'climatisation', 'chauffage', ARRAY['radiateur habitacle'], true),
('Vanne de chauffage', 'climatisation', 'chauffage', ARRAY['robinet chauffage'], false),
('Résistance de chauffage', 'climatisation', 'chauffage', ARRAY['résistance pulseur'], true),
('Pulseur d''air', 'climatisation', 'ventilation', ARRAY['ventilateur habitacle'], true),

-- Huiles moteur
('Huile moteur 0W20', 'moteur', 'fluide', ARRAY['huile 0W20'], true),
('Huile moteur 5W30', 'moteur', 'fluide', ARRAY['huile 5W30'], true),
('Huile moteur 5W40', 'moteur', 'fluide', ARRAY['huile 5W40'], true),
('Huile moteur 10W40', 'moteur', 'fluide', ARRAY['huile 10W40'], true),
('Huile moteur 15W40', 'moteur', 'fluide', ARRAY['huile 15W40'], false),
('Huile synthétique', 'moteur', 'fluide', ARRAY['huile 100% synthèse'], true),
('Huile semi-synthétique', 'moteur', 'fluide', ARRAY['huile technosynthèse'], true),
('Huile minérale', 'moteur', 'fluide', ARRAY['huile classique'], false),
('Huile diesel', 'moteur', 'fluide', ARRAY['huile moteur diesel'], true),
('Huile essence', 'moteur', 'fluide', ARRAY['huile moteur essence'], true),

-- Additifs huile
('Additif huile moteur', 'moteur', 'additif', ARRAY['traitement huile'], false),
('Additif anti-fuite huile', 'moteur', 'additif', ARRAY['stop fuite huile'], false),
('Nettoyant moteur', 'moteur', 'additif', ARRAY['flush moteur'], true),
('Additif régénérant moteur', 'moteur', 'additif', ARRAY['céramique moteur'], false),

-- Filtration huile
('Filtre à huile', 'moteur', 'filtre', ARRAY['oil filter'], true),
('Filtre à huile cartouche', 'moteur', 'filtre', ARRAY['élément filtrant'], true),
('Filtre à huile vissant', 'moteur', 'filtre', ARRAY['filtre à vis'], true),
('Joint de filtre à huile', 'moteur', 'joint', ARRAY['joint torique filtre'], false),
('Clé à filtre à huile', 'moteur', 'outil', ARRAY['clé sangle'], false),

-- Refroidissement turbo
('Durite d''eau de turbo', 'moteur', 'refroidissement', ARRAY['durite refroidissement turbo'], true),
('Raccord d''eau de turbo', 'moteur', 'refroidissement', ARRAY['banjo eau turbo'], false),

-- Capteurs
('Capteur de température d''huile', 'moteur', 'capteur', ARRAY['sonde T° huile'], false),
('Capteur de pression d''huile', 'moteur', 'capteur', ARRAY['manocontact'], true),
('Capteur de niveau d''huile', 'moteur', 'capteur', ARRAY['sonde niveau huile'], false),
('Capteur de température LDR', 'moteur', 'capteur', ARRAY['sonde eau'], true),
('Jauge de température', 'moteur', 'instrument', ARRAY['indicateur température'], false),
('Jauge de pression d''huile', 'moteur', 'instrument', ARRAY['mano huile'], false),

-- Intercooler eau
('Intercooler eau-air', 'moteur', 'refroidissement', ARRAY['échangeur eau'], false),
('Pompe d''intercooler eau', 'moteur', 'refroidissement', ARRAY['pompe circuit intercooler'], false),
('Radiateur d''intercooler eau', 'moteur', 'refroidissement', ARRAY['radiateur air charge'], false),

-- Dégazage et purge
('Vis de purge de circuit de refroidissement', 'moteur', 'refroidissement', ARRAY['purgeur LDR'], false),
('Bouchon de vidange de radiateur', 'moteur', 'refroidissement', ARRAY['robinet vidange'], false),

-- Protection moteur
('Grille de radiateur', 'carrosserie', 'protection', ARRAY['calandre'], true),
('Déflecteur de radiateur', 'carrosserie', 'aerodynamisme', ARRAY['écope air'], false),
('Protection sous moteur', 'carrosserie', 'protection', ARRAY['cache sous moteur'], true),
('Bavette de protection moteur', 'carrosserie', 'protection', ARRAY['déflecteur moteur'], false),

-- Joint de circuit
('Joint de durite de refroidissement', 'moteur', 'joint', ARRAY['joint torique durite'], false),
('Joint de bride de refroidissement', 'moteur', 'joint', ARRAY['joint sortie eau'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Radiateur de refroidissement',
  'Vase d''expansion',
  'Pompe à eau',
  'Calorstat',
  'Boîtier de calorstat',
  'Ventilateur de refroidissement',
  'Motoventilateur',
  'Durite de radiateur supérieure',
  'Durite de radiateur inférieure',
  'Filtre à huile',
  'Huile moteur 5W30',
  'Huile moteur 5W40',
  'Liquide de refroidissement prêt à l''emploi',
  'Capteur de température d''eau',
  'Radiateur de chauffage',
  'Pulseur d''air'
);
