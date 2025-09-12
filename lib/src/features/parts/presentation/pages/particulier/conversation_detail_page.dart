import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/particulier_conversations_providers.dart';
import '../../../../../shared/presentation/widgets/french_license_plate.dart';

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
      _markAsRead();
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
      backgroundColor: Colors.grey[100],
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
                      child: _buildMessagesList(conversation.messages, theme),
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
        color: theme.colorScheme.primary,
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.store,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.sellerName ?? 'Vendeur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  conversation.partType ?? 'Pièce auto',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showOptionsMenu(context);
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
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

  Widget _buildMessagesList(List<dynamic> messages, ThemeData theme) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final message = sortedMessages[index];
        final isFromMe = message.isFromParticulier;
        final showTimestamp = index == 0 || 
            _shouldShowTimestamp(
              sortedMessages[index - 1].createdAt,
              message.createdAt,
            );

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.createdAt),
            _buildMessageBubble(message, isFromMe, theme),
            const SizedBox(height: 4),
          ],
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

  Widget _buildMessageBubble(dynamic message, bool isFromMe, ThemeData theme) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromMe 
            ? theme.colorScheme.primary
            : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isFromMe ? const Radius.circular(4) : null,
            bottomLeft: !isFromMe ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 16,
                color: isFromMe ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isFromMe 
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey[600],
                  ),
                ),
                if (isFromMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead 
                      ? Colors.blue[200]
                      : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isSending ? null : _sendMessage,
                  child: Center(
                    child: _isSending 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer la conversation'),
              onTap: () {
                Navigator.pop(context);
                _deleteConversation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Bloquer le vendeur'),
              onTap: () {
                Navigator.pop(context);
                _blockConversation();
              },
            ),
          ],
        ),
      ),
    );
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
}