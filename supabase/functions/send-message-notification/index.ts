import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const ONESIGNAL_APP_ID = 'dd1bf04c-a036-4654-9c19-92e7b20bae08'
const ONESIGNAL_API_URL = 'https://onesignal.com/api/v1/notifications'

interface MessagePayload {
  message_id: string
  sender_id: string
  recipient_id: string
  content: string
  sender_name?: string
  conversation_id?: string
}

serve(async (req) => {
  try {
    console.log('🔔 Edge Function: send-message-notification triggered')

    // Vérification de la méthode HTTP
    if (req.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 })
    }

    // Récupération du payload
    const payload: MessagePayload = await req.json()
    console.log('📨 Payload reçu:', payload)

    const {
      message_id,
      sender_id,
      recipient_id,
      content,
      sender_name = 'Quelqu\'un',
      conversation_id
    } = payload

    // Récupération de la clé API OneSignal depuis les secrets
    const oneSignalApiKey = Deno.env.get('ONESIGNAL_API_KEY')
    if (!oneSignalApiKey) {
      console.error('❌ ONESIGNAL_API_KEY manquante')
      return new Response('Configuration manquante', { status: 500 })
    }

    // Récupération du Player ID OneSignal du destinataire
    const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseKey)

    // Chercher le Player ID dans la table particuliers
    const { data: particulier, error: particulierError } = await supabase
      .from('particuliers')
      .select('onesignal_player_id')
      .eq('id', recipient_id)
      .single()

    if (particulierError || !particulier?.onesignal_player_id) {
      console.log(`⚠️ Pas de Player ID OneSignal pour le particulier ${recipient_id}`)
      return new Response('Utilisateur non configuré pour les notifications', { status: 200 })
    }

    const playerIDs = [particulier.onesignal_player_id]
    console.log('🎯 Envoi vers Player ID:', playerIDs)

    // Préparation du message de notification
    const notificationTitle = `💬 ${sender_name}`
    const notificationBody = content.length > 100 ?
      content.substring(0, 97) + '...' :
      content

    // Données additionnelles pour la navigation dans l'app
    const additionalData = {
      type: 'new_message',
      message_id,
      sender_id,
      conversation_id,
      click_action: 'OPEN_CONVERSATION'
    }

    // Payload OneSignal
    const oneSignalPayload = {
      app_id: ONESIGNAL_APP_ID,
      include_player_ids: playerIDs,
      headings: { en: notificationTitle },
      contents: { en: notificationBody },
      data: additionalData,
      android_channel_id: 'fcm_fallback_notification_channel',
      priority: 10,
      ttl: 259200, // 3 jours
      android_sound: 'default',
      ios_sound: 'default'
    }

    console.log('📤 Envoi vers OneSignal:', oneSignalPayload)

    // Envoi vers OneSignal
    const oneSignalResponse = await fetch(ONESIGNAL_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${oneSignalApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(oneSignalPayload)
    })

    const oneSignalResult = await oneSignalResponse.json()
    console.log('📨 Réponse OneSignal:', oneSignalResult)

    if (!oneSignalResponse.ok) {
      console.error('❌ Erreur OneSignal:', oneSignalResult)
      return new Response('Erreur lors de l\'envoi de la notification', { status: 500 })
    }

    console.log('✅ Notification envoyée avec succès')
    return new Response(JSON.stringify({
      success: true,
      notification_id: oneSignalResult.id,
      recipients: oneSignalResult.recipients
    }), {
      headers: { 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('💥 Erreur dans send-message-notification:', error)
    return new Response(JSON.stringify({
      error: 'Erreur interne',
      details: error.message
    }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})