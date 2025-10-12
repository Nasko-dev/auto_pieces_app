-- Ajout complet véhicule électrique et hybride

-- ========================================
-- VÉHICULE ÉLECTRIQUE / HYBRIDE
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Batteries haute tension
('Batterie haute tension', 'electricite', 'batterie-hv', ARRAY['batterie HV', 'pack batterie'], true),
('Module de batterie haute tension', 'electricite', 'batterie-hv', ARRAY['module HV'], false),
('Cellule de batterie', 'electricite', 'batterie-hv', ARRAY['cellule Li-ion'], false),
('BMS (Battery Management System)', 'electricite', 'batterie-hv', ARRAY['gestionnaire batterie'], true),
('Connecteur haute tension', 'electricite', 'batterie-hv', ARRAY['connecteur HV'], false),
('Câble haute tension', 'electricite', 'cable-hv', ARRAY['câble orange'], true),

-- Moteurs électriques
('Moteur électrique avant', 'electricite', 'moteur-electrique', ARRAY['moteur traction AV'], true),
('Moteur électrique arrière', 'electricite', 'moteur-electrique', ARRAY['moteur traction AR'], true),
('Rotor de moteur électrique', 'electricite', 'moteur-electrique', ARRAY['rotor'], false),
('Stator de moteur électrique', 'electricite', 'moteur-electrique', ARRAY['stator'], false),
('Réducteur de moteur électrique', 'electricite', 'moteur-electrique', ARRAY['gearbox électrique'], true),

-- Onduleur et convertisseur
('Onduleur de traction', 'electricite', 'onduleur', ARRAY['inverter'], true),
('Convertisseur DC/DC', 'electricite', 'convertisseur', ARRAY['convertisseur 12V'], true),
('Chargeur embarqué', 'electricite', 'chargeur', ARRAY['OBC'], true),
('Module de puissance', 'electricite', 'onduleur', ARRAY['power module'], false),

-- Refroidissement véhicule électrique
('Radiateur de batterie', 'electricite', 'refroidissement', ARRAY['échangeur batterie'], true),
('Pompe de refroidissement de batterie', 'electricite', 'refroidissement', ARRAY['pompe circuit batterie'], false),
('Radiateur d''onduleur', 'electricite', 'refroidissement', ARRAY['échangeur onduleur'], false),
('Plaque de refroidissement batterie', 'electricite', 'refroidissement', ARRAY['cold plate'], false),
('Chiller', 'electricite', 'refroidissement', ARRAY['échangeur réfrigérant'], false),
('Pompe à chaleur', 'climatisation', 'pompe-chaleur', ARRAY['heat pump'], true),

-- Charge électrique
('Prise de charge type 2', 'electricite', 'charge', ARRAY['prise Mennekes'], true),
('Prise de charge type 1', 'electricite', 'charge', ARRAY['prise J1772'], false),
('Prise de charge CCS', 'electricite', 'charge', ARRAY['combo'], true),
('Prise de charge CHAdeMO', 'electricite', 'charge', ARRAY['prise CHAdeMO'], false),
('Câble de charge domestique', 'electricite', 'charge', ARRAY['câble mode 2'], true),
('Câble de charge type 2', 'electricite', 'charge', ARRAY['câble mode 3'], true),
('Trappe de charge', 'electricite', 'charge', ARRAY['volet charge'], true),
('Actuateur de trappe de charge', 'electricite', 'charge', ARRAY['moteur trappe charge'], false),
('Verrou de trappe de charge', 'electricite', 'charge', ARRAY['serrure charge'], false),

-- Composants hybrides
('Batterie hybride', 'electricite', 'batterie-hybride', ARRAY['batterie NiMH'], true),
('Moteur électrique hybride', 'electricite', 'moteur-hybride', ARRAY['MG1', 'MG2'], true),
('Boîte de vitesses hybride', 'transmission', 'hybride', ARRAY['e-CVT'], false),
('Planétaire hybride', 'transmission', 'hybride', ARRAY['train épicycloïdal'], false),

-- Calculateurs et contrôleurs véhicule électrique
('Calculateur de véhicule électrique', 'electronique', 'calculateur', ARRAY['VCU'], true),
('Contrôleur de moteur électrique', 'electronique', 'calculateur', ARRAY['MCU'], false),
('Calculateur de batterie', 'electronique', 'calculateur', ARRAY['BCU'], false),

-- Capteurs véhicule électrique
('Capteur de courant haute tension', 'electricite', 'capteur', ARRAY['capteur HV'], false),
('Capteur de température de batterie', 'electricite', 'capteur', ARRAY['sonde T° batterie'], false),
('Capteur d''isolement', 'electricite', 'capteur', ARRAY['IMD'], false),

-- Fusibles et disjoncteurs haute tension
('Fusible haute tension', 'electricite', 'fusible-hv', ARRAY['fusible HV'], true),
('Disjoncteur haute tension', 'electricite', 'fusible-hv', ARRAY['service disconnect'], false),
('Précharge haute tension', 'electricite', 'fusible-hv', ARRAY['résistance précharge'], false),

-- Chauffage électrique
('Réchauffeur électrique PTC', 'climatisation', 'chauffage', ARRAY['chauffage PTC'], true),
('Résistance de chauffage habitacle', 'climatisation', 'chauffage', ARRAY['chauffage électrique'], false),

-- Alimentation 12V véhicule électrique
('Batterie 12V auxiliaire', 'electricite', 'batterie', ARRAY['batterie service'], true),
('Chargeur de batterie 12V', 'electricite', 'chargeur', ARRAY['DC/DC 12V'], false),

-- Accessoires charge
('Wallbox 7kW', 'electricite', 'borne', ARRAY['borne murale 7kW'], true),
('Wallbox 11kW', 'electricite', 'borne', ARRAY['borne murale 11kW'], true),
('Wallbox 22kW', 'electricite', 'borne', ARRAY['borne murale 22kW'], false),
('Adaptateur de charge', 'electricite', 'charge', ARRAY['adaptateur prise'], false),

-- Consommables véhicule électrique
('Liquide de refroidissement batterie', 'electricite', 'fluide', ARRAY['coolant batterie'], true),
('Graisse diélectrique', 'electricite', 'produit', ARRAY['graisse HV'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Batterie haute tension',
  'BMS (Battery Management System)',
  'Moteur électrique avant',
  'Moteur électrique arrière',
  'Onduleur de traction',
  'Convertisseur DC/DC',
  'Chargeur embarqué',
  'Prise de charge type 2',
  'Câble de charge type 2',
  'Trappe de charge',
  'Pompe à chaleur',
  'Wallbox 7kW',
  'Wallbox 11kW',
  'Calculateur de véhicule électrique'
);
