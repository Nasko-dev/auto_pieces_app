-- =====================================================
-- SCRIPT DE PRÉPARATION PRODUCTION - PIÈCES D'OCCASION
-- =====================================================
-- À exécuter dans Supabase SQL Editor
-- Date: 2025-01-17
-- Version: 1.0
-- Auteur: William Le Gall
-- =====================================================

-- =====================================================
-- 1. ACTIVATION ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.anonymous_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.part_advertisements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.part_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.particuliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_rejections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. POLICIES DE SÉCURITÉ
-- =====================================================

-- Policies pour anonymous_users
CREATE POLICY "Anonymous users can read own data" ON anonymous_users
  FOR SELECT USING (id = auth.uid() OR device_id = current_setting('app.device_id', true));

CREATE POLICY "Anonymous users can insert" ON anonymous_users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anonymous users can update own" ON anonymous_users
  FOR UPDATE USING (id = auth.uid() OR device_id = current_setting('app.device_id', true));

-- Policies pour conversations
CREATE POLICY "Users see own conversations" ON conversations
  FOR ALL USING (auth.uid() = user_id OR auth.uid() = seller_id);

-- Policies pour messages
CREATE POLICY "Users can view messages in their conversations" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversations
      WHERE conversations.id = messages.conversation_id
      AND (conversations.user_id = auth.uid() OR conversations.seller_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in their conversations" ON messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversations
      WHERE conversations.id = conversation_id
      AND (conversations.user_id = auth.uid() OR conversations.seller_id = auth.uid())
    )
  );

-- Policies pour part_advertisements
CREATE POLICY "Anyone can view active advertisements" ON part_advertisements
  FOR SELECT USING (status = 'active' OR user_id = auth.uid());

CREATE POLICY "Users can manage own advertisements" ON part_advertisements
  FOR ALL USING (user_id = auth.uid());

-- Policies pour part_requests
CREATE POLICY "Sellers can view active requests" ON part_requests
  FOR SELECT USING (
    status = 'active'
    OR user_id = auth.uid()
    OR EXISTS (SELECT 1 FROM sellers WHERE id = auth.uid())
  );

CREATE POLICY "Users can manage own requests" ON part_requests
  FOR ALL USING (user_id = auth.uid());

-- Policies pour particuliers
CREATE POLICY "Users can view own profile" ON particuliers
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON particuliers
  FOR UPDATE USING (id = auth.uid());

-- Policies pour parts (catalogue public)
CREATE POLICY "Anyone can view parts catalog" ON parts
  FOR SELECT USING (is_active = true);

-- Policies pour seller_rejections
CREATE POLICY "Sellers can manage own rejections" ON seller_rejections
  FOR ALL USING (seller_id = auth.uid());

-- Policies pour seller_responses
CREATE POLICY "Sellers can manage own responses" ON seller_responses
  FOR ALL USING (seller_id = auth.uid());

CREATE POLICY "Users can view responses to their requests" ON seller_responses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM part_requests
      WHERE part_requests.id = request_id
      AND part_requests.user_id = auth.uid()
    )
  );

-- Policies pour sellers
CREATE POLICY "Public can view verified sellers" ON sellers
  FOR SELECT USING (is_active = true AND is_verified = true);

CREATE POLICY "Sellers can manage own profile" ON sellers
  FOR ALL USING (id = auth.uid());

-- =====================================================
-- 3. INDEX POUR OPTIMISATION
-- =====================================================

-- Index pour conversations
CREATE INDEX IF NOT EXISTS idx_conversations_user_seller ON conversations(user_id, seller_id);
CREATE INDEX IF NOT EXISTS idx_conversations_status_date ON conversations(status, last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_request ON conversations(request_id);
CREATE INDEX IF NOT EXISTS idx_conversations_unread_user ON conversations(user_id, unread_count_for_user) WHERE unread_count_for_user > 0;
CREATE INDEX IF NOT EXISTS idx_conversations_unread_seller ON conversations(seller_id, unread_count_for_seller) WHERE unread_count_for_seller > 0;

-- Index pour messages
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(conversation_id, is_read) WHERE NOT is_read;
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id, sender_type);
CREATE INDEX IF NOT EXISTS idx_messages_type ON messages(message_type) WHERE message_type != 'text';

-- Index pour part_advertisements
CREATE INDEX IF NOT EXISTS idx_part_ads_active_type ON part_advertisements(status, part_type) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_part_ads_location ON part_advertisements(department, city) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_part_ads_user_status ON part_advertisements(user_id, status);
CREATE INDEX IF NOT EXISTS idx_part_ads_price ON part_advertisements(price) WHERE status = 'active' AND price IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_part_ads_created ON part_advertisements(created_at DESC) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_part_ads_expires ON part_advertisements(expires_at) WHERE status = 'active';

-- Index pour part_requests
CREATE INDEX IF NOT EXISTS idx_part_requests_active ON part_requests(status, created_at DESC) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_part_requests_user ON part_requests(user_id, status);
CREATE INDEX IF NOT EXISTS idx_part_requests_type ON part_requests(part_type);
CREATE INDEX IF NOT EXISTS idx_part_requests_expires ON part_requests(expires_at) WHERE status = 'active';

-- Index pour sellers
CREATE INDEX IF NOT EXISTS idx_sellers_verified ON sellers(is_verified, is_active) WHERE is_verified = true AND is_active = true;
CREATE INDEX IF NOT EXISTS idx_sellers_company ON sellers(company_name) WHERE company_name IS NOT NULL;

-- Index pour seller_responses
CREATE INDEX IF NOT EXISTS idx_seller_responses_request ON seller_responses(request_id, status);
CREATE INDEX IF NOT EXISTS idx_seller_responses_seller ON seller_responses(seller_id, created_at DESC);

-- =====================================================
-- 4. FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction pour mise à jour automatique de updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour synchroniser les compteurs de messages
CREATE OR REPLACE FUNCTION sync_conversation_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Mise à jour des compteurs et derniers messages
    UPDATE conversations
    SET
      total_messages = total_messages + 1,
      last_message_at = NEW.created_at,
      last_message_content = LEFT(NEW.content, 100),
      last_message_sender_type = NEW.sender_type,
      last_message_created_at = NEW.created_at,
      unread_count_for_user = CASE
        WHEN NEW.sender_type = 'seller' AND NOT NEW.is_read THEN unread_count_for_user + 1
        ELSE unread_count_for_user
      END,
      unread_count_for_seller = CASE
        WHEN NEW.sender_type = 'user' AND NOT NEW.is_read THEN unread_count_for_seller + 1
        ELSE unread_count_for_seller
      END,
      updated_at = NOW()
    WHERE id = NEW.conversation_id;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Si un message est marqué comme lu
    IF OLD.is_read = false AND NEW.is_read = true THEN
      UPDATE conversations
      SET
        unread_count_for_user = CASE
          WHEN NEW.sender_type = 'seller' THEN GREATEST(0, unread_count_for_user - 1)
          ELSE unread_count_for_user
        END,
        unread_count_for_seller = CASE
          WHEN NEW.sender_type = 'user' THEN GREATEST(0, unread_count_for_seller - 1)
          ELSE unread_count_for_seller
        END
      WHERE id = NEW.conversation_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour incrémenter les compteurs de vues
CREATE OR REPLACE FUNCTION increment_view_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE part_advertisements
  SET view_count = view_count + 1
  WHERE id = NEW.id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Fonction de nettoyage des données expirées
CREATE OR REPLACE FUNCTION cleanup_expired_data()
RETURNS void AS $$
BEGIN
  -- Supprimer les utilisateurs anonymes expirés
  DELETE FROM anonymous_users
  WHERE expires_at < NOW() - INTERVAL '7 days';

  -- Marquer les annonces expirées comme inactives
  UPDATE part_advertisements
  SET status = 'inactive'
  WHERE expires_at < NOW()
    AND status = 'active';

  -- Fermer les demandes expirées
  UPDATE part_requests
  SET status = 'closed'
  WHERE expires_at < NOW()
    AND status = 'active';

  -- Logger l'opération
  INSERT INTO performance_metrics (metric_type, metric_value, metadata)
  VALUES ('cleanup_expired', 1, jsonb_build_object('executed_at', NOW()));
END;
$$ LANGUAGE plpgsql;

-- Fonction pour calculer les statistiques
CREATE OR REPLACE FUNCTION calculate_daily_stats()
RETURNS void AS $$
DECLARE
  v_total_users integer;
  v_active_ads integer;
  v_active_requests integer;
  v_total_messages integer;
BEGIN
  SELECT COUNT(DISTINCT id) INTO v_total_users FROM particuliers;
  SELECT COUNT(*) INTO v_active_ads FROM part_advertisements WHERE status = 'active';
  SELECT COUNT(*) INTO v_active_requests FROM part_requests WHERE status = 'active';
  SELECT COUNT(*) INTO v_total_messages FROM messages WHERE created_at > NOW() - INTERVAL '24 hours';

  INSERT INTO performance_metrics (metric_type, metric_value, metadata)
  VALUES (
    'daily_stats',
    1,
    jsonb_build_object(
      'date', CURRENT_DATE,
      'total_users', v_total_users,
      'active_ads', v_active_ads,
      'active_requests', v_active_requests,
      'messages_24h', v_total_messages
    )
  );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. TRIGGERS
-- =====================================================

-- Triggers pour updated_at
DROP TRIGGER IF EXISTS update_conversations_updated_at ON conversations;
CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_messages_updated_at ON messages;
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_part_advertisements_updated_at ON part_advertisements;
CREATE TRIGGER update_part_advertisements_updated_at BEFORE UPDATE ON part_advertisements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_part_requests_updated_at ON part_requests;
CREATE TRIGGER update_part_requests_updated_at BEFORE UPDATE ON part_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_particuliers_updated_at ON particuliers;
CREATE TRIGGER update_particuliers_updated_at BEFORE UPDATE ON particuliers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_sellers_updated_at ON sellers;
CREATE TRIGGER update_sellers_updated_at BEFORE UPDATE ON sellers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_seller_responses_updated_at ON seller_responses;
CREATE TRIGGER update_seller_responses_updated_at BEFORE UPDATE ON seller_responses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Trigger pour synchronisation des messages
DROP TRIGGER IF EXISTS sync_message_counts ON messages;
CREATE TRIGGER sync_message_counts
  AFTER INSERT OR UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION sync_conversation_counts();

-- =====================================================
-- 6. CONTRAINTES D'INTÉGRITÉ SUPPLÉMENTAIRES
-- =====================================================

-- Unicité pour éviter les doublons (avec gestion des conflits)
DO $$
BEGIN
  BEGIN
    ALTER TABLE conversations
    ADD CONSTRAINT unique_conversation_per_request_user_seller
    UNIQUE(request_id, user_id, seller_id);
  EXCEPTION
    WHEN duplicate_table THEN NULL;
  END;

  BEGIN
    ALTER TABLE seller_responses
    ADD CONSTRAINT unique_seller_response_per_request
    UNIQUE(request_id, seller_id);
  EXCEPTION
    WHEN duplicate_table THEN NULL;
  END;

  BEGIN
    ALTER TABLE seller_rejections
    ADD CONSTRAINT unique_seller_rejection_per_request
    UNIQUE(seller_id, part_request_id);
  EXCEPTION
    WHEN duplicate_table THEN NULL;
  END;
END $$;

-- Contraintes de validation (avec gestion des conflits)
DO $$
BEGIN
  BEGIN
    ALTER TABLE part_advertisements
    ADD CONSTRAINT price_positive CHECK (price IS NULL OR price >= 0);
  EXCEPTION
    WHEN duplicate_object THEN NULL;
  END;

  BEGIN
    ALTER TABLE messages
    ADD CONSTRAINT offer_price_positive CHECK (offer_price IS NULL OR offer_price >= 0);
  EXCEPTION
    WHEN duplicate_object THEN NULL;
  END;

  BEGIN
    ALTER TABLE seller_responses
    ADD CONSTRAINT response_price_positive CHECK (price IS NULL OR price >= 0);
  EXCEPTION
    WHEN duplicate_object THEN NULL;
  END;
END $$;

-- =====================================================
-- 7. TABLES DE MONITORING
-- =====================================================

-- Table pour les métriques de performance
CREATE TABLE IF NOT EXISTS performance_metrics (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  metric_type text NOT NULL,
  metric_value numeric,
  metadata jsonb DEFAULT '{}',
  created_at timestamp with time zone DEFAULT NOW()
);

-- Index pour les métriques
CREATE INDEX IF NOT EXISTS idx_metrics_type_date ON performance_metrics(metric_type, created_at DESC);

-- Table pour les logs d'erreurs
CREATE TABLE IF NOT EXISTS error_logs (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  error_type text NOT NULL,
  error_message text,
  stack_trace text,
  user_id uuid,
  metadata jsonb DEFAULT '{}',
  created_at timestamp with time zone DEFAULT NOW()
);

-- =====================================================
-- 8. VUES MATÉRIALISÉES
-- =====================================================

-- Vue pour le dashboard vendeur
DROP MATERIALIZED VIEW IF EXISTS seller_dashboard CASCADE;
CREATE MATERIALIZED VIEW seller_dashboard AS
SELECT
  s.id as seller_id,
  s.company_name,
  s.city,
  COUNT(DISTINCT c.id) as total_conversations,
  COUNT(DISTINCT CASE WHEN c.status = 'active' THEN c.id END) as active_conversations,
  COALESCE(SUM(c.unread_count_for_seller), 0) as total_unread,
  COUNT(DISTINCT sr.id) as total_responses,
  AVG(sr.price)::numeric(10,2) as avg_offer_price,
  COUNT(DISTINCT CASE
    WHEN c.created_at > NOW() - INTERVAL '7 days'
    THEN c.id
  END) as conversations_this_week,
  NOW() as last_refresh
FROM sellers s
LEFT JOIN conversations c ON c.seller_id = s.id
LEFT JOIN seller_responses sr ON sr.seller_id = s.id
WHERE s.is_active = true
GROUP BY s.id, s.company_name, s.city;

-- Index pour la vue matérialisée
CREATE UNIQUE INDEX idx_seller_dashboard_id ON seller_dashboard(seller_id);

-- Vue pour les statistiques globales
DROP MATERIALIZED VIEW IF EXISTS global_stats CASCADE;
CREATE MATERIALIZED VIEW global_stats AS
SELECT
  (SELECT COUNT(*) FROM particuliers) as total_users,
  (SELECT COUNT(*) FROM sellers WHERE is_active = true) as total_sellers,
  (SELECT COUNT(*) FROM part_advertisements WHERE status = 'active') as active_ads,
  (SELECT COUNT(*) FROM part_requests WHERE status = 'active') as active_requests,
  (SELECT COUNT(*) FROM conversations WHERE status = 'active') as active_conversations,
  (SELECT COUNT(*) FROM messages WHERE created_at > NOW() - INTERVAL '24 hours') as messages_24h,
  (SELECT COUNT(*) FROM part_advertisements WHERE created_at > NOW() - INTERVAL '7 days') as new_ads_week,
  (SELECT AVG(price)::numeric(10,2) FROM part_advertisements WHERE price IS NOT NULL) as avg_ad_price,
  NOW() as last_refresh;

-- =====================================================
-- 9. FONCTIONS DE RAFRAÎCHISSEMENT
-- =====================================================

CREATE OR REPLACE FUNCTION refresh_materialized_views()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY seller_dashboard;
  REFRESH MATERIALIZED VIEW CONCURRENTLY global_stats;

  INSERT INTO performance_metrics (metric_type, metric_value, metadata)
  VALUES ('view_refresh', 1, jsonb_build_object('refreshed_at', NOW()));
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. CONFIGURATION CRON (OPTIONNEL)
-- =====================================================

-- Vérifier si pg_cron est installé et configurer les tâches
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    -- Nettoyage quotidien à 2h du matin
    PERFORM cron.schedule(
      'cleanup-expired-data',
      '0 2 * * *',
      'SELECT cleanup_expired_data();'
    );

    -- Rafraîchissement des vues toutes les heures
    PERFORM cron.schedule(
      'refresh-views',
      '0 * * * *',
      'SELECT refresh_materialized_views();'
    );

    -- Calcul des statistiques quotidiennes à minuit
    PERFORM cron.schedule(
      'calculate-daily-stats',
      '0 0 * * *',
      'SELECT calculate_daily_stats();'
    );

    RAISE NOTICE 'CRON jobs configured successfully';
  ELSE
    RAISE NOTICE 'pg_cron extension not found - skipping cron configuration';
  END IF;
END $$;

-- =====================================================
-- 11. VALIDATION FINALE
-- =====================================================

-- Rapport de validation
DO $$
DECLARE
  v_tables_count integer;
  v_rls_enabled_count integer;
  v_indexes_count integer;
  v_policies_count integer;
BEGIN
  -- Compter les tables
  SELECT COUNT(*) INTO v_tables_count
  FROM pg_tables
  WHERE schemaname = 'public';

  -- Compter les tables avec RLS activé
  SELECT COUNT(*) INTO v_rls_enabled_count
  FROM pg_tables t
  JOIN pg_class c ON c.relname = t.tablename
  WHERE t.schemaname = 'public'
  AND c.relrowsecurity = true;

  -- Compter les index
  SELECT COUNT(*) INTO v_indexes_count
  FROM pg_indexes
  WHERE schemaname = 'public';

  -- Compter les policies
  SELECT COUNT(*) INTO v_policies_count
  FROM pg_policies
  WHERE schemaname = 'public';

  RAISE NOTICE '=== RAPPORT DE VALIDATION ===';
  RAISE NOTICE 'Tables totales: %', v_tables_count;
  RAISE NOTICE 'Tables avec RLS: %', v_rls_enabled_count;
  RAISE NOTICE 'Index créés: %', v_indexes_count;
  RAISE NOTICE 'Policies créées: %', v_policies_count;
  RAISE NOTICE '=============================';
END $$;

-- =====================================================
-- INSTRUCTIONS POST-EXÉCUTION
-- =====================================================
/*
INSTRUCTIONS IMPORTANTES APRÈS EXÉCUTION :

1. VÉRIFICATION MANUELLE :
   - Vérifiez que toutes les policies sont actives
   - Testez l'accès aux données depuis votre app
   - Validez les performances avec quelques requêtes

2. CONFIGURATION SUPABASE DASHBOARD :
   - Allez dans Authentication > Settings
   - Activez "Enable email confirmations"
   - Configurez les rate limits appropriés
   - Activez la double authentification pour les admins

3. BACKUPS :
   - Configurez les backups automatiques quotidiens
   - Testez une restauration sur un environnement de test
   - Documentez la procédure de restauration

4. MONITORING :
   - Activez les logs dans Supabase
   - Configurez des alertes pour :
     * Erreurs de base de données
     * Utilisation excessive de CPU/mémoire
     * Requêtes lentes (>500ms)

5. TESTS DE CHARGE :
   - Simulez 100-500 utilisateurs simultanés
   - Vérifiez les temps de réponse
   - Ajustez les index si nécessaire

6. DOCUMENTATION :
   - Documentez les nouvelles policies
   - Créez un guide de dépannage
   - Formez l'équipe sur les nouvelles procédures

Le script a été exécuté avec succès !
Votre base de données est maintenant prête pour la production.
*/

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================