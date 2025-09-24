-- NETTOYAGE COMPLET DES TRIGGERS DE NOTIFICATION

-- 1. Supprimer tous les triggers existants
DROP TRIGGER IF EXISTS trigger_notify_new_message ON messages;

-- 2. Supprimer toutes les fonctions existantes
DROP FUNCTION IF EXISTS notify_new_message();

-- 3. Vérifier la structure des tables
-- (Juste pour debug - commentez si pas besoin)
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'conversations';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'messages';

-- 4. Créer la fonction CORRIGÉE
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
    sender_name TEXT;
    recipient_user_id UUID;
    conversation_record RECORD;
BEGIN
    -- Log pour debug
    RAISE NOTICE 'Trigger déclenché pour message ID: %', NEW.id;

    -- Récupérer les informations de la conversation
    SELECT c.particulier_user_id, c.seller_id, c.id
    INTO conversation_record
    FROM conversations c
    WHERE c.id = NEW.conversation_id;

    -- Vérifier que la conversation existe
    IF conversation_record.id IS NULL THEN
        RAISE NOTICE 'Conversation % non trouvée', NEW.conversation_id;
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Conversation trouvée: particulier=%, seller=%',
        conversation_record.particulier_user_id, conversation_record.seller_id;

    -- Déterminer qui est le destinataire (celui qui n'a pas envoyé le message)
    IF NEW.sender_id = conversation_record.particulier_user_id THEN
        -- Le particulier a envoyé, notifier le vendeur
        recipient_user_id := conversation_record.seller_id;

        -- Récupérer le nom du particulier
        SELECT COALESCE(display_name, email, 'Un particulier')
        INTO sender_name
        FROM profiles
        WHERE id = NEW.sender_id;

    ELSIF NEW.sender_id = conversation_record.seller_id THEN
        -- Le vendeur a envoyé, notifier le particulier
        recipient_user_id := conversation_record.particulier_user_id;

        -- Récupérer le nom du vendeur depuis la table sellers
        SELECT COALESCE(company_name, display_name, 'Un vendeur')
        INTO sender_name
        FROM sellers
        WHERE user_id = NEW.sender_id;

        -- Si pas trouvé dans sellers, essayer profiles
        IF sender_name IS NULL THEN
            SELECT COALESCE(display_name, email, 'Un vendeur')
            INTO sender_name
            FROM profiles
            WHERE id = NEW.sender_id;
        END IF;
    ELSE
        -- Cas d'erreur, ne pas envoyer de notification
        RAISE NOTICE 'Sender % ne correspond à aucun participant', NEW.sender_id;
        RETURN NEW;
    END IF;

    -- Éviter l'auto-notification
    IF recipient_user_id = NEW.sender_id THEN
        RAISE NOTICE 'Auto-notification évitée pour %', NEW.sender_id;
        RETURN NEW;
    END IF;

    -- Vérifier que le destinataire existe
    IF recipient_user_id IS NULL THEN
        RAISE NOTICE 'Destinataire non trouvé';
        RETURN NEW;
    END IF;

    RAISE NOTICE 'Envoi notification: % -> %', NEW.sender_id, recipient_user_id;

    -- NOTE: Edge Function call désactivée pour l'instant
    -- Décommentez quand la Edge Function sera déployée
    /*
    PERFORM
        net.http_post(
            url := current_setting('app.settings.supabase_url') || '/functions/v1/send-message-notification',
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
            ),
            body := jsonb_build_object(
                'message_id', NEW.id,
                'sender_id', NEW.sender_id,
                'recipient_id', recipient_user_id,
                'content', NEW.content,
                'sender_name', COALESCE(sender_name, 'Quelqu''un'),
                'conversation_id', NEW.conversation_id
            )
        );
    */

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Créer le trigger avec la fonction corrigée
CREATE TRIGGER trigger_notify_new_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_message();

-- 6. Commentaires pour documentation
COMMENT ON FUNCTION notify_new_message() IS 'Envoie une notification OneSignal lors de la réception d''un nouveau message - VERSION CORRIGÉE';
COMMENT ON TRIGGER trigger_notify_new_message ON messages IS 'Déclenche l''envoi de notifications pour les nouveaux messages - VERSION CORRIGÉE';

-- Fin du script