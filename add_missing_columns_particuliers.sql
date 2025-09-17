-- Ajouter les colonnes manquantes à la table particuliers
-- Ces colonnes sont nécessaires pour stocker les paramètres utilisateur

-- Ajouter la colonne country avec une valeur par défaut
ALTER TABLE public.particuliers
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'France';

-- Ajouter les colonnes pour les notifications
ALTER TABLE public.particuliers
ADD COLUMN IF NOT EXISTS notifications_enabled BOOLEAN DEFAULT true;

ALTER TABLE public.particuliers
ADD COLUMN IF NOT EXISTS email_notifications_enabled BOOLEAN DEFAULT true;

-- Ajouter la colonne pour l'avatar
ALTER TABLE public.particuliers
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Créer un index sur country pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_particuliers_country
ON public.particuliers USING btree (country) TABLESPACE pg_default;

-- Commentaire pour documenter les colonnes
COMMENT ON COLUMN public.particuliers.country IS 'Pays de résidence du particulier';
COMMENT ON COLUMN public.particuliers.notifications_enabled IS 'Activer les notifications push';
COMMENT ON COLUMN public.particuliers.email_notifications_enabled IS 'Activer les notifications par email';
COMMENT ON COLUMN public.particuliers.address IS 'Adresse postale du particulier';
COMMENT ON COLUMN public.particuliers.city IS 'Ville du particulier';
COMMENT ON COLUMN public.particuliers.zip_code IS 'Code postal du particulier';
COMMENT ON COLUMN public.particuliers.phone IS 'Numéro de téléphone du particulier';