-- Table universelle pour gérer les tokens push de tous les utilisateurs
-- Cette table utilise le player_id comme clé principale pour éviter les problèmes de duplication
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  onesignal_player_id TEXT UNIQUE NOT NULL,
  user_type TEXT CHECK (user_type IN ('particulier', 'seller', 'unknown')),
  user_email TEXT,
  platform TEXT DEFAULT 'android',
  last_active TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id ON public.push_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_push_tokens_player_id ON public.push_tokens(onesignal_player_id);

-- RLS (Row Level Security)
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

-- Politique pour permettre à tous de créer/mettre à jour leur propre token
CREATE POLICY "Users can manage own push tokens"
  ON public.push_tokens
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.last_active = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour updated_at
CREATE TRIGGER update_push_tokens_updated_at BEFORE UPDATE ON public.push_tokens
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();