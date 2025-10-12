-- Ajout complet suspension et train roulant

-- ========================================
-- SUSPENSION & TRAIN ROULANT
-- ========================================
INSERT INTO public.parts (name, category, subcategory, synonyms, is_popular) VALUES
-- Amortisseurs
('Amortisseur avant gauche', 'suspension', 'amortisseur', ARRAY['amortisseur AV G', 'shock AV G'], true),
('Amortisseur avant droit', 'suspension', 'amortisseur', ARRAY['amortisseur AV D', 'shock AV D'], true),
('Amortisseur arrière gauche', 'suspension', 'amortisseur', ARRAY['amortisseur AR G', 'shock AR G'], true),
('Amortisseur arrière droit', 'suspension', 'amortisseur', ARRAY['amortisseur AR D', 'shock AR D'], true),
('Kit amortisseurs avant', 'suspension', 'kit', ARRAY['paire amortisseurs AV'], true),
('Kit amortisseurs arrière', 'suspension', 'kit', ARRAY['paire amortisseurs AR'], true),
('Amortisseur à gaz avant gauche', 'suspension', 'amortisseur', ARRAY['shock gaz AV G'], false),
('Amortisseur à gaz arrière droit', 'suspension', 'amortisseur', ARRAY['shock gaz AR D'], false),
('Kit sport amortisseurs courts', 'suspension', 'performance', ARRAY['amortisseurs sport'], false),

-- Ressorts
('Ressort avant gauche', 'suspension', 'ressort', ARRAY['spring AV G'], true),
('Ressort avant droit', 'suspension', 'ressort', ARRAY['spring AV D'], true),
('Ressort arrière gauche', 'suspension', 'ressort', ARRAY['spring AR G'], true),
('Ressort arrière droit', 'suspension', 'ressort', ARRAY['spring AR D'], true),
('Kit ressorts sport avant', 'suspension', 'performance', ARRAY['springs sport AV'], false),
('Kit ressorts sport arrière', 'suspension', 'performance', ARRAY['springs sport AR'], false),
('Ressort hélicoïdal avant', 'suspension', 'ressort', ARRAY['spring hélicoïdal AV'], false),
('Lame de ressort', 'suspension', 'ressort', ARRAY['ressort à lames'], false),
('Kit lames de suspension arrière', 'suspension', 'ressort', ARRAY['pack lames AR'], false),

-- Jambes de force (MacPherson)
('Jambe de force avant gauche', 'suspension', 'macpherson', ARRAY['strut AV G', 'jambe MacPherson G'], true),
('Jambe de force avant droite', 'suspension', 'macpherson', ARRAY['strut AV D', 'jambe MacPherson D'], true),
('Kit jambes de force avant', 'suspension', 'kit', ARRAY['kit struts AV'], true),
('Coupelle de jambe de force avant gauche', 'suspension', 'liaison', ARRAY['top mount AV G'], true),
('Coupelle de jambe de force avant droite', 'suspension', 'liaison', ARRAY['top mount AV D'], true),
('Butée de jambe de force avant gauche', 'suspension', 'liaison', ARRAY['bump stop AV G'], false),
('Butée de jambe de force avant droite', 'suspension', 'liaison', ARRAY['bump stop AV D'], false),
('Roulement de coupelle avant gauche', 'suspension', 'roulement', ARRAY['bearing top mount G'], true),
('Roulement de coupelle avant droit', 'suspension', 'roulement', ARRAY['bearing top mount D'], true),

-- Triangles de suspension
('Triangle inférieur avant gauche', 'suspension', 'bras', ARRAY['bras suspension AV inf G', 'wishbone G'], true),
('Triangle inférieur avant droit', 'suspension', 'bras', ARRAY['bras suspension AV inf D', 'wishbone D'], true),
('Triangle supérieur avant gauche', 'suspension', 'bras', ARRAY['bras suspension AV sup G'], false),
('Triangle supérieur avant droit', 'suspension', 'bras', ARRAY['bras suspension AV sup D'], false),
('Bras de suspension arrière gauche', 'suspension', 'bras', ARRAY['trailing arm G'], true),
('Bras de suspension arrière droit', 'suspension', 'bras', ARRAY['trailing arm D'], true),
('Bras longitudinal arrière gauche', 'suspension', 'bras', ARRAY['bras longitudinal AR G'], false),
('Bras longitudinal arrière droit', 'suspension', 'bras', ARRAY['bras longitudinal AR D'], false),
('Bras transversal arrière gauche', 'suspension', 'bras', ARRAY['bras transversal AR G'], false),
('Bras transversal arrière droit', 'suspension', 'bras', ARRAY['bras transversal AR D'], false),

-- Rotules de suspension
('Rotule de suspension avant gauche', 'suspension', 'rotule', ARRAY['ball joint AV G'], true),
('Rotule de suspension avant droite', 'suspension', 'rotule', ARRAY['ball joint AV D'], true),
('Rotule de triangle inférieur avant gauche', 'suspension', 'rotule', ARRAY['rotule bras inf AV G'], true),
('Rotule de triangle inférieur avant droit', 'suspension', 'rotule', ARRAY['rotule bras inf AV D'], true),
('Rotule de triangle supérieur avant gauche', 'suspension', 'rotule', ARRAY['rotule bras sup AV G'], false),
('Rotule de triangle supérieur avant droit', 'suspension', 'rotule', ARRAY['rotule bras sup AV D'], false),

-- Silent-blocs
('Silent-bloc de triangle avant gauche', 'suspension', 'silent-bloc', ARRAY['silent-bloc bras AV G'], true),
('Silent-bloc de triangle avant droit', 'suspension', 'silent-bloc', ARRAY['silent-bloc bras AV D'], true),
('Silent-bloc de bras arrière gauche', 'suspension', 'silent-bloc', ARRAY['silent-bloc bras AR G'], true),
('Silent-bloc de bras arrière droit', 'suspension', 'silent-bloc', ARRAY['silent-bloc bras AR D'], true),
('Kit silent-blocs de suspension avant', 'suspension', 'kit', ARRAY['kit silent-blocs AV'], false),
('Kit silent-blocs de suspension arrière', 'suspension', 'kit', ARRAY['kit silent-blocs AR'], false),
('Silent-bloc de barre stabilisatrice avant', 'suspension', 'silent-bloc', ARRAY['silent-bloc barre stab AV'], true),
('Silent-bloc de barre stabilisatrice arrière', 'suspension', 'silent-bloc', ARRAY['silent-bloc barre stab AR'], false),
('Silent-bloc polyuréthane sport avant', 'suspension', 'performance', ARRAY['silent-bloc PU AV'], false),
('Silent-bloc polyuréthane sport arrière', 'suspension', 'performance', ARRAY['silent-bloc PU AR'], false),

-- Barres stabilisatrices
('Barre stabilisatrice avant', 'suspension', 'barre-anti-roulis', ARRAY['barre anti-roulis AV'], true),
('Barre stabilisatrice arrière', 'suspension', 'barre-anti-roulis', ARRAY['barre anti-roulis AR'], true),
('Biellette de barre stabilisatrice avant gauche', 'suspension', 'biellette', ARRAY['biellette stab AV G', 'drop link G'], true),
('Biellette de barre stabilisatrice avant droite', 'suspension', 'biellette', ARRAY['biellette stab AV D', 'drop link D'], true),
('Biellette de barre stabilisatrice arrière gauche', 'suspension', 'biellette', ARRAY['biellette stab AR G'], true),
('Biellette de barre stabilisatrice arrière droite', 'suspension', 'biellette', ARRAY['biellette stab AR D'], true),
('Kit biellettes de stabilisatrice avant', 'suspension', 'kit', ARRAY['kit biellettes AV'], true),
('Kit biellettes de stabilisatrice arrière', 'suspension', 'kit', ARRAY['kit biellettes AR'], false),
('Barre stabilisatrice sport renforcée avant', 'suspension', 'performance', ARRAY['barre stab sport AV'], false),

-- Roulements de roue
('Roulement de roue avant gauche', 'suspension', 'roulement', ARRAY['bearing AV G', 'wheel bearing G'], true),
('Roulement de roue avant droit', 'suspension', 'roulement', ARRAY['bearing AV D', 'wheel bearing D'], true),
('Roulement de roue arrière gauche', 'suspension', 'roulement', ARRAY['bearing AR G'], true),
('Roulement de roue arrière droit', 'suspension', 'roulement', ARRAY['bearing AR D'], true),
('Kit roulement de roue avant gauche', 'suspension', 'kit', ARRAY['kit bearing AV G'], true),
('Kit roulement de roue avant droit', 'suspension', 'kit', ARRAY['kit bearing AV D'], true),
('Kit roulement de roue arrière gauche', 'suspension', 'kit', ARRAY['kit bearing AR G'], false),
('Kit roulement de roue arrière droit', 'suspension', 'kit', ARRAY['kit bearing AR D'], false),

-- Moyeux et fusées
('Moyeu avant gauche', 'suspension', 'moyeu', ARRAY['hub AV G'], true),
('Moyeu avant droit', 'suspension', 'moyeu', ARRAY['hub AV D'], true),
('Moyeu arrière gauche', 'suspension', 'moyeu', ARRAY['hub AR G'], true),
('Moyeu arrière droit', 'suspension', 'moyeu', ARRAY['hub AR D'], true),
('Fusée avant gauche', 'suspension', 'fusee', ARRAY['porte-moyeu AV G', 'knuckle G'], true),
('Fusée avant droite', 'suspension', 'fusee', ARRAY['porte-moyeu AV D', 'knuckle D'], true),
('Fusée arrière gauche', 'suspension', 'fusee', ARRAY['porte-moyeu AR G'], false),
('Fusée arrière droite', 'suspension', 'fusee', ARRAY['porte-moyeu AR D'], false),
('Écrou de moyeu avant gauche', 'suspension', 'fixation', ARRAY['écrou hub AV G'], false),
('Écrou de moyeu avant droit', 'suspension', 'fixation', ARRAY['écrou hub AV D'], false),

-- Suspension pneumatique
('Boudin pneumatique avant gauche', 'suspension', 'pneumatique', ARRAY['air spring AV G', 'coussin air G'], true),
('Boudin pneumatique avant droit', 'suspension', 'pneumatique', ARRAY['air spring AV D', 'coussin air D'], true),
('Boudin pneumatique arrière gauche', 'suspension', 'pneumatique', ARRAY['air spring AR G'], true),
('Boudin pneumatique arrière droit', 'suspension', 'pneumatique', ARRAY['air spring AR D'], true),
('Compresseur de suspension pneumatique', 'suspension', 'pneumatique', ARRAY['compresseur air suspension'], true),
('Valve de suspension pneumatique avant gauche', 'suspension', 'pneumatique', ARRAY['valve air AV G'], false),
('Valve de suspension pneumatique avant droite', 'suspension', 'pneumatique', ARRAY['valve air AV D'], false),
('Valve de suspension pneumatique arrière gauche', 'suspension', 'pneumatique', ARRAY['valve air AR G'], false),
('Valve de suspension pneumatique arrière droite', 'suspension', 'pneumatique', ARRAY['valve air AR D'], false),
('Calculateur de suspension pneumatique', 'suspension', 'electronique', ARRAY['ECU air suspension'], false),
('Capteur de hauteur avant gauche', 'suspension', 'capteur', ARRAY['capteur niveau AV G'], false),
('Capteur de hauteur avant droit', 'suspension', 'capteur', ARRAY['capteur niveau AV D'], false),
('Capteur de hauteur arrière gauche', 'suspension', 'capteur', ARRAY['capteur niveau AR G'], false),
('Capteur de hauteur arrière droit', 'suspension', 'capteur', ARRAY['capteur niveau AR D'], false),
('Réservoir d''air de suspension', 'suspension', 'pneumatique', ARRAY['réserve air suspension'], false),

-- Suspension pilotée/adaptative
('Amortisseur piloté avant gauche', 'suspension', 'adaptatif', ARRAY['amortisseur électronique AV G'], false),
('Amortisseur piloté avant droit', 'suspension', 'adaptatif', ARRAY['amortisseur électronique AV D'], false),
('Amortisseur piloté arrière gauche', 'suspension', 'adaptatif', ARRAY['amortisseur électronique AR G'], false),
('Amortisseur piloté arrière droit', 'suspension', 'adaptatif', ARRAY['amortisseur électronique AR D'], false),
('Calculateur de suspension adaptative', 'suspension', 'electronique', ARRAY['ECU adaptive damping'], false),
('Capteur d''accélération suspension', 'suspension', 'capteur', ARRAY['accéléromètre suspension'], false),

-- Cardans et arbres de transmission
('Cardan avant gauche', 'transmission', 'cardan', ARRAY['arbre de roue AV G', 'driveshaft G'], true),
('Cardan avant droit', 'transmission', 'cardan', ARRAY['arbre de roue AV D', 'driveshaft D'], true),
('Cardan arrière gauche', 'transmission', 'cardan', ARRAY['arbre de roue AR G'], true),
('Cardan arrière droit', 'transmission', 'cardan', ARRAY['arbre de roue AR D'], true),
('Soufflet de cardan avant gauche intérieur', 'transmission', 'cardan', ARRAY['soufflet tripode G'], true),
('Soufflet de cardan avant gauche extérieur', 'transmission', 'cardan', ARRAY['soufflet tulipe G'], true),
('Soufflet de cardan avant droit intérieur', 'transmission', 'cardan', ARRAY['soufflet tripode D'], true),
('Soufflet de cardan avant droit extérieur', 'transmission', 'cardan', ARRAY['soufflet tulipe D'], true),
('Kit soufflets de cardan avant gauche', 'transmission', 'kit', ARRAY['kit soufflets cardan G'], true),
('Kit soufflets de cardan avant droit', 'transmission', 'kit', ARRAY['kit soufflets cardan D'], true),
('Croisillon de cardan', 'transmission', 'cardan', ARRAY['joint cardan'], false),
('Circlips de cardan', 'transmission', 'fixation', ARRAY['clips cardan'], false)

ON CONFLICT (name) DO NOTHING;

-- Mise à jour des pièces populaires
UPDATE public.parts SET is_popular = true WHERE name IN (
  'Amortisseur avant gauche',
  'Amortisseur avant droit',
  'Amortisseur arrière gauche',
  'Amortisseur arrière droit',
  'Ressort avant gauche',
  'Ressort avant droit',
  'Triangle inférieur avant gauche',
  'Triangle inférieur avant droit',
  'Rotule de suspension avant gauche',
  'Rotule de suspension avant droite',
  'Roulement de roue avant gauche',
  'Roulement de roue avant droit',
  'Cardan avant gauche',
  'Cardan avant droit'
);
