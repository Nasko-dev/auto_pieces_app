-- Migration : Ajout système de gestion de stock pour part_advertisements
-- Date : 2025-01-20

-- Ajouter colonnes de gestion de stock
ALTER TABLE part_advertisements
ADD COLUMN IF NOT EXISTS quantity_total INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS quantity_available INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS quantity_sold INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER DEFAULT 2,
ADD COLUMN IF NOT EXISTS auto_mark_sold_when_empty BOOLEAN DEFAULT true;

-- Commentaires pour documentation
COMMENT ON COLUMN part_advertisements.quantity_total IS 'Stock initial total de la pièce';
COMMENT ON COLUMN part_advertisements.quantity_available IS 'Quantité actuellement disponible en stock';
COMMENT ON COLUMN part_advertisements.quantity_sold IS 'Nombre de pièces vendues';
COMMENT ON COLUMN part_advertisements.low_stock_threshold IS 'Seuil d''alerte stock bas (pour notifications)';
COMMENT ON COLUMN part_advertisements.auto_mark_sold_when_empty IS 'Marquer automatiquement comme vendu quand stock vide';

-- Fonction pour décrémenter le stock lors d'une vente
CREATE OR REPLACE FUNCTION decrement_stock(
  p_advertisement_id uuid,
  p_quantity integer DEFAULT 1
)
RETURNS json AS $$
DECLARE
  v_current_available integer;
  v_auto_mark boolean;
  v_result json;
BEGIN
  -- Vérifier que la quantité est positive
  IF p_quantity <= 0 THEN
    RAISE EXCEPTION 'La quantité doit être positive';
  END IF;

  -- Récupérer les infos actuelles
  SELECT quantity_available, auto_mark_sold_when_empty
  INTO v_current_available, v_auto_mark
  FROM part_advertisements
  WHERE id = p_advertisement_id AND user_id = auth.uid();

  -- Vérifier que l'annonce existe et appartient à l'utilisateur
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Annonce non trouvée ou accès refusé';
  END IF;

  -- Vérifier qu'il y a assez de stock
  IF v_current_available < p_quantity THEN
    RAISE EXCEPTION 'Stock insuffisant. Disponible: %, Demandé: %', v_current_available, p_quantity;
  END IF;

  -- Mettre à jour le stock
  UPDATE part_advertisements
  SET
    quantity_available = quantity_available - p_quantity,
    quantity_sold = quantity_sold + p_quantity,
    -- Si auto_mark activé et stock devient 0, marquer comme vendu
    status = CASE
      WHEN v_auto_mark AND (quantity_available - p_quantity) = 0 THEN 'sold'
      ELSE status
    END,
    updated_at = now()
  WHERE id = p_advertisement_id
  RETURNING json_build_object(
    'id', id,
    'quantity_available', quantity_available,
    'quantity_sold', quantity_sold,
    'status', status
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour incrémenter le stock (réappro, annulation vente)
CREATE OR REPLACE FUNCTION increment_stock(
  p_advertisement_id uuid,
  p_quantity integer DEFAULT 1
)
RETURNS json AS $$
DECLARE
  v_result json;
BEGIN
  -- Vérifier que la quantité est positive
  IF p_quantity <= 0 THEN
    RAISE EXCEPTION 'La quantité doit être positive';
  END IF;

  -- Mettre à jour le stock
  UPDATE part_advertisements
  SET
    quantity_total = quantity_total + p_quantity,
    quantity_available = quantity_available + p_quantity,
    -- Si l'annonce était vendue et qu'on rajoute du stock, la réactiver
    status = CASE
      WHEN status = 'sold' THEN 'active'
      ELSE status
    END,
    updated_at = now()
  WHERE id = p_advertisement_id AND user_id = auth.uid()
  RETURNING json_build_object(
    'id', id,
    'quantity_total', quantity_total,
    'quantity_available', quantity_available,
    'status', status
  ) INTO v_result;

  -- Vérifier que l'annonce existe et appartient à l'utilisateur
  IF v_result IS NULL THEN
    RAISE EXCEPTION 'Annonce non trouvée ou accès refusé';
  END IF;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour mettre à jour le stock directement
CREATE OR REPLACE FUNCTION update_stock(
  p_advertisement_id uuid,
  p_new_quantity integer
)
RETURNS json AS $$
DECLARE
  v_old_available integer;
  v_sold integer;
  v_result json;
BEGIN
  -- Vérifier que la quantité est positive ou nulle
  IF p_new_quantity < 0 THEN
    RAISE EXCEPTION 'La quantité ne peut pas être négative';
  END IF;

  -- Récupérer les infos actuelles
  SELECT quantity_available, quantity_sold
  INTO v_old_available, v_sold
  FROM part_advertisements
  WHERE id = p_advertisement_id AND user_id = auth.uid();

  -- Vérifier que l'annonce existe
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Annonce non trouvée ou accès refusé';
  END IF;

  -- Mettre à jour le stock
  UPDATE part_advertisements
  SET
    quantity_total = p_new_quantity + quantity_sold,
    quantity_available = p_new_quantity,
    status = CASE
      WHEN p_new_quantity = 0 AND auto_mark_sold_when_empty THEN 'sold'
      WHEN p_new_quantity > 0 AND status = 'sold' THEN 'active'
      ELSE status
    END,
    updated_at = now()
  WHERE id = p_advertisement_id
  RETURNING json_build_object(
    'id', id,
    'quantity_total', quantity_total,
    'quantity_available', quantity_available,
    'quantity_sold', quantity_sold,
    'status', status
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour vérifier la cohérence du stock
CREATE OR REPLACE FUNCTION check_stock_consistency()
RETURNS TRIGGER AS $$
BEGIN
  -- Vérifier que available + sold = total
  IF NEW.quantity_available + NEW.quantity_sold != NEW.quantity_total THEN
    NEW.quantity_total := NEW.quantity_available + NEW.quantity_sold;
  END IF;

  -- Vérifier que les quantités ne sont pas négatives
  IF NEW.quantity_available < 0 THEN
    NEW.quantity_available := 0;
  END IF;

  IF NEW.quantity_sold < 0 THEN
    NEW.quantity_sold := 0;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trigger_check_stock_consistency ON part_advertisements;
CREATE TRIGGER trigger_check_stock_consistency
  BEFORE INSERT OR UPDATE ON part_advertisements
  FOR EACH ROW
  EXECUTE FUNCTION check_stock_consistency();

-- Permissions pour les nouvelles fonctions
GRANT EXECUTE ON FUNCTION decrement_stock(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_stock(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION update_stock(uuid, integer) TO authenticated;

-- Index pour optimiser les requêtes sur le stock
CREATE INDEX IF NOT EXISTS idx_part_advertisements_stock
ON part_advertisements(quantity_available)
WHERE status = 'active';

-- Mettre à jour les annonces existantes avec les valeurs par défaut
UPDATE part_advertisements
SET
  quantity_total = 1,
  quantity_available = CASE WHEN status = 'sold' THEN 0 ELSE 1 END,
  quantity_sold = CASE WHEN status = 'sold' THEN 1 ELSE 0 END,
  low_stock_threshold = 2,
  auto_mark_sold_when_empty = true
WHERE quantity_total IS NULL;
