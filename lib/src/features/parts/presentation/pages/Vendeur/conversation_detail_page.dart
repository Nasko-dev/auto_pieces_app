import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/conversation_enums.dart';
import '../../providers/conversations_providers.dart';
import '../../../../../shared/presentation/widgets/loading_widget.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../widgets/chat_input_widget.dart';
import '../../../../../core/providers/message_image_providers.dart';
import '../../../../../core/providers/session_providers.dart';
import '../../../../../core/services/global_message_notification_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';

class SellerConversationDetailPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String? prefilledMessage;

  const SellerConversationDetailPage({
    super.key,
    required this.conversationId,
    this.prefilledMessage,
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

    // Informer le service global que cette conversation est active
    GlobalMessageNotificationService().setActiveConversation(widget.conversationId);

    // Pré-remplir le message si fourni
    if (widget.prefilledMessage != null) {
      _messageController.text = widget.prefilledMessage!;
    }

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
    // ✅ SIMPLE: Éviter setState during build en différant l'appel
    Future.microtask(() {
      ref.read(conversationsControllerProvider.notifier).markConversationAsRead(widget.conversationId);
    });
  }
  
  void _subscribeToRealtimeMessages() {
    debugPrint('🔄 [Vendeur] DEBUT _subscribeToRealtimeMessages pour conversation: ${widget.conversationId}');

    final realtimeService = ref.read(realtimeServiceProvider);
    debugPrint('🔄 [Vendeur] RealtimeService récupéré: $realtimeService');

    // IMPORTANT: Activer la subscription Supabase pour cette conversation
    realtimeService.subscribeToMessages(widget.conversationId);
    debugPrint('🔄 [Vendeur] Subscription Supabase activée');

    // S'abonner et écouter les messages en temps réel pour cette conversation
    debugPrint('🔄 [Vendeur] Création du stream listener...');
    _messageSubscription = realtimeService.getMessageStreamForConversation(widget.conversationId).listen(
      (message) {
        debugPrint('🎯 [Vendeur Realtime] Nouveau message reçu via stream !');
        debugPrint('   Message ID: ${message.id}');
        debugPrint('   Sender ID: ${message.senderId}');
        debugPrint('   Content: ${message.content}');

        // Vérifier que c'est bien pour notre conversation
        if (message.conversationId == widget.conversationId) {
          // Les notifications sont gérées par le service global
          // Pas besoin de notification locale ici
          ref.read(conversationsControllerProvider.notifier).handleIncomingMessage(message);

          // Auto-scroll vers le bas
          _scrollToBottom();
        }
      },
      onError: (error) {
        debugPrint('❌ [Vendeur Realtime] Erreur stream: $error');
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }


  @override
  void deactivate() {
    // Informer le service global qu'aucune conversation n'est active
    GlobalMessageNotificationService().setActiveConversation(null);

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

    // Auto-scroll vers le bas quand de nouveaux messages arrivent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Les notifications sont gérées par le service global
      // Pas besoin de notification locale ici

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
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: _buildInstagramAppBarTitle(conversation),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Utiliser GoRouter au lieu de Navigator.pop pour compatibilité notifications
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/seller/messages');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () => _makePhoneCall(conversation),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            onPressed: () => _makeVideoCall(conversation),
          ),
          ContextMenu(
            items: const [
              ContextMenuItem(
                value: 'close',
                label: 'Fermer la conversation',
                icon: Icons.close,
              ),
              ContextMenuItem(
                value: 'delete',
                label: 'Supprimer',
                icon: Icons.delete_outline,
                isDestructive: true,
                showDividerBefore: true,
              ),
            ],
            onSelected: (value) => _handleMenuAction(value),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: _buildMessagesArea(messages, isLoadingMessages, error, conversation),
          ),
          // Zone de saisie
          ChatInputWidget(
            controller: _messageController,
            onSend: (content) => _sendMessage(),
            onCamera: _takePhoto,
            onGallery: _pickFromGallery,
            onOffer: null, // ✅ CORRECTION: Système d'offres supprimé
            isLoading: isSendingMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(List<Message> messages, bool isLoading, String? error, dynamic conversation) {

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
            currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
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

  void _showCloseDialog() async {
    final result = await context.showConfirmationDialog(
      title: 'Fermer la conversation',
      message: 'Êtes-vous sûr de vouloir fermer cette conversation ? '
          'Le client ne pourra plus vous envoyer de messages.',
      confirmText: 'Fermer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(conversationsControllerProvider.notifier)
          .closeConversation(widget.conversationId);
      if (mounted) {
        Navigator.of(context).pop(); // Retour à la liste
        notificationService.info(context, 'Conversation fermée');
      }
    }
  }

  void _showDeleteDialog() async {
    final result = await context.showIOSDialog(
      title: 'Supprimer la conversation',
      message: 'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action ne peut pas être annulée.',
      type: DialogType.error,
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(conversationsControllerProvider.notifier)
          .deleteConversation(widget.conversationId);
      if (mounted) {
        Navigator.of(context).pop(); // Retour à la liste
        notificationService.error(context, 'Conversation supprimée');
      }
    }
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
            color: Colors.black.withValues(alpha: 0.1),
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

  Future<void> _makePhoneCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du particulier
    final phoneNumber = conversation?.userName; // userName contient le téléphone

    if (phoneNumber != null && phoneNumber.isNotEmpty) {

      // Nettoyer le numéro (enlever espaces, tirets, etc.)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanPhone);

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showErrorSnackBar('Impossible de lancer l\'appel téléphonique');
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors du lancement de l\'appel');
      }
    } else {
      _showErrorSnackBar('Numéro de téléphone non disponible');
    }
  }

  Future<void> _makeVideoCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du particulier
    final phoneNumber = conversation?.userName;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {

      // Pour l'appel vidéo, on peut essayer différentes applications
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Essayer WhatsApp d'abord (plus populaire pour la vidéo)
      final whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

      try {
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback vers l'application de téléphone par défaut
          final telUri = Uri(scheme: 'tel', path: cleanPhone);
          if (await canLaunchUrl(telUri)) {
            await launchUrl(telUri);
          } else {
            _showErrorSnackBar('Impossible de lancer l\'appel vidéo');
          }
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors du lancement de l\'appel vidéo');
      }
    } else {
      _showErrorSnackBar('Numéro de téléphone non disponible');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      notificationService.error(context, message);
    }
  }

  Future<void> _takePhoto() async {

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        await _sendImageMessage(File(photo.path));
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la prise de photo');
    }
  }

  Future<void> _pickFromGallery() async {

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _sendImageMessage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sélection d\'image');
    }
  }

  Future<void> _sendImageMessage(File imageFile) async {

    try {
      final conversationId = widget.conversationId;
      final userId = ref.read(currentUserProvider)?.id;

      if (userId == null) {
        _showErrorSnackBar('Utilisateur non connecté');
        return;
      }

      // Afficher un indicateur de chargement
      _showInfoSnackBar('Envoi de l\'image en cours...');

      // Upload de l'image vers Supabase Storage
      final imageService = ref.read(messageImageServiceProvider);
      final imageUrl = await imageService.uploadMessageImage(
        conversationId: conversationId,
        imageFile: imageFile,
      );


      // Envoyer le message via le provider
      await ref.read(conversationsControllerProvider.notifier).sendMessage(
        conversationId: conversationId,
        content: '', // Contenu vide pour les images
        messageType: MessageType.image,
        attachments: [imageUrl],
        metadata: {
          'imageUrl': imageUrl,
          'fileName': imageFile.path.split('/').last,
        },
      );

      _showSuccessSnackBar('Image envoyée !');

    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'envoi de l\'image');
    }
  }

  // ✅ CORRECTION: Système d'offres supprimé (inutile côté vendeur)

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      notificationService.success(context, message);
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      notificationService.info(context, message);
    }
  }
}