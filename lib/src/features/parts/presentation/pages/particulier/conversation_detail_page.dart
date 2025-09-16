import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/providers/particulier_conversations_providers.dart';
import '../../../../../shared/presentation/widgets/french_license_plate.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../../domain/entities/conversation_enums.dart';

class ConversationDetailPage extends ConsumerStatefulWidget {
  final String conversationId;
  
  const ConversationDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends ConsumerState<ConversationDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Charger les détails de la conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversationDetails();
      // _markAsRead(); // Marquage désactivé temporairement
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadConversationDetails() {
    ref.read(particulierConversationsControllerProvider.notifier).loadConversationDetails(widget.conversationId);
  }

  void _markAsRead() {
    print('👀 [UI-ParticulierDetail] Marquage conversation comme lue: ${widget.conversationId}');
    ref.read(particulierConversationsControllerProvider.notifier).markConversationAsRead(widget.conversationId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(particulierConversationsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: conversationsAsync.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : conversationsAsync.error != null
            ? _buildErrorView(context, conversationsAsync.error!)
            : () {
                final conversation = conversationsAsync.conversations
                    .where((c) => c.id == widget.conversationId)
                    .firstOrNull;
          
                if (conversation == null) {
                  return _buildNotFoundView(context);
                }

                return Column(
                  children: [
                    _buildAppBar(context, conversation, theme),
                    _buildConversationInfo(conversation, theme),
                    Expanded(
                      child: _buildMessagesList(conversation.messages, conversation, theme),
                    ),
                    _buildMessageInput(theme),
                  ],
                );
              }(),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic conversation, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          _buildSellerAvatar(conversation),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSellerDisplayName(conversation),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () => _makePhoneCall(conversation),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            onPressed: () => _makeVideoCall(conversation),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Bloquer le vendeur'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversationInfo(dynamic conversation, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    conversation.vehiclePlate ?? 'AA-123-BB',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              (conversation.partNames as List?)?.join(', ') ?? 'Pièces demandées',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<dynamic> messages, dynamic conversation, ThemeData theme) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message dans cette conversation',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Trier les messages par date
    final sortedMessages = List.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final isFromMe = message.isFromParticulier;
        final showTimestamp = index == 0 ||
            _shouldShowTimestamp(
              sortedMessages[index - 1].createdAt,
              message.createdAt,
            );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              if (showTimestamp) _buildTimestamp(message.createdAt),
              _buildMessageBubbleWithAvatar(message, conversation),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimestamp(DateTime dateTime) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _formatTimestamp(dateTime),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), // Gris Instagram
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6), // Bleu Instagram
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isSending ? null : _sendMessage,
                  child: Center(
                    child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _loadConversationDetails();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundView(BuildContext context) {
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
            'Conversation introuvable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ref
          .read(particulierConversationsControllerProvider.notifier)
          .sendMessage(widget.conversationId, content);
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'delete':
        _deleteConversation();
        break;
      case 'block':
        _blockConversation();
        break;
    }
  }

  void _deleteConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(particulierConversationsControllerProvider.notifier)
            .deleteConversation(widget.conversationId);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _blockConversation() async {
    // TODO: Implémenter le blocage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
      ),
    );
  }

  bool _shouldShowTimestamp(DateTime previous, DateTime current) {
    return current.difference(previous).inMinutes > 15;
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal(); // Conversion UTC vers heure locale
    final difference = now.difference(localDateTime);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${localDateTime.day}/${localDateTime.month}/${localDateTime.year} ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal(); // Conversion UTC vers heure locale
    return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageBubbleWithAvatar(dynamic message, dynamic conversation) {
    return MessageBubbleWidget(
      message: message,
      currentUserType: MessageSenderType.user, // Côté particulier
      isLastMessage: false, // Géré différemment dans cette page
      otherUserName: _getSellerDisplayName(conversation),
      otherUserAvatarUrl: conversation.sellerAvatarUrl,
      otherUserCompany: conversation.sellerCompany,
    );
  }

  Widget _buildSellerAvatar(dynamic conversation) {
    if (conversation.sellerAvatarUrl != null && conversation.sellerAvatarUrl!.isNotEmpty) {
      // Avatar style Instagram avec vraie photo
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
            conversation.sellerAvatarUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultSellerAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildDefaultSellerAvatar();
            },
          ),
        ),
      );
    } else {
      return _buildDefaultSellerAvatar();
    }
  }

  Widget _buildDefaultSellerAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF405DE6), const Color(0xFF5851DB)], // Gradient Instagram bleu
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
        Icons.business,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  String _getSellerDisplayName(dynamic conversation) {
    // Priorité : nom d'entreprise > nom vendeur > "Vendeur"
    if (conversation.sellerCompany != null && conversation.sellerCompany!.isNotEmpty) {
      return conversation.sellerCompany!;
    } else if (conversation.sellerName != null && conversation.sellerName!.isNotEmpty) {
      return conversation.sellerName!;
    } else {
      return 'Vendeur Professionnel';
    }
  }

  String _getSellerSubtitle(dynamic conversation) {
    // Si on affiche l'entreprise en haut, mettre le nom du vendeur en bas
    if (conversation.sellerCompany != null &&
        conversation.sellerCompany!.isNotEmpty &&
        conversation.sellerName != null &&
        conversation.sellerName!.isNotEmpty) {
      return conversation.sellerName!;
    } else {
      // Sinon afficher le type de pièce
      return conversation.partType ?? 'Pièce auto';
    }
  }

  Future<void> _makePhoneCall(dynamic conversation) async {
    // Pour l'instant, nous n'avons pas le numéro du vendeur dans les données
    // On peut implémenter une solution alternative
    print('📞 [UI-Particulier] Tentative d\'appel vers le vendeur');

    _showInfoSnackBar('Contactez le vendeur via la messagerie pour obtenir son numéro');
  }

  Future<void> _makeVideoCall(dynamic conversation) async {
    // Pour l'instant, nous n'avons pas le numéro du vendeur dans les données
    print('📹 [UI-Particulier] Tentative d\'appel vidéo vers le vendeur');

    _showInfoSnackBar('Contactez le vendeur via la messagerie pour organiser un appel vidéo');
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}