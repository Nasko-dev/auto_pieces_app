import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cente_pice/src/features/parts/domain/entities/message.dart';
import 'package:cente_pice/src/features/parts/domain/entities/conversation_enums.dart';
import '../../providers/conversations_providers.dart' hide realtimeServiceProvider;
import '../../../../../shared/presentation/widgets/loading_widget.dart';
import '../../widgets/message_bubble_widget.dart';
import '../../widgets/chat_input_widget.dart';
import '../../../../../core/providers/particulier_conversations_providers.dart';
import '../../../../../core/providers/message_image_providers.dart';
import '../../../../../core/providers/session_providers.dart';
import '../../../../../core/services/global_message_notification_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/utils/haptic_helper.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';
import '../../../../../core/theme/app_theme.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription? _messageSubscription;
  int _previousMessageCount = 0;

  // Cache local pour les données vendeur
  Map<String, dynamic>? _sellerInfo;
  bool _isLoadingSellerInfo = false;

  @override
  void initState() {
    super.initState();

    // Informer le service global que cette conversation est active
    GlobalMessageNotificationService().setActiveConversation(widget.conversationId);

    // Charger les messages au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsControllerProvider.notifier)
          .loadConversationMessages(widget.conversationId);

      // ✅ SIMPLE: Marquer la conversation comme lue (remettre compteur local à 0)
      Future.microtask(() {
        ref.read(particulierConversationsControllerProvider.notifier)
            .markConversationAsRead(widget.conversationId);
      });

      // S'abonner aux messages en temps réel via RealtimeService
      _subscribeToRealtimeMessages();

      // Charger les infos vendeur
      _loadSellerInfo();
    });
  }

  void _subscribeToRealtimeMessages() {
    debugPrint('🔔 [Particulier Realtime] Abonnement aux messages de conversation ${widget.conversationId}');

    final realtimeService = ref.read(realtimeServiceProvider);

    // S'abonner aux messages de cette conversation spécifique
    realtimeService.subscribeToMessages(widget.conversationId);

    // Écouter les nouveaux messages via le stream spécifique à cette conversation
    _messageSubscription = realtimeService.getMessageStreamForConversation(widget.conversationId).listen(
      (message) {
        debugPrint('🎯 [Particulier Realtime] Nouveau message reçu via stream !');
        debugPrint('   Message ID: ${message.id}');
        debugPrint('   Sender ID: ${message.senderId}');
        debugPrint('   Content: ${message.content}');

        // Vérifier que c'est bien pour notre conversation
        if (message.conversationId == widget.conversationId) {
          // Les notifications sont gérées par le service global
          // Pas besoin de notification locale ici

          // Envoyer au controller via la méthode unifiée
          ref.read(conversationsControllerProvider.notifier)
              .handleIncomingMessage(message);
        }
      },
      onError: (error) {
        debugPrint('❌ [Particulier Realtime] Erreur stream: $error');
      },
      onDone: () {
        debugPrint('✅ [Particulier Realtime] Stream terminé');
      },
    );
  }
  Future<void> _loadSellerInfo() async {
    if (_isLoadingSellerInfo) return;

    setState(() {
      _isLoadingSellerInfo = true;
    });

    try {
      // Charger la conversation directement pour obtenir le sellerId
      final convResponse = await Supabase.instance.client
          .from('conversations')
          .select('seller_id')
          .eq('id', widget.conversationId)
          .maybeSingle();

      if (convResponse == null || convResponse['seller_id'] == null) {
        if (mounted) {
          setState(() {
            _isLoadingSellerInfo = false;
          });
        }
        return;
      }

      final sellerId = convResponse['seller_id'] as String;

      final response = await Supabase.instance.client
          .from('sellers')
          .select('id, first_name, last_name, company_name, phone, avatar_url')
          .eq('id', sellerId)
          .limit(1);

      if (response.isNotEmpty && mounted) {
        setState(() {
          _sellerInfo = response.first;
          _isLoadingSellerInfo = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement info vendeur: $e');
      if (mounted) {
        setState(() {
          _isLoadingSellerInfo = false;
        });
      }
    }
  }

  @override
  void deactivate() {
    // Informer le service global qu'aucune conversation n'est active
    GlobalMessageNotificationService().setActiveConversation(null);

    // ✅ SIMPLE: Désactiver la conversation quand on quitte (avant dispose)
    ref.read(particulierConversationsControllerProvider.notifier)
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

    // Auto-scroll quand de nouveaux messages arrivent
    if (messages.length > _previousMessageCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
      _previousMessageCount = messages.length;
    }

    // Trouver la conversation pour le titre - gestion sécurisée
    final conversationsState = ref.watch(particulierConversationsControllerProvider);
    final conversation = conversationsState.conversations.where((c) => c.id == widget.conversationId).firstOrNull;


    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.darkGray,
        elevation: 0,
        title: _buildInstagramAppBarTitle(conversation),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.darkGray),
          onPressed: () {
            HapticHelper.light();
            // Utiliser GoRouter au lieu de Navigator.pop pour compatibilité notifications
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/conversations');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppTheme.darkGray),
            onPressed: () => _makePhoneCall(conversation),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppTheme.darkGray),
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
                value: 'block',
                label: 'Bloquer le vendeur',
                icon: Icons.block,
              ),
              ContextMenuItem(
                value: 'delete',
                label: 'Supprimer',
                icon: Icons.delete_outline,
                isDestructive: true,
                showDividerBefore: true,
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'close':
                  _showCloseDialog();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
                case 'block':
                  _showBlockDialog();
                  break;
              }
            },
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
            onSend: (content) => _sendMessage(content),
            onCamera: _takePhoto,
            onGallery: _pickFromGallery,
            onOffer: null, // Pas d'offres pour les particuliers
            isLoading: isSendingMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesArea(List<Message> messages, bool isLoading, String? error, dynamic conversation) {
    Widget content;

    if (isLoading && messages.isEmpty) {
      content = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            SizedBox(height: 16),
            Text('Chargement des messages...'),
          ],
        ),
      );
    } else if (error != null && messages.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
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
    } else if (messages.isEmpty) {
      content = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.gray,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez la conversation en envoyant un message.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.gray),
            ),
          ],
        ),
      );
    } else {
      content = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastMessage = index == messages.length - 1;
        final showDateSeparator = _shouldShowDateSeparator(messages, index);

        return Column(
          children: [
            if (showDateSeparator) ...[
              _buildDateSeparator(message.createdAt),
              const SizedBox(height: 16),
            ],
            MessageBubbleWidget(
              message: message,
              currentUserType: MessageSenderType.user, // Côté particulier
              currentUserId: Supabase.instance.client.auth.currentUser?.id ?? '',
              isLastMessage: isLastMessage,
              otherUserName: _getSellerDisplayName(conversation),
              otherUserAvatarUrl: _sellerInfo?['avatar_url'],
              otherUserCompany: _sellerInfo?['company_name'],
            ),
            const SizedBox(height: 12), // Plus d'espace entre messages
          ],
        );
      },
    );
    }

    // Envelopper le contenu dans un Stack avec le logo en arrière-plan
    return Stack(
      children: [
        // Logo en arrière-plan au centre
        Center(
          child: Image.asset(
            'assets/Backgrund-message.png',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        // Contenu par-dessus
        content,
      ],
    );
  }

  bool _shouldShowDateSeparator(List<Message> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.createdAt.year,
      currentMessage.createdAt.month,
      currentMessage.createdAt.day,
    );

    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );

    return !currentDate.isAtSameMomentAs(previousDate);
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Aujourd\'hui';
    } else if (messageDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      dateText = 'Hier';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        dateText,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.gray,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;


    ref.read(conversationsControllerProvider.notifier).sendMessage(
      conversationId: widget.conversationId,
      content: content.trim(),
    );

    _messageController.clear();
  }

  void _showCloseDialog() async {
    final result = await context.showConfirmationDialog(
      title: 'Fermer la conversation',
      message: 'Voulez-vous fermer cette conversation ? Vous pourrez toujours la rouvrir plus tard.',
      confirmText: 'Fermer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(conversationsControllerProvider.notifier)
          .closeConversation(widget.conversationId);

      if (mounted) {
        notificationService.showConversationClosed(context);
      }
    }
  }

  void _showDeleteDialog() async {
    final result = await context.showDestructiveDialog(
      title: 'Supprimer la conversation',
      message: 'Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action ne peut pas être annulée.',
      destructiveText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(conversationsControllerProvider.notifier)
          .deleteConversation(widget.conversationId);

      if (mounted) {
        // Utiliser GoRouter pour compatibilité notifications
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/conversations');
        }
        notificationService.showConversationDeleted(context);
      }
    }
  }

  void _showBlockDialog() async {
    final result = await context.showWarningDialog(
      title: 'Bloquer le vendeur',
      message: 'Êtes-vous sûr de vouloir bloquer ce vendeur ? Vous ne recevrez plus de messages de sa part.',
      confirmText: 'Bloquer',
      cancelText: 'Annuler',
    );

    if (result == true && mounted) {
      ref.read(conversationsControllerProvider.notifier)
          .blockConversation(widget.conversationId);

      if (mounted) {
        // Utiliser GoRouter pour compatibilité notifications
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/conversations');
        }
        notificationService.showSellerBlocked(context);
      }
    }
  }

  Widget _buildInstagramAppBarTitle(dynamic conversation) {
    return Row(
      children: [
        // Avatar du vendeur
        _buildSellerAvatar(conversation),

        const SizedBox(width: 12),

        // Informations style Instagram
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'En ligne',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getSellerDisplayName(conversation),
                style: const TextStyle(
                  color: AppTheme.gray,
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

  Widget _buildSellerAvatar(dynamic conversation) {
    final avatarUrl = _sellerInfo?['avatar_url'] ?? conversation?.sellerAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      // Avatar style Instagram avec vraie photo
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightGray,
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF405DE6), Color(0xFF5851DB)], // Gradient Instagram bleu
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.business,
        color: AppTheme.white,
        size: 16,
      ),
    );
  }

  String _getSellerDisplayName(dynamic conversation) {
    // Priorité : données chargées directement > données de conversation
    final companyName = _sellerInfo?['company_name'];
    final firstName = _sellerInfo?['first_name'];
    final lastName = _sellerInfo?['last_name'];

    if (companyName != null && companyName.isNotEmpty) {
      return companyName;
    } else if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    } else if (conversation?.sellerName != null && conversation!.sellerName!.isNotEmpty) {
      return conversation!.sellerName!;
    } else {
      return 'Vendeur Professionnel';
    }
  }

  Future<void> _makePhoneCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du vendeur
    final phoneNumber = _sellerInfo?['phone'] ?? conversation?.sellerPhone;

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
      _showInfoSnackBar('Numéro de téléphone du vendeur non disponible');
    }
  }

  Future<void> _makeVideoCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du vendeur
    final phoneNumber = _sellerInfo?['phone'] ?? conversation?.sellerPhone;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {

      // Pour l'appel vidéo, essayer WhatsApp d'abord
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

      try {
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback vers l'application de téléphone
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
      _showInfoSnackBar('Numéro de téléphone du vendeur non disponible');
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

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      notificationService.success(context, message);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      notificationService.error(context, message);
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      notificationService.info(context, message);
    }
  }
}
