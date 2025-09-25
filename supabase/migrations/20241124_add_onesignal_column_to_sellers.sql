-- Ajouter la colonne onesignal_player_id à la table sellers
ALTER TABLE public.sellers
ADD COLUMN IF NOT EXISTS onesignal_player_id TEXT;

-- Ajouter un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_sellers_onesignal_player_id
ON public.sellers(onesignal_player_id);

-- Commentaire pour documenter la colonne
COMMENT ON COLUMN public.sellers.onesignal_player_id
IS 'OneSignal Player ID pour les notifications push';