# DIAGRAMME ARCHITECTURE MESSAGERIE TEMPS RÉEL

## 🏗️ VUE D'ENSEMBLE - CLEAN ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐    ┌─────────────────┐ │
│  │   PARTICULIER UI     │    │     VENDEUR UI       │    │   SHARED UI     │ │
│  ├──────────────────────┤    ├──────────────────────┤    ├─────────────────┤ │
│  │ ConversationsListPage│    │ MessagesPage         │    │ConversationItem │ │
│  │ ConversationDetail   │    │ ConversationDetail   │    │Widget           │ │
│  │ ChatPage            │    │                      │    │(Polyvalent)     │ │
│  └──────────────────────┘    └──────────────────────┘    └─────────────────┘ │
│                   │                      │                        │          │
│                   ▼                      ▼                        ▼          │
│  ┌──────────────────────┐    ┌──────────────────────┐    ┌─────────────────┐ │
│  │  PARTICULIER         │    │    VENDEUR           │    │   REAL-TIME     │ │
│  │  CONTROLLERS         │    │    CONTROLLERS       │    │   SERVICE       │ │
│  ├──────────────────────┤    ├──────────────────────┤    ├─────────────────┤ │
│  │ParticulierConvers.   │    │ ConversationsCtrl    │    │ RealtimeService │ │
│  │Controller            │    │                      │    │ (Centralisé)    │ │
│  │+ loadConversations() │    │+ getConversations()  │    │+ subscriptions  │ │
│  │+ calcUnreadCounts()  │    │+ sendMessage()       │    │+ globalMessages │ │
│  │+ realtime subscript. │    │+ markAsRead()        │    │+ polling 30s    │ │
│  └──────────────────────┘    └──────────────────────┘    └─────────────────┘ │
│                   │                      │                        │          │
└─────────────────────────────────────────────────────────────────────────────┘
                    │                      │                        │
                    ▼                      ▼                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               DOMAIN LAYER                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐    ┌─────────────────┐ │
│  │    PARTICULIER       │    │      VENDEUR         │    │     SHARED      │ │
│  │     ENTITIES         │    │      ENTITIES        │    │    ENTITIES     │ │
│  ├──────────────────────┤    ├──────────────────────┤    ├─────────────────┤ │
│  │ParticulierConversation│   │ Conversation         │    │ConversationEnum │ │
│  │+ id: String          │    │+ id: String          │    │MessageType      │ │
│  │+ partRequest         │    │+ requestId           │    │MessageSenderType│ │
│  │+ sellerName          │    │+ userId/sellerId     │    │ConversationStat.│ │
│  │+ messages: List<>    │    │+ lastMessageContent  │    │                 │ │
│  │+ unreadCount: int ⭐  │    │+ unreadCount: int ⭐  │    │                 │ │
│  │+ hasUnreadMessages   │    │+ totalMessages       │    │                 │ │
│  └──────────────────────┘    └──────────────────────┘    └─────────────────┘ │
│                                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐                      │
│  │ ParticulierMessage   │    │     Message          │                      │ │
│  ├──────────────────────┤    ├──────────────────────┤                      │
│  │+ id: String          │    │+ id: String          │                      │
│  │+ conversationId      │    │+ conversationId      │                      │
│  │+ senderId            │    │+ senderId            │                      │
│  │+ content: String     │    │+ senderType ⭐        │                      │
│  │+ isFromParticulier⭐  │    │+ content: String     │                      │
│  │+ isRead: bool ⭐      │    │+ isRead: bool ⭐      │                      │
│  │+ createdAt           │    │+ createdAt           │                      │
│  └──────────────────────┘    └──────────────────────┘                      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                    REPOSITORY INTERFACES                               │ │
│  ├─────────────────────────────────────────────────────────────────────────┤ │
│  │ PartRequestRepository                                                   │ │
│  │ + getParticulierConversations(): Either<Failure, List<ParticConvers>>  │ │
│  │ + getParticulierConversationById(): Either<Failure, ParticConvers>     │ │
│  │ + sendParticulierMessage(): Either<Failure, void>                      │ │
│  │ + markParticulierConversationAsRead(): Either<Failure, void>           │ │
│  │                                                                         │ │
│  │ ConversationsRepository                                                 │ │
│  │ + getConversations(): Either<Failure, List<Conversation>>              │ │
│  │ + sendMessage(): Either<Failure, Message>                              │ │
│  │ + markMessagesAsRead(): Either<Failure, void>                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 DATA LAYER                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                       REPOSITORY IMPLEMENTATIONS                        │ │
│  ├─────────────────────────────────────────────────────────────────────────┤ │
│  │ PartRequestRepositoryImpl                                               │ │
│  │ + getParticulierConversations() {                                      │ │
│  │     return remoteDataSource.getParticulierConversations()              │ │
│  │   }                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                          REMOTE DATA SOURCES                           │ │
│  ├─────────────────────────────────────────────────────────────────────────┤ │
│  │ ConversationsRemoteDataSourceImpl                                      │ │
│  │                                                                         │ │
│  │ + getConversations(userId) {                                           │ │
│  │     // 🔍 AUTO-DÉTECTION TYPE UTILISATEUR                             │ │
│  │     if (_checkIfUserIsSeller(userId)) {                               │ │
│  │       return _getSellerConversations(userId)                          │ │
│  │     } else {                                                           │ │
│  │       return _getParticulierConversations(userId)                     │ │
│  │     }                                                                   │ │
│  │   }                                                                     │ │
│  │                                                                         │ │
│  │ + _getParticulierConversations() {                                     │ │
│  │     // 📱 DEVICE ID LOOKUP pour persistance                           │ │
│  │     deviceId = await deviceService.getDeviceId()                      │ │
│  │     particuliers = supabase.from('particuliers')                      │ │
│  │                          .select('id')                                │ │
│  │                          .eq('device_id', deviceId)                   │ │
│  │   }                                                                     │ │
│  │                                                                         │ │
│  │ + _getSellerConversations() {                                          │ │
│  │     // 🧮 CALCUL LOCAL UNREAD COUNT                                    │ │
│  │     messages = await getMessages(conversationId)                       │ │
│  │     unreadCount = messages.where(msg =>                                │ │
│  │       !msg.isRead && msg.senderId != sellerId).length                 │ │
│  │   }                                                                     │ │
│  │                                                                         │ │
│  │ + subscribeToNewMessages(conversationId) {                             │ │
│  │     return supabase.from('messages')                                   │ │
│  │                   .stream(primaryKey: ['id'])                          │ │
│  │                   .eq('conversation_id', conversationId)               │ │
│  │   }                                                                     │ │
│  │                                                                         │ │
│  │ + _mapSupabaseToConversation() {                                       │ │
│  │     // 🔄 MAPPING ROBUSTE sender_type                                  │ │
│  │     'senderType': json['sender_type'] ?? 'user',                       │ │
│  │     'unreadCount': json['unread_count'] ?? 0,                          │ │
│  │   }                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              EXTERNAL LAYER                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐    ┌─────────────────┐ │
│  │     SUPABASE         │    │    DEVICE STORAGE    │    │   REAL-TIME     │ │
│  │     DATABASE         │    │                      │    │   SUBSCRIPTIONS │ │
│  ├──────────────────────┤    ├──────────────────────┤    ├─────────────────┤ │
│  │                      │    │                      │    │                 │ │
│  │ ┌──conversations───┐ │    │ SharedPreferences    │    │ Supabase        │ │
│  │ │id               │ │    │ + device_id          │    │ Realtime        │ │
│  │ │request_id       │ │    │ + user_preferences   │    │                 │ │
│  │ │user_id          │ │    │                      │    │ PostgresChanges │ │
│  │ │seller_id        │ │    │ DeviceService        │    │ + INSERT events │ │
│  │ │unread_count ⭐   │ │    │ + getDeviceId()      │    │ + UPDATE events │ │
│  │ │last_message_at  │ │    │ + persistance cross- │    │                 │ │
│  │ │status           │ │    │   session            │    │ Channel:        │ │
│  │ └─────────────────┘ │    │                      │    │'global_messages'│ │
│  │                      │    │                      │    │                 │ │
│  │ ┌──messages────────┐ │    │                      │    │                 │ │
│  │ │id               │ │    │                      │    │                 │ │
│  │ │conversation_id  │ │    │                      │    │                 │ │
│  │ │sender_id        │ │    │                      │    │                 │ │
│  │ │sender_type ⭐    │ │    │                      │    │                 │ │
│  │ │content          │ │    │                      │    │                 │ │
│  │ │is_read ⭐        │ │    │                      │    │                 │ │
│  │ │created_at (UTC) │ │    │                      │    │                 │ │
│  │ └─────────────────┘ │    │                      │    │                 │ │
│  │                      │    │                      │    │                 │ │
│  │ ┌──particuliers────┐ │    │                      │    │                 │ │
│  │ │id               │ │    │                      │    │                 │ │
│  │ │device_id ⭐      │ │    │                      │    │                 │ │
│  │ │phone            │ │    │                      │    │                 │ │
│  │ └─────────────────┘ │    │                      │    │                 │ │
│  │                      │    │                      │    │                 │ │
│  │ ┌──sellers─────────┐ │    │                      │    │                 │ │
│  │ │id               │ │    │                      │    │                 │ │
│  │ │company_name     │ │    │                      │    │                 │ │
│  │ │email            │ │    │                      │    │                 │ │
│  │ └─────────────────┘ │    │                      │    │                 │ │
│  └──────────────────────┘    └──────────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 FLUX DE DONNÉES - NOUVEAU MESSAGE → EFFETS VISUELS

```
    📨 NOUVEAU MESSAGE ENVOYÉ
           │
           ▼
┌─────────────────────────────────┐
│        SUPABASE DB              │
│                                 │
│ INSERT INTO messages (          │
│   conversation_id: 'conv-123',  │
│   sender_id: 'seller-456',      │
│   sender_type: 'seller', ⭐      │
│   content: 'Bonjour!',          │
│   is_read: false ⭐              │
│ )                               │
└─────────────────────────────────┘
           │
           ▼ PostgreSQL NOTIFY
┌─────────────────────────────────┐
│     SUPABASE REALTIME           │
│                                 │
│ Channel: 'global_messages'      │
│ Event: PostgresChangeEvent      │
│ Payload: {                      │
│   "conversation_id": "conv-123", │
│   "sender_id": "seller-456",    │
│   "sender_type": "seller"       │
│ }                               │
└─────────────────────────────────┘
           │
           ▼ Stream Event
┌─────────────────────────────────┐
│  PARTICULIER CONTROLLER         │
│                                 │
│ _subscribeToGlobalMessages() {  │
│   channel.onPostgresChanges(    │
│     callback: (payload) => {    │
│       _handleGlobalNewMessage() │
│     }                           │
│   )                             │
│ }                               │
│                                 │
│ _handleGlobalNewMessage() {     │
│   if (senderId != currentUser) { │
│     🚀 loadConversations()      │
│   }                             │
│ }                               │
└─────────────────────────────────┘
           │
           ▼ Repository Call
┌─────────────────────────────────┐
│       DATA SOURCE               │
│                                 │
│ getParticulierConversations() { │
│   📱 deviceId = getDeviceId()   │
│   🔍 userIds = findByDevice()   │
│   📡 conversations = supabase   │
│        .from('conversations')   │
│        .inFilter('user_id',     │
│                  userIds)       │
│   return conversations          │
│ }                               │
└─────────────────────────────────┘
           │
           ▼ Data Processing
┌─────────────────────────────────┐
│      CONTROLLER                 │
│                                 │
│ _calculateAndUpdateUnreadCounts │
│ (conversations) {               │
│                                 │
│   for (conversation in list) {  │
│     unreadCount = 0             │
│     for (message in messages) { │
│       isFromVendeur =           │
│         !msg.isFromParticulier  │
│       if (!msg.isRead &&        │
│           isFromVendeur) {      │
│         unreadCount++ ⭐         │
│       }                         │
│     }                           │
│     🔄 conversation.copyWith(   │
│          unreadCount: count)    │
│   }                             │
│ }                               │
└─────────────────────────────────┘
           │
           ▼ State Update
┌─────────────────────────────────┐
│       RIVERPOD STATE            │
│                                 │
│ state = state.copyWith(         │
│   conversations: updated,       │
│   unreadCount: totalUnread      │
│ )                               │
│                                 │
│ ⚡ notifyListeners()            │
└─────────────────────────────────┘
           │
           ▼ Widget Rebuild
┌─────────────────────────────────┐
│   CONVERSATION ITEM WIDGET      │
│                                 │
│ didUpdateWidget() {             │
│   _updateAnimation() ⭐          │
│ }                               │
│                                 │
│ _updateAnimation() {            │
│   hasUnread = conversation      │
│             .unreadCount > 0    │
│                                 │
│   if (hasUnread) {              │
│     🎆 animationController      │
│        .repeat(reverse: true)   │
│   }                             │
│ }                               │
│                                 │
│ build() {                       │
│   return AnimatedBuilder(       │
│     child: Transform.scale(     │
│       scale: hasUnread ?        │
│         _pulseAnimation.value : │
│         1.0 ⭐                   │
│     )                           │
│   )                             │
│ }                               │
└─────────────────────────────────┘
           │
           ▼ Visual Effects
┌─────────────────────────────────┐
│        UI RENDERING             │
│                                 │
│ 🎨 EFFETS VISUELS:              │
│                                 │
│ ✨ Transform.scale(1.05)        │
│    Animation pulse continue     │
│                                 │
│ 🔴 Card(                        │
│      elevation: 6,              │
│      shadowColor: Colors.red    │
│    )                            │
│                                 │
│ 🔲 BorderSide(                  │
│      color: Colors.red,         │
│      width: 2                   │
│    )                            │
│                                 │
│ 🌈 LinearGradient(              │
│      colors: [red.opacity(0.08), │
│               Colors.white]      │
│    )                            │
│                                 │
│ 🔴 Badge(                       │
│      color: Colors.red,         │
│      text: unreadCount          │
│    )                            │
└─────────────────────────────────┘
           │
           ▼
    👀 UTILISATEUR VOIT LES EFFETS
```

## ⚡ OPTIMISATIONS PERFORMANCE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          OPTIMISATIONS APPLIQUÉES                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🔄 REALTIME ARCHITECTURE                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ AVANT (Triple abonnement)    │    APRÈS (Single abonnement)           │ │
│  │                              │                                         │ │
│  │ ┌─Controller────┐             │    ┌─Controller────┐                   │ │
│  │ │ - subscribe() │             │    │ - subscribe() │ ⭐ UNIQUE          │ │
│  │ └───────────────┘             │    └───────────────┘                   │ │
│  │ ┌─ChatPage──────┐             │    ┌─ChatPage──────┐                   │ │
│  │ │ - subscribe() │ ❌ REDONDANT │    │ - listen only │ ✅ PASSIF          │ │
│  │ └───────────────┘             │    └───────────────┘                   │ │
│  │ ┌─DataSource────┐             │    ┌─DataSource────┐                   │ │
│  │ │ - subscribe() │ ❌ REDONDANT │    │ - no realtime │ ✅ SIMPLE API      │ │
│  │ └───────────────┘             │    └───────────────┘                   │ │
│  │                              │                                         │ │
│  │ 📈 Résultat: Messages x3     │    📉 Résultat: Message unique         │ │
│  │ 🐌 Performance dégradée      │    ⚡ Performance optimale              │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ⏰ POLLING STRATEGY                                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ AVANT                        │    APRÈS                                │ │
│  │ Timer.periodic(10 seconds)   │    Timer.periodic(30 seconds)          │ │
│  │ + loadConversations() full   │    + _loadConversationsQuietly()       │ │
│  │ + setState on every call     │    + setState only on changes          │ │
│  │                              │                                         │ │
│  │ 📊 Impact:                   │    📊 Impact:                           │ │
│  │ • 6 calls/minute             │    • 2 calls/minute                     │ │
│  │ • UI flickering              │    • Smooth updates                     │ │
│  │ • Battery drain              │    • Battery friendly                   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  🧮 UNREAD COUNT CALCULATION                                                │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ AVANT (Inefficace)           │    APRÈS (Optimisé)                     │ │
│  │                              │                                         │ │
│  │ conversations.map((c) => {   │    conversations.map((c) => {           │ │
│  │   final unread = c.messages  │      int unread = 0;                    │ │
│  │     .where((m) => !m.isRead  │      for (final m in c.messages) {     │ │
│  │            && isFromVendeur) │        if (!m.isRead && isFromVendeur) │ │
│  │     .length;                 │          unread++;                      │ │
│  │                              │      }                                  │ │
│  │   return c.copyWith(         │      if (c.unreadCount != unread) {    │ │
│  │     unreadCount: unread      │        return c.copyWith(              │ │
│  │   );                         │          unreadCount: unread);         │ │
│  │ })                           │      }                                  │ │
│  │                              │      return c; // ⭐ Évite copyWith    │ │
│  │ 📈 Complexité: O(n²)         │    })                                   │ │
│  │ 🐌 copyWith() systématique   │    📉 Complexité: O(n)                 │ │
│  │                              │    ⚡ copyWith() conditionnel           │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  💾 MEMORY & STATE MANAGEMENT                                               │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ • AnimationController dispose() correctement                           │ │
│  │ • Timer.cancel() dans dispose()                                        │ │
│  │ • Stream subscriptions properly closed                                 │ │
│  │ • Conditional copyWith() pour éviter rebuilds inutiles                 │ │
│  │ • Logs debug détaillés pour troubleshooting                            │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔧 POINTS CRITIQUES CORRIGÉS

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             CORRECTIONS MAJEURES                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ❌ BUG: Mapping sender_type incorrect                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ PROBLÈME:                                                               │ │
│  │ • BDD stocke: sender_type = 'user' (particulier) / 'seller' (vendeur) │ │
│  │ • Code particulier: isFromParticulier = boolean                        │ │
│  │ • Mapping: 'user' → isFromParticulier = ??? ❌ CONFUSION              │ │
│  │                                                                         │ │
│  │ SYMPTÔME:                                                               │ │
│  │ • unreadCount toujours = 0                                             │ │
│  │ • Effets visuels jamais déclenchés                                     │ │
│  │ • Messages non lus invisibles                                          │ │
│  │                                                                         │ │
│  │ SOLUTION APPLIQUÉE:                                                     │ │
│  │ ✅ _mapSupabaseToMessage() {                                           │ │
│  │     // Mapping explicite et robuste                                    │ │
│  │     isFromParticulier: json['sender_type'] == 'user',                  │ │
│  │   }                                                                     │ │
│  │                                                                         │ │
│  │ ✅ _calculateAndUpdateUnreadCounts() {                                 │ │
│  │     final isFromVendeur = !msg.isFromParticulier;                      │ │
│  │     // Logique claire: vendeur = NOT particulier                       │ │
│  │   }                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ❌ PROBLÈME: Triple abonnement Realtime                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ IMPACT:                                                                 │ │
│  │ • Messages reçus en triple exemplaire                                  │ │
│  │ • Performance dégradée (3x bandwidth)                                  │ │
│  │ • UI confused avec updates concurrents                                 │ │
│  │                                                                         │ │
│  │ SOLUTION:                                                               │ │
│  │ ✅ Centralisation dans Controller uniquement                           │ │
│  │ ✅ ChatPage devient passive (écoute state seulement)                   │ │
│  │ ✅ DataSource = API calls pure (no realtime)                          │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ❌ PROBLÈME: Timestamps UTC/Local mélangés                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ SYMPTÔME:                                                               │ │
│  │ • Décalage 2h affiché (France UTC+2)                                   │ │
│  │ • Incohérence: "Il y a 2h" pour message à l'instant                   │ │
│  │                                                                         │ │
│  │ SOLUTION:                                                               │ │
│  │ ✅ Backend: Supabase 'now()' pour UTC consistant                       │ │
│  │ ✅ Frontend: .toLocal() dans tous les widgets UI                       │ │
│  │ ✅ Conversion centralisée dans _formatTimestamp()                      │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ❌ PROBLÈME: markAsRead() automatique frustrant                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ UX PROBLÉMATIQUE:                                                       │ │
│  │ • Tap sur conversation → markAsRead() immédiat                         │ │
│  │ • Utilisateur n'a pas le temps de lire                                 │ │
│  │ • Badge disparait avant lecture réelle                                 │ │
│  │                                                                         │ │
│  │ AMÉLIORATION:                                                           │ │
│  │ ✅ Suppression markAsRead() automatique                                │ │
│  │ ✅ Contrôle utilisateur: bouton explicite "Marquer lu"                 │ │
│  │ ✅ Badge persiste jusqu'à action délibérée                             │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ❌ PROBLÈME: Effets visuels cachés                                          │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │ DEBUG DIFFICILE:                                                        │ │
│  │ • Badge visible seulement si unreadCount > 0                           │ │
│  │ • Si bug de calcul → badge invisible = impossible à débugger           │ │
│  │                                                                         │ │
│  │ SOLUTION DEBUG:                                                         │ │
│  │ ✅ Badge toujours visible avec couleur conditionnelle                  │ │
│  │ ✅ Logs détaillés pour chaque étape de calcul                          │ │
│  │ ✅ Animation visible même avec count = 0 (debug)                       │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

*📐 Diagrammes créés le 13 septembre 2025*  
*🏗️ Architecture Flutter Clean + Riverpod + Supabase*  
*🎯 Focus: Structure, Flux de données et Optimisations*