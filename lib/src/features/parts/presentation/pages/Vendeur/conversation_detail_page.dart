import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/conversation_enums.dart';
import '../../providers/conversations_providers.dart';
import '../../../../../shared/presentation/widgets/loading_widget.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../widgets/chat_input_widget.dart';

class SellerConversationDetailPage extends ConsumerStatefulWidget {
  final String conversationId;

  const SellerConversationDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<SellerConversationDetailPage> createState() => _SellerConversationDetailPageState();
}

class _SellerConversationDetailPageState extends ConsumerState<SellerConversationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    print('💬 [UI] SellerConversationDetailPage initialisée pour: ${widget.conversationId}');
    
    // Charger les messages pour toutes les conversations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsControllerProvider.notifier)
          .loadConversationMessages(widget.conversationId);
      
      // Marquer la conversation comme lue
      _markAsRead();
      
      // S'abonner aux messages en temps réel pour cette conversation
      _subscribeToRealtimeMessages();
    });
  }

  void _markAsRead() {
    print('👀 [UI-VendeurDetail] Marquage conversation comme lue: ${widget.conversationId}');
    // ✅ SIMPLE: Éviter setState during build en différant l'appel
    Future.microtask(() {
      ref.read(conversationsControllerProvider.notifier).markConversationAsRead(widget.conversationId);
    });
  }
  
  void _subscribeToRealtimeMessages() {
    print('🔔 [SellerConversationDetailPage] Abonnement realtime pour conversation: ${widget.conversationId}');
    
    final realtimeService = ref.read(realtimeServiceProvider);
    
    // S'abonner aux messages de cette conversation spécifique
    realtimeService.subscribeToMessages(widget.conversationId);
    
    // Écouter les nouveaux messages via le stream spécifique à cette conversation
    _messageSubscription = realtimeService.getMessageStreamForConversation(widget.conversationId).listen((message) {
      // Vérifier que c'est bien pour notre conversation
      if (message.conversationId == widget.conversationId) {
        print('🎆 [SellerConversationDetailPage] Nouveau message reçu en temps réel!');
        
        // Envoyer au controller via la méthode unifiée
        ref.read(conversationsControllerProvider.notifier)
            .handleIncomingMessage(message);
        
        // Faire défiler vers le bas
        _scrollToBottom();
      }
    });
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void deactivate() {
    // ✅ SIMPLE: Désactiver la conversation quand on quitte (avant dispose)
    ref.read(conversationsControllerProvider.notifier)
        .setConversationInactive();
    super.deactivate();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationMessagesProvider(widget.conversationId));
    final isLoadingMessages = ref.watch(isLoadingMessagesProvider);
    final isSendingMessage = ref.watch(isSendingMessageProvider);
    final error = ref.watch(conversationsErrorProvider);
    final conversation = _getConversationFromList();

    print('💬 [UI] Chat vendeur - ${messages.length} messages, loading: $isLoadingMessages');

    // Auto-scroll vers le bas quand de nouveaux messages arrivent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: _buildInstagramAppBarTitle(conversation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Functionality téléphone
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Functionality vidéo
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'close',
                child: ListTile(
                  leading: Icon(Icons.close),
                  title: Text('Fermer la conversation'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: _buildMessagesArea(messages, isLoadingMessages, error),
          ),
          // Zone de saisie
          ChatInputWidget(
            controller: _messageController,
            onSend: (content) => _sendMessage(),
            isLoading: isSendingMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(List<Message> messages, bool isLoading, String? error) {

    if (isLoading && messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(height: 16),
            Text('Chargement des messages...'),
          ],
        ),
      );
    }

    if (error != null && messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(conversationsControllerProvider.notifier)
                    .loadConversationMessages(widget.conversationId);
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun message dans cette conversation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Démarrez la conversation avec ce client.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // Plus d'espace entre messages
          child: MessageBubbleWidget(
            message: message,
            currentUserType: MessageSenderType.seller, // Côté vendeur
            isLastMessage: index == messages.length - 1,
            otherUserName: _getUserDisplayName(conversation),
            otherUserAvatarUrl: conversation?.userAvatarUrl,
            otherUserCompany: null,
          ),
        );
      },
    );
  }

  Widget _buildInstagramAppBarTitle(dynamic conversation) {
    return Row(
      children: [
        // Avatar du particulier
        _buildUserAvatar(conversation),

        const SizedBox(width: 12),

        // Informations style Instagram
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getUserDisplayName(conversation),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'En ligne',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  dynamic _getConversationFromList() {
    final conversations = ref.watch(conversationsListProvider);
    try {
      return conversations.firstWhere((c) => c.id == widget.conversationId);
    } catch (e) {
      return null;
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    print('📤 [UI] Envoi message vendeur: $content');
    
    ref.read(conversationsControllerProvider.notifier).sendMessage(
      conversationId: widget.conversationId,
      content: content,
      messageType: MessageType.text,
    );

    _messageController.clear();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'close':
        _showCloseDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fermer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir fermer cette conversation ? '
          'Le client ne pourra plus vous envoyer de messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(conversationsControllerProvider.notifier)
                  .closeConversation(widget.conversationId);
              Navigator.of(context).pop(); // Retour à la liste
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation fermée'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(conversationsControllerProvider.notifier)
                  .deleteConversation(widget.conversationId);
              Navigator.of(context).pop(); // Retour à la liste
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation supprimée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _getUserDisplayName(dynamic conversation) {
    // Afficher le nom du particulier depuis les nouvelles données
    if (conversation?.userDisplayName != null && conversation.userDisplayName!.isNotEmpty) {
      return conversation.userDisplayName!;
    } else if (conversation?.userName != null && conversation.userName!.isNotEmpty) {
      return conversation.userName!;
    } else {
      return 'Client';
    }
  }

  Widget _buildUserAvatar(dynamic conversation) {
    if (conversation?.userAvatarUrl != null && conversation.userAvatarUrl!.isNotEmpty) {
      // Avatar avec vraie photo du particulier
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            conversation.userAvatarUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultUserAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefaultUserAvatar();
            },
          ),
        ),
      );
    } else {
      return _buildDefaultUserAvatar();
    }
  }

  Widget _buildDefaultUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF9CA3AF), const Color(0xFF6B7280)], // Gradient gris pour particulier
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}