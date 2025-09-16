-- Ajouter les colonnes manquantes à la table sellers pour le profil vendeur

-- Ajouter la colonne pour l'avatar
ALTER TABLE public.sellers
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Ajouter les colonnes pour les notifications
ALTER TABLE public.sellers
ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT true;

ALTER TABLE public.sellers
ADD COLUMN IF NOT EXISTS email_notifications_enabled BOOLEAN DEFAULT true;

-- Optionnels : Ajouter des commentaires pour documenter les nouvelles colonnes
COMMENT ON COLUMN public.sellers.avatar_url IS 'URL de l''avatar/photo de profil du vendeur stockée dans Supabase Storage';
COMMENT ON COLUMN public.sellers.notifications_enabled IS 'Active/désactive les notifications push pour les nouvelles demandes';
COMMENT ON COLUMN public.sellers.email_notifications_enabled IS 'Active/désactive les notifications par email (résumé quotidien)';

-- Créer des index pour améliorer les performances si nécessaire
CREATE INDEX IF NOT EXISTS idx_sellers_notifications_enabled
ON public.sellers USING btree (notifications_enabled) TABLESPACE pg_default;

-- Vérifier que les colonnes ont été ajoutées
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'sellers'
  AND table_schema = 'public'
  AND column_name IN ('avatar_url', 'notifications_enabled', 'email_notifications_enabled')
ORDER BY column_name;