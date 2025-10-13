-- Ajout complet admission et échappement

-- ========================================
-- ADMISSION & ÉCHAPPEMENT
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Filtre à air et admission
('Filtre à air', 'moteur', 'filtre', ARRAY['air filter'], true),
('Boîtier de filtre à air', 'moteur', 'admission', ARRAY['corps filtre air'], true),
('Couvercle de boîtier de filtre à air', 'moteur', 'admission', ARRAY['cache filtre air'], false),
('Durite d''admission d''air', 'moteur', 'admission', ARRAY['tuyau air'], true),
('Tuyau d''air entre filtre et turbo', 'moteur', 'admission', ARRAY['durite pré-turbo'], false),
('Débitmètre d''air', 'moteur', 'capteur', ARRAY['MAF', 'débitmètre massique'], true),
('Sonde de température d''air', 'moteur', 'capteur', ARRAY['capteur IAT'], false),
('Capteur de pression d''admission', 'moteur', 'capteur', ARRAY['MAP sensor'], true),
('Papillon des gaz motorisé', 'moteur', 'admission', ARRAY['boîtier papillon électrique'], true),
('Papillon des gaz mécanique', 'moteur', 'admission', ARRAY['boîtier papillon câble'], false),
('Câble d''accélérateur', 'moteur', 'admission', ARRAY['câble de gaz'], true),
('Capteur de position papillon', 'moteur', 'capteur', ARRAY['TPS'], false),
('Joint de boîtier papillon', 'moteur', 'joint', ARRAY['joint papillon'], false),
('Filtre à air sport', 'moteur', 'performance', ARRAY['filtre coton'], false),
('Kit admission dynamique', 'moteur', 'performance', ARRAY['CAI', 'cold air intake'], false),

-- Turbo et compresseur
('Turbocompresseur', 'moteur', 'turbo', ARRAY['turbo'], true),
('Turbo neuf', 'moteur', 'turbo', ARRAY['turbocompresseur neuf'], false),
('Turbo reconditionné', 'moteur', 'turbo', ARRAY['turbo échange standard'], true),
('Compresseur mécanique', 'moteur', 'compresseur', ARRAY['supercharger'], false),
('Cartouche de turbo', 'moteur', 'turbo', ARRAY['CHRA'], false),
('Joint de turbo', 'moteur', 'joint', ARRAY['joint turbine'], true),
('Kit joints de turbo', 'moteur', 'kit', ARRAY['kit gaskets turbo'], false),
('Durite de turbo', 'moteur', 'turbo', ARRAY['durite intercooler'], true),
('Coude de sortie de turbo', 'moteur', 'turbo', ARRAY['elbow turbo'], false),
('Durite d''huile de turbo', 'moteur', 'turbo', ARRAY['ligne huile turbo'], true),
('Durite d''alimentation turbo', 'moteur', 'turbo', ARRAY['durite gavage turbo'], false),
('Durite de retour d''huile turbo', 'moteur', 'turbo', ARRAY['durite retour huile'], false),
('Actuateur de turbo', 'moteur', 'turbo', ARRAY['wastegate pneumatique'], true),
('Électrovanne de turbo', 'moteur', 'turbo', ARRAY['N75', 'solénoïde boost'], true),
('Capteur de pression de turbo', 'moteur', 'capteur', ARRAY['capteur boost'], false),
('Dump valve', 'moteur', 'turbo', ARRAY['valve de décharge'], false),
('Blow-off valve', 'moteur', 'performance', ARRAY['BOV', 'soupape décharge'], false),

-- Intercooler
('Intercooler', 'moteur', 'intercooler', ARRAY['échangeur air-air'], true),
('Durite d''intercooler supérieure', 'moteur', 'intercooler', ARRAY['durite inter haute'], true),
('Durite d''intercooler inférieure', 'moteur', 'intercooler', ARRAY['durite inter basse'], true),
('Intercooler étagé', 'moteur', 'performance', ARRAY['front mount intercooler'], false),

-- EGR et dépollution admission
('Vanne EGR', 'moteur', 'egr', ARRAY['valve EGR'], true),
('Refroidisseur EGR', 'moteur', 'egr', ARRAY['échangeur EGR'], true),
('Joint de vanne EGR', 'moteur', 'joint', ARRAY['joint EGR'], false),
('Durite de vanne EGR', 'moteur', 'egr', ARRAY['tuyau EGR'], false),
('Électrovanne de vanne EGR', 'moteur', 'egr', ARRAY['solénoïde EGR'], false),

-- Échappement avant
('Ligne d''échappement complète', 'moteur', 'echappement', ARRAY['échappement complet'], true),
('Collecteur d''échappement', 'moteur', 'echappement', ARRAY['manifold échappement'], true),
('Descente de turbo', 'moteur', 'echappement', ARRAY['downpipe'], true),
('Catalyseur', 'moteur', 'echappement', ARRAY['pot catalytique', 'cat'], true),
('Pré-catalyseur', 'moteur', 'echappement', ARRAY['petit catalyseur'], false),
('Tube avant d''échappement', 'moteur', 'echappement', ARRAY['pipe avant'], false),
('Joint de collecteur échappement', 'moteur', 'joint', ARRAY['joint manifold'], true),

-- Échappement milieu
('Ligne intermédiaire', 'moteur', 'echappement', ARRAY['pipe centrale'], true),
('Tube intermédiaire', 'moteur', 'echappement', ARRAY['section centrale'], false),
('Filtre à particules', 'moteur', 'echappement', ARRAY['FAP', 'DPF'], true),
('Additif FAP', 'moteur', 'fluide', ARRAY['Eolys', 'cérine'], true),
('Capteur de pression différentielle FAP', 'moteur', 'capteur', ARRAY['capteur DPF'], true),
('Capteur de température FAP avant', 'moteur', 'capteur', ARRAY['sonde T° FAP AV'], false),
('Capteur de température FAP arrière', 'moteur', 'capteur', ARRAY['sonde T° FAP AR'], false),
('Injecteur d''additif FAP', 'moteur', 'echappement', ARRAY['doseur Eolys'], false),

-- Échappement arrière
('Silencieux arrière', 'moteur', 'echappement', ARRAY['pot arrière'], true),
('Silencieux intermédiaire', 'moteur', 'echappement', ARRAY['pot central'], false),
('Sortie d''échappement', 'moteur', 'echappement', ARRAY['embout échappement'], true),
('Embout chromé d''échappement', 'moteur', 'echappement', ARRAY['tip échappement'], false),
('Ligne échappement sport', 'moteur', 'performance', ARRAY['échappement inox'], false),
('Silencieux sport', 'moteur', 'performance', ARRAY['pot sport'], false),

-- Fixations échappement
('Collier d''échappement', 'moteur', 'fixation', ARRAY['collier serrage'], true),
('Support d''échappement', 'moteur', 'fixation', ARRAY['fixation échappement'], true),
('Silent-bloc d''échappement', 'moteur', 'fixation', ARRAY['caoutchouc échappement'], true),
('Bride d''échappement', 'moteur', 'fixation', ARRAY['flange échappement'], false),
('Joint de bride d''échappement', 'moteur', 'joint', ARRAY['joint flange'], true),
('Joint graphite d''échappement', 'moteur', 'joint', ARRAY['joint graphite'], false),
('Joint torique d''échappement', 'moteur', 'joint', ARRAY['joint donut'], false),

-- Sondes lambda
('Sonde lambda avant', 'moteur', 'capteur', ARRAY['sonde O2 AV', 'lambda 1'], true),
('Sonde lambda arrière', 'moteur', 'capteur', ARRAY['sonde O2 AR', 'lambda 2'], true),
('Sonde lambda post-catalyseur', 'moteur', 'capteur', ARRAY['sonde après cat'], true),
('Sonde lambda large bande', 'moteur', 'capteur', ARRAY['wide band'], false),

-- SCR et AdBlue
('Catalyseur SCR', 'moteur', 'echappement', ARRAY['pot SCR'], true),
('Injecteur AdBlue', 'moteur', 'scr', ARRAY['injecteur urée'], true),
('Réservoir AdBlue', 'moteur', 'scr', ARRAY['réservoir urée'], true),
('Pompe AdBlue', 'moteur', 'scr', ARRAY['pompe urée'], true),
('Module AdBlue', 'moteur', 'scr', ARRAY['doseur AdBlue'], false),
('Capteur de niveau AdBlue', 'moteur', 'capteur', ARRAY['capteur urée'], false),
('Capteur de qualité AdBlue', 'moteur', 'capteur', ARRAY['capteur NOx'], false),
('Durite AdBlue', 'moteur', 'scr', ARRAY['tuyau urée'], false),
('Bouchon de réservoir AdBlue', 'moteur', 'scr', ARRAY['bouchon urée'], false),

-- Wastegate
('Wastegate externe', 'moteur', 'performance', ARRAY['waste gate'], false),
('Wastegate interne', 'moteur', 'turbo', ARRAY['actuateur interne'], false),

-- Admission variable
('Volets d''admission variables', 'moteur', 'admission', ARRAY['swirl flaps'], false),
('Actuateur de volets d''admission', 'moteur', 'admission', ARRAY['moteur swirl'], false),

-- Pâte et produits
('Pâte d''échappement', 'moteur', 'produit', ARRAY['mastic échappement'], true),
('Graisse montage sonde lambda', 'moteur', 'produit', ARRAY['pâte copper'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Filtre à air',
  'Boîtier de filtre à air',
  'Débitmètre d''air',
  'Papillon des gaz motorisé',
  'Turbocompresseur',
  'Durite de turbo',
  'Intercooler',
  'Vanne EGR',
  'Refroidisseur EGR',
  'Catalyseur',
  'Filtre à particules',
  'Sonde lambda avant',
  'Sonde lambda arrière',
  'Silencieux arrière',
  'Ligne d''échappement complète',
  'Collier d''échappement',
  'Support d''échappement'
);
