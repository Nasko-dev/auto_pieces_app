-- Ajout des pièces spécifiques par type de véhicule

-- ========================================
-- PIÈCES SPÉCIFIQUES 4X4 & SUV
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
('Boîtier de transfert', 'transmission', '4x4', ARRAY['transfer case'], true),
('Arbre de transfert', 'transmission', '4x4', ARRAY['arbre transfer'], false),
('Actuateur 4x4', 'transmission', '4x4', ARRAY['moteur 4WD'], false),
('Différentiel central', 'transmission', '4x4', ARRAY['différentiel central Torsen'], false),
('Différentiel arrière autobloquant', 'transmission', '4x4', ARRAY['diff AR LSD'], false),
('Protection sous moteur acier', 'carrosserie', 'protection', ARRAY['sabot moteur'], true),
('Protection sous boîte', 'carrosserie', 'protection', ARRAY['sabot BV'], false),
('Protection sous réservoir', 'carrosserie', 'protection', ARRAY['sabot réservoir'], false),
('Arceau de sécurité SUV', 'carrosserie', 'securite', ARRAY['roll bar'], false),
('Pare-buffle', 'carrosserie', 'protection', ARRAY['bull bar'], false),
('Treuil électrique', 'accessoires', '4x4', ARRAY['winch'], false),
('Support treuil', 'accessoires', '4x4', ARRAY['platine treuil'], false),
('Barres LED tout-terrain', 'eclairage', '4x4', ARRAY['rampe LED'], false),
('Projecteur de toit', 'eclairage', '4x4', ARRAY['phare toit'], false),
('Suspension pneumatique', 'suspension', 'confort', ARRAY['air suspension'], true),
('Compresseur suspension pneumatique', 'suspension', 'pneumatique', ARRAY['compresseur air'], true),
('Réservoir air suspension', 'suspension', 'pneumatique', ARRAY['ballon air'], false),
('Électrovanne suspension', 'suspension', 'pneumatique', ARRAY['valve air'], false),
('Capteur hauteur caisse', 'suspension', 'mesure', ARRAY['capteur assiette'], false),
('Module contrôle suspension', 'suspension', 'electronique', ARRAY['ECU suspension'], false),

-- ========================================
-- PIÈCES SPÉCIFIQUES UTILITAIRES
-- ========================================
('Panneau de séparation', 'interieur', 'utilitaire', ARRAY['cloison'], false),
('Habillage bois plancher', 'interieur', 'utilitaire', ARRAY['plancher bois'], false),
('Ridelles', 'carrosserie', 'utilitaire', ARRAY['bords de benne'], false),
('Bâche de benne', 'accessoires', 'utilitaire', ARRAY['cover benne'], false),
('Hayon élévateur', 'accessoires', 'utilitaire', ARRAY['lift gate'], false),
('Échelle de toit', 'accessoires', 'utilitaire', ARRAY['échelle'], false),
('Porte latérale coulissante gauche', 'carrosserie', 'utilitaire', ARRAY['porte coulissante G'], true),
('Porte latérale coulissante droite', 'carrosserie', 'utilitaire', ARRAY['porte coulissante D'], true),
('Porte arrière simple', 'carrosserie', 'utilitaire', ARRAY['porte AR'], true),
('Portes arrière battantes', 'carrosserie', 'utilitaire', ARRAY['portes AR double'], true),

-- ========================================
-- PIÈCES SPÉCIFIQUES CABRIOLETS
-- ========================================
('Capote électrique', 'carrosserie', 'cabriolet', ARRAY['toit électrique'], true),
('Moteur capote cabriolet', 'carrosserie', 'cabriolet', ARRAY['mécanisme capote'], true),
('Toile de capote', 'carrosserie', 'cabriolet', ARRAY['capote tissu'], true),
('Lunette arrière capote', 'vitrage', 'cabriolet', ARRAY['vitre capote'], false),
('Armature capote', 'carrosserie', 'cabriolet', ARRAY['mécanisme toit'], false),
('Couvre-capote', 'carrosserie', 'cabriolet', ARRAY['housse capote'], false),
('Arceau de sécurité cabriolet', 'carrosserie', 'securite', ARRAY['roll bar cabriolet'], false),
('Déflecteur de vent', 'carrosserie', 'cabriolet', ARRAY['wind deflector'], false),
('Filet anti-remous', 'carrosserie', 'cabriolet', ARRAY['wind blocker'], false),

-- ========================================
-- PIÈCES SPÉCIFIQUES SPORTIVES
-- ========================================
('Échappement sport inox', 'echappement', 'performance', ARRAY['ligne sport'], false),
('Ligne échappement titane', 'echappement', 'performance', ARRAY['échappement Ti'], false),
('Intercooler frontal', 'moteur', 'performance', ARRAY['FMIC'], false),
('Kit admission carbone', 'moteur', 'performance', ARRAY['intake carbone'], false),
('Turbo K04', 'moteur', 'performance', ARRAY['turbo upgrade K04'], false),
('Kit freins Brembo', 'freinage', 'performance', ARRAY['freins Brembo'], false),
('Disques Brembo', 'freinage', 'performance', ARRAY['disques performance'], false),
('Étriers Brembo', 'freinage', 'performance', ARRAY['étriers sport'], false),
('Suspension sport KW', 'suspension', 'performance', ARRAY['coilovers KW'], false),
('Suspension Bilstein', 'suspension', 'performance', ARRAY['amortisseurs Bilstein'], false),
('Amortisseurs Öhlins', 'suspension', 'performance', ARRAY['amortisseurs Öhlins'], false),
('Différentiel mécanique', 'transmission', 'performance', ARRAY['diff mécanique'], false),
('Différentiel Torsen', 'transmission', 'performance', ARRAY['diff Torsen'], false),
('Différentiel Quaife', 'transmission', 'performance', ARRAY['diff Quaife'], false),

-- ========================================
-- PIÈCES SPÉCIFIQUES ANCIENNES
-- ========================================
('Carburateur', 'moteur', 'classique', ARRAY['carbu'], false),
('Kit de révision carburateur', 'moteur', 'classique', ARRAY['joints carburateur'], false),
('Pompe à essence mécanique', 'carburant', 'classique', ARRAY['pompe carbu'], false),
('Allumeur', 'electricite', 'classique', ARRAY['distributeur'], false),
('Condensateur allumage', 'electricite', 'classique', ARRAY['condensateur'], false),
('Rupteur', 'electricite', 'classique', ARRAY['vis platinées'], false),
('Tête d''allumeur', 'electricite', 'classique', ARRAY['doigt allumeur'], false),
('Générateur', 'electricite', 'classique', ARRAY['dynamo'], false),
('Régulateur de dynamo', 'electricite', 'classique', ARRAY['régulateur dynamo'], false),
('Bobine 6V', 'electricite', 'classique', ARRAY['bobine 6 volts'], false),
('Bobine 12V', 'electricite', 'classique', ARRAY['bobine 12 volts'], false),
('Batterie 6V', 'electricite', 'classique', ARRAY['batterie 6 volts'], false)

ON CONFLICT (name) DO NOTHING;
