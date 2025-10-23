-- ============================================
-- MIGRATION: Système de Gestion de Stock
-- Date: 22 janvier 2025
-- Description: Ajout des fonctionnalités de gestion d'inventaire pour les annonces
-- ============================================

-- 1. Ajouter les colonnes de gestion de stock à part_advertisements
ALTER TABLE part_advertisements
  ADD COLUMN IF NOT EXISTS stock_type VARCHAR(20) DEFAULT 'single' CHECK (stock_type IN ('single', 'multiple', 'unlimited')),
  ADD COLUMN IF NOT EXISTS quantity INTEGER,
  ADD COLUMN IF NOT EXISTS initial_quantity INTEGER,
  ADD COLUMN IF NOT EXISTS sold_quantity INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS reserved_quantity INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER DEFAULT 1,
  ADD COLUMN IF NOT EXISTS auto_disable_when_empty BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS stock_alert_enabled BOOLEAN DEFAULT true;

-- 2. Ajouter des commentaires pour la documentation
COMMENT ON COLUMN part_advertisements.stock_type IS 'Type de stock: single (pièce unique), multiple (quantité limitée), unlimited (stock illimité)';
COMMENT ON COLUMN part_advertisements.quantity IS 'Quantité disponible en stock (NULL si unlimited)';
COMMENT ON COLUMN part_advertisements.initial_quantity IS 'Quantité initiale (pour statistiques)';
COMMENT ON COLUMN part_advertisements.sold_quantity IS 'Nombre de pièces vendues';
COMMENT ON COLUMN part_advertisements.reserved_quantity IS 'Nombre de pièces réservées temporairement';
COMMENT ON COLUMN part_advertisements.low_stock_threshold IS 'Seuil pour alerte stock bas';
COMMENT ON COLUMN part_advertisements.auto_disable_when_empty IS 'Désactiver automatiquement l''annonce quand stock = 0';
COMMENT ON COLUMN part_advertisements.stock_alert_enabled IS 'Activer les alertes de stock bas';

-- 3. Ajouter des contraintes de cohérence
ALTER TABLE part_advertisements
  ADD CONSTRAINT quantity_check CHECK (
    (stock_type = 'single' AND quantity = 1) OR
    (stock_type = 'multiple' AND quantity > 0) OR
    (stock_type = 'unlimited' AND quantity IS NULL)
  );

-- 4. Créer un index pour les requêtes de stock
CREATE INDEX IF NOT EXISTS idx_part_advertisements_stock
ON part_advertisements(stock_type, quantity)
WHERE status = 'active';

-- 5. Créer une table d'historique des mouvements de stock
CREATE TABLE IF NOT EXISTS stock_movements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  advertisement_id UUID NOT NULL REFERENCES part_advertisements(id) ON DELETE CASCADE,
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('sale', 'reserve', 'unreserve', 'restock', 'adjustment')),
  quantity_change INTEGER NOT NULL,
  quantity_before INTEGER,
  quantity_after INTEGER,
  reason TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE stock_movements IS 'Historique des mouvements de stock pour audit et statistiques';
COMMENT ON COLUMN stock_movements.movement_type IS 'Type de mouvement: sale (vente), reserve (réservation), unreserve (annulation réservation), restock (réapprovisionnement), adjustment (ajustement manuel)';

-- 6. Créer un index pour l'historique
CREATE INDEX IF NOT EXISTS idx_stock_movements_advertisement
ON stock_movements(advertisement_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_stock_movements_type
ON stock_movements(movement_type, created_at DESC);

-- 7. Fonction pour décrémenter le stock lors d'une vente
CREATE OR REPLACE FUNCTION decrement_stock(
  p_advertisement_id UUID,
  p_quantity INTEGER DEFAULT 1
) RETURNS BOOLEAN AS $$
DECLARE
  v_current_quantity INTEGER;
  v_stock_type VARCHAR(20);
  v_auto_disable BOOLEAN;
BEGIN
  -- Récupérer les infos actuelles
  SELECT quantity, stock_type, auto_disable_when_empty
  INTO v_current_quantity, v_stock_type, v_auto_disable
  FROM part_advertisements
  WHERE id = p_advertisement_id
  FOR UPDATE;

  -- Si stock illimité, ne rien faire
  IF v_stock_type = 'unlimited' THEN
    RETURN true;
  END IF;

  -- Vérifier qu'il y a assez de stock
  IF v_current_quantity < p_quantity THEN
    RAISE EXCEPTION 'Stock insuffisant';
  END IF;

  -- Décrémenter le stock
  UPDATE part_advertisements
  SET
    quantity = quantity - p_quantity,
    sold_quantity = sold_quantity + p_quantity,
    updated_at = NOW()
  WHERE id = p_advertisement_id;

  -- Enregistrer le mouvement
  INSERT INTO stock_movements (
    advertisement_id,
    movement_type,
    quantity_change,
    quantity_before,
    quantity_after
  ) VALUES (
    p_advertisement_id,
    'sale',
    -p_quantity,
    v_current_quantity,
    v_current_quantity - p_quantity
  );

  -- Si stock = 0 et auto-disable activé, désactiver l'annonce
  IF (v_current_quantity - p_quantity) = 0 AND v_auto_disable THEN
    UPDATE part_advertisements
    SET status = 'sold'
    WHERE id = p_advertisement_id;
  END IF;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Fonction pour réapprovisionner le stock
CREATE OR REPLACE FUNCTION restock_advertisement(
  p_advertisement_id UUID,
  p_quantity INTEGER,
  p_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
  v_current_quantity INTEGER;
  v_stock_type VARCHAR(20);
BEGIN
  -- Récupérer les infos actuelles
  SELECT quantity, stock_type
  INTO v_current_quantity, v_stock_type
  FROM part_advertisements
  WHERE id = p_advertisement_id
  FOR UPDATE;

  -- Si stock illimité, ne rien faire
  IF v_stock_type = 'unlimited' THEN
    RETURN true;
  END IF;

  -- Augmenter le stock
  UPDATE part_advertisements
  SET
    quantity = quantity + p_quantity,
    status = CASE
      WHEN status = 'sold' AND (quantity + p_quantity) > 0 THEN 'active'
      ELSE status
    END,
    updated_at = NOW()
  WHERE id = p_advertisement_id;

  -- Enregistrer le mouvement
  INSERT INTO stock_movements (
    advertisement_id,
    movement_type,
    quantity_change,
    quantity_before,
    quantity_after,
    reason
  ) VALUES (
    p_advertisement_id,
    'restock',
    p_quantity,
    v_current_quantity,
    v_current_quantity + p_quantity,
    p_reason
  );

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Fonction pour réserver temporairement du stock
CREATE OR REPLACE FUNCTION reserve_stock(
  p_advertisement_id UUID,
  p_quantity INTEGER DEFAULT 1
) RETURNS BOOLEAN AS $$
DECLARE
  v_available_quantity INTEGER;
  v_stock_type VARCHAR(20);
BEGIN
  -- Récupérer les infos actuelles
  SELECT quantity - reserved_quantity, stock_type
  INTO v_available_quantity, v_stock_type
  FROM part_advertisements
  WHERE id = p_advertisement_id
  FOR UPDATE;

  -- Si stock illimité, toujours OK
  IF v_stock_type = 'unlimited' THEN
    RETURN true;
  END IF;

  -- Vérifier disponibilité
  IF v_available_quantity < p_quantity THEN
    RAISE EXCEPTION 'Stock disponible insuffisant pour réservation';
  END IF;

  -- Réserver
  UPDATE part_advertisements
  SET reserved_quantity = reserved_quantity + p_quantity
  WHERE id = p_advertisement_id;

  -- Enregistrer le mouvement
  INSERT INTO stock_movements (
    advertisement_id,
    movement_type,
    quantity_change
  ) VALUES (
    p_advertisement_id,
    'reserve',
    p_quantity
  );

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Fonction pour libérer une réservation
CREATE OR REPLACE FUNCTION unreserve_stock(
  p_advertisement_id UUID,
  p_quantity INTEGER DEFAULT 1
) RETURNS BOOLEAN AS $$
BEGIN
  -- Libérer la réservation
  UPDATE part_advertisements
  SET reserved_quantity = GREATEST(0, reserved_quantity - p_quantity)
  WHERE id = p_advertisement_id;

  -- Enregistrer le mouvement
  INSERT INTO stock_movements (
    advertisement_id,
    movement_type,
    quantity_change
  ) VALUES (
    p_advertisement_id,
    'unreserve',
    -p_quantity
  );

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Vue pour afficher le stock disponible en temps réel
CREATE OR REPLACE VIEW advertisement_stock_status AS
SELECT
  pa.id,
  pa.part_name,
  pa.stock_type,
  pa.quantity AS total_quantity,
  pa.reserved_quantity,
  CASE
    WHEN pa.stock_type = 'unlimited' THEN NULL
    ELSE pa.quantity - pa.reserved_quantity
  END AS available_quantity,
  pa.sold_quantity,
  pa.low_stock_threshold,
  CASE
    WHEN pa.stock_type = 'unlimited' THEN false
    WHEN (pa.quantity - pa.reserved_quantity) <= pa.low_stock_threshold THEN true
    ELSE false
  END AS is_low_stock,
  CASE
    WHEN pa.stock_type = 'unlimited' THEN false
    WHEN (pa.quantity - pa.reserved_quantity) = 0 THEN true
    ELSE false
  END AS is_out_of_stock,
  pa.status,
  pa.created_at,
  pa.updated_at
FROM part_advertisements pa;

COMMENT ON VIEW advertisement_stock_status IS 'Vue pour consulter le statut du stock en temps réel';

-- 12. Mettre à jour les annonces existantes avec des valeurs par défaut
UPDATE part_advertisements
SET
  stock_type = 'single',
  quantity = 1,
  initial_quantity = 1,
  sold_quantity = 0,
  reserved_quantity = 0
WHERE stock_type IS NULL;

-- 13. RLS (Row Level Security) pour stock_movements
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Vendeurs peuvent voir leurs mouvements de stock"
ON stock_movements FOR SELECT
USING (
  advertisement_id IN (
    SELECT id FROM part_advertisements
    WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Système peut insérer des mouvements"
ON stock_movements FOR INSERT
WITH CHECK (true);

-- 14. Notification en temps réel pour stock bas (Edge Function trigger)
CREATE OR REPLACE FUNCTION notify_low_stock()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.stock_alert_enabled
     AND NEW.stock_type != 'unlimited'
     AND (NEW.quantity - NEW.reserved_quantity) <= NEW.low_stock_threshold
     AND (OLD.quantity - OLD.reserved_quantity) > OLD.low_stock_threshold
  THEN
    -- Envoyer notification (à implémenter côté Edge Function)
    PERFORM pg_notify(
      'low_stock_alert',
      json_build_object(
        'advertisement_id', NEW.id,
        'part_name', NEW.part_name,
        'available_quantity', NEW.quantity - NEW.reserved_quantity,
        'threshold', NEW.low_stock_threshold
      )::text
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_low_stock_notification
AFTER UPDATE OF quantity, reserved_quantity
ON part_advertisements
FOR EACH ROW
EXECUTE FUNCTION notify_low_stock();

-- ============================================
-- FIN DE LA MIGRATION
-- ============================================
