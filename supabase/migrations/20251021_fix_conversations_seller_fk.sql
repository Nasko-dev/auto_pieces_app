-- Migration pour permettre aux particuliers de répondre aux demandes
-- Problème: seller_id a une FK vers sellers, mais les particuliers ne sont pas dans sellers
-- Solution: Supprimer la contrainte FK stricte pour permettre seller_id de pointer vers particuliers ou sellers

-- 1. Supprimer l'ancienne contrainte FK si elle existe
ALTER TABLE conversations
DROP CONSTRAINT IF EXISTS conversations_seller_id_fkey;

-- 2. Note: On garde seller_id sans contrainte FK pour permettre:
--    - Les vendeurs (ID dans table sellers)
--    - Les particuliers répondeurs (ID dans table particuliers)
-- La validation se fera au niveau application

-- 3. Optionnel: Ajouter un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_conversations_seller_id
ON conversations(seller_id);

-- 4. Commentaire pour documentation
COMMENT ON COLUMN conversations.seller_id IS
'ID du répondeur (peut être un seller.id OU un particulier.id selon qui répond à la demande)';
