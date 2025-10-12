-- Ajout des pièces pour véhicules hybrides et électriques

-- ========================================
-- VÉHICULES ÉLECTRIQUES & HYBRIDES
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Batterie haute tension', 'electricite', 'stockage', ARRAY['batterie HV', 'pack batterie'], true),
('Module de batterie HV', 'electricite', 'stockage', ARRAY['cellule batterie'], false),
('BMS système gestion batterie', 'electronique', 'gestion', ARRAY['battery management system'], true),
('Câble haute tension orange', 'electricite', 'liaison', ARRAY['câble HV'], true),
('Connecteur haute tension', 'electricite', 'connexion', ARRAY['prise HV'], false),
('Onduleur de traction', 'electricite', 'conversion', ARRAY['inverter'], true),
('Moteur électrique avant', 'electricite', 'propulsion', ARRAY['moteur traction AV'], true),
('Moteur électrique arrière', 'electricite', 'propulsion', ARRAY['moteur traction AR'], true),
('Réducteur moteur électrique', 'transmission', 'boite', ARRAY['boîte réduction électrique'], true),
('Chargeur embarqué', 'electricite', 'charge', ARRAY['OBC'], true),
('Câble de charge Type 2', 'electricite', 'accessoire', ARRAY['câble recharge'], true),
('Prise de charge', 'electricite', 'connexion', ARRAY['trappe charge'], true),
('Convertisseur DC-DC', 'electricite', 'conversion', ARRAY['convertisseur haute tension'], true),
('Compresseur climatisation électrique', 'climatisation', 'compression', ARRAY['compresseur HV'], true),
('Réchauffeur électrique habitacle', 'climatisation', 'chauffage', ARRAY['PTC heater'], true),
('Pompe à chaleur', 'climatisation', 'chauffage', ARRAY['heat pump'], true),
('Refroidisseur de batterie', 'electricite', 'refroidissement', ARRAY['radiateur batterie'], true),
('Circuit de refroidissement batterie', 'electricite', 'refroidissement', ARRAY['liquide refroidissement HV'], false),
('Servomoteur de frein', 'freinage', 'assistance', ARRAY['iBooster'], true),
('Contrôleur de moteur électrique', 'electronique', 'gestion', ARRAY['ECU moteur électrique'], true),
('Contacteur haute tension', 'electricite', 'securite', ARRAY['contacteur HV'], false),
('Fusible haute tension', 'electricite', 'protection', ARRAY['fusible HV'], true),
('Isolateur haute tension', 'electricite', 'securite', ARRAY['isolateur HV'], false),
('Capteur de courant HV', 'electricite', 'mesure', ARRAY['shunt HV'], false),
('Capteur température batterie', 'electricite', 'mesure', ARRAY['sonde température HV'], false),
('Carte électronique BMS', 'electronique', 'gestion', ARRAY['PCB BMS'], false),
('Module de précharge', 'electricite', 'securite', ARRAY['précharge HV'], false),
('Résistance de précharge', 'electricite', 'securite', ARRAY['résistance HV'], false),
('Réservoir liquide refroidissement HV', 'electricite', 'refroidissement', ARRAY['vase expansion HV'], false),
('Pompe liquide refroidissement batterie', 'electricite', 'refroidissement', ARRAY['pompe circuit HV'], false)

ON CONFLICT (name) DO NOTHING;
