-- Fonction pour envoyer une notification lors d'un nouveau message
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
    sender_name TEXT;
    recipient_user_id UUID;
    conversation_record RECORD;
BEGIN
    -- Récupérer les informations de la conversation
    SELECT c.particulier_user_id, c.seller_id, c.id
    INTO conversation_record
    FROM conversations c
    WHERE c.id = NEW.conversation_id;

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

        -- Récupérer le nom du vendeur
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
        RETURN NEW;
    END IF;

    -- Éviter l'auto-notification
    IF recipient_user_id = NEW.sender_id THEN
        RETURN NEW;
    END IF;

    -- Vérifier que le destinataire existe
    IF recipient_user_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Appeler la Edge Function pour envoyer la notification
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

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS trigger_notify_new_message ON messages;

-- Créer le trigger pour les nouveaux messages
CREATE TRIGGER trigger_notify_new_message
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION notify_new_message();

-- Commentaire pour documentation
COMMENT ON FUNCTION notify_new_message() IS 'Envoie une notification OneSignal lors de la réception d''un nouveau message';
COMMENT ON TRIGGER trigger_notify_new_message ON messages IS 'Déclenche l''envoi de notifications pour les nouveaux messages';