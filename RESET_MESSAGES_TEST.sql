-- 🧹 COMMANDE SQL POUR RÉINITIALISER L'ÉTAT DES TESTS

-- 1. Marquer tous les messages de test existants comme lus
UPDATE messages
SET is_read = true, read_at = NOW()
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND content LIKE '%NOUVEAU MESSAGE%';

-- 2. Supprimer les anciens messages de test pour éviter le spam
DELETE FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1'
  AND content LIKE '%NOUVEAU MESSAGE T%';

-- 3. Vérifier l'état final - ne devrait plus y avoir de messages non lus
SELECT
    COUNT(*) as total_messages,
    COUNT(CASE WHEN is_read = false THEN 1 END) as unread_messages
FROM messages
WHERE conversation_id = '63175f1f-a4dc-4101-911d-0ba540fd06d1';

-- État propre pour démarrer les tests ✨