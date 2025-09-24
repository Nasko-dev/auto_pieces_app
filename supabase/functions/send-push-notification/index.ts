import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const ONESIGNAL_APP_ID = "dd1bf04c-a036-4654-9c19-92e7b20bae08"
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationRequest {
  player_ids?: string[]
  user_ids?: string[]
  device_ids?: string[]
  title: string
  message: string
  data?: Record<string, any>
  type?: 'message' | 'part_request' | 'part_response'
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
      player_ids,
      user_ids,
      device_ids,
      title,
      message,
      data,
      type = 'message'
    } = await req.json() as NotificationRequest

    // Si on a des user_ids, récupérer les player_ids depuis la DB
    let targetPlayerIds = player_ids || []

    if (user_ids && user_ids.length > 0) {
      // Import Supabase client
      const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2')

      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

      const supabase = createClient(supabaseUrl, supabaseServiceKey)

      // Récupérer les player_ids depuis push_tokens
      console.log('🔍 Recherche des Player IDs pour:', user_ids)
      const { data: tokens, error } = await supabase
        .from('push_tokens')
        .select('onesignal_player_id')
        .in('user_id', user_ids)

      console.log('📊 Tokens trouvés:', tokens)
      console.log('❌ Erreur éventuelle:', error)

      if (!error && tokens) {
        targetPlayerIds = [...targetPlayerIds, ...tokens.map(t => t.onesignal_player_id)]
      }
    }

    // Si on a des device_ids, récupérer les player_ids directement depuis push_tokens
    if (device_ids && device_ids.length > 0) {
      const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2')

      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

      const supabase = createClient(supabaseUrl, supabaseServiceKey)

      console.log('🔍 Recherche des Player IDs directement par device_ids:', device_ids)

      // Récupérer les player_ids directement par device_id dans push_tokens
      const { data: tokens, error: tokensError } = await supabase
        .from('push_tokens')
        .select('onesignal_player_id')
        .in('device_id', device_ids)

      console.log('📊 Tokens trouvés directement par device_ids:', tokens)

      if (!tokensError && tokens) {
        targetPlayerIds = [...targetPlayerIds, ...tokens.map(t => t.onesignal_player_id)]
      }
    }

    if (targetPlayerIds.length === 0) {
      throw new Error('Aucun destinataire trouvé')
    }

    // Envoyer la notification via OneSignal
    const notificationBody = {
      app_id: ONESIGNAL_APP_ID,
      include_player_ids: targetPlayerIds,
      headings: { en: title, fr: title },
      contents: { en: message, fr: message },
      data: {
        ...data,
        type,
        timestamp: new Date().toISOString()
      },
      // Style Android amélioré
      android_accent_color: 'FF2196F3',
      small_icon: 'ic_notification',
      large_icon: 'ic_launcher',
      priority: 10, // Haute priorité
      android_visibility: 1, // Public
      sound: 'default',
      android_group: 'messages',
      collapse_id: type === 'message' ? 'message' : undefined,
    }

    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify(notificationBody)
    })

    const result = await response.json()

    if (!response.ok) {
      throw new Error(`OneSignal error: ${JSON.stringify(result)}`)
    }

    return new Response(
      JSON.stringify({
        success: true,
        notification_id: result.id,
        recipients: targetPlayerIds.length
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})