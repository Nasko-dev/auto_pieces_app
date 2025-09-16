import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
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
            child: _buildMessagesArea(messages, isLoadingMessages, error, conversation),
          ),
          // Zone de saisie
          ChatInputWidget(
            controller: _messageController,
            onSend: (content) => _sendMessage(),
            onCamera: _takePhoto,
            onGallery: _pickFromGallery,
            onOffer: _createOffer,
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

  Future<void> _makePhoneCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du particulier
    final phoneNumber = conversation?.userName; // userName contient le téléphone

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      print('📞 [UI] Tentative d\'appel vers: $phoneNumber');

      // Nettoyer le numéro (enlever espaces, tirets, etc.)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanPhone);

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          print('✅ [UI] Appel lancé avec succès');
        } else {
          print('⚠️ [UI] Impossible de lancer l\'appel');
          _showErrorSnackBar('Impossible de lancer l\'appel téléphonique');
        }
      } catch (e) {
        print('❌ [UI] Erreur lors du lancement de l\'appel: $e');
        _showErrorSnackBar('Erreur lors du lancement de l\'appel');
      }
    } else {
      print('⚠️ [UI] Numéro de téléphone non disponible');
      _showErrorSnackBar('Numéro de téléphone non disponible');
    }
  }

  Future<void> _makeVideoCall(dynamic conversation) async {
    // Récupérer le numéro de téléphone du particulier
    final phoneNumber = conversation?.userName;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      print('📹 [UI] Tentative d\'appel vidéo vers: $phoneNumber');

      // Pour l'appel vidéo, on peut essayer différentes applications
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Essayer WhatsApp d'abord (plus populaire pour la vidéo)
      final whatsappUri = Uri.parse('https://wa.me/$cleanPhone');

      try {
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          print('✅ [UI] WhatsApp ouvert avec succès');
        } else {
          // Fallback vers l'application de téléphone par défaut
          final telUri = Uri(scheme: 'tel', path: cleanPhone);
          if (await canLaunchUrl(telUri)) {
            await launchUrl(telUri);
            print('✅ [UI] Application téléphone lancée');
          } else {
            _showErrorSnackBar('Impossible de lancer l\'appel vidéo');
          }
        }
      } catch (e) {
        print('❌ [UI] Erreur lors du lancement de l\'appel vidéo: $e');
        _showErrorSnackBar('Erreur lors du lancement de l\'appel vidéo');
      }
    } else {
      _showErrorSnackBar('Numéro de téléphone non disponible');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    print('📷 [UI-Vendeur] Prise de photo');

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        print('✅ [UI-Vendeur] Photo prise: ${photo.path}');
        // TODO: Envoyer la photo en tant que message
        _showSuccessSnackBar('Photo prise ! Envoi des images bientôt disponible.');
      }
    } catch (e) {
      print('❌ [UI-Vendeur] Erreur prise photo: $e');
      _showErrorSnackBar('Erreur lors de la prise de photo');
    }
  }

  Future<void> _pickFromGallery() async {
    print('🖼️ [UI-Vendeur] Sélection galerie');

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ [UI-Vendeur] Image sélectionnée: ${image.path}');
        // TODO: Envoyer l'image en tant que message
        _showSuccessSnackBar('Image sélectionnée ! Envoi des images bientôt disponible.');
      }
    } catch (e) {
      print('❌ [UI-Vendeur] Erreur galerie: $e');
      _showErrorSnackBar('Erreur lors de la sélection d\'image');
    }
  }

  Future<void> _createOffer() async {
    print('💰 [UI-Vendeur] Création offre');

    // Afficher une dialog pour créer l'offre
    final offer = await _showOfferDialog();

    if (offer != null) {
      print('✅ [UI-Vendeur] Offre créée: $offer');
      // TODO: Envoyer l'offre en tant que message spécial
      _showSuccessSnackBar('Offre créée ! Envoi d\'offres bientôt disponible.');
    }
  }

  Future<Map<String, dynamic>?> _showOfferDialog() async {
    final priceController = TextEditingController();
    final availabilityController = TextEditingController();
    final deliveryController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Faire une offre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix (€)',
                hintText: 'Ex: 150.00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: availabilityController,
              decoration: const InputDecoration(
                labelText: 'Disponibilité',
                hintText: 'Ex: En stock, Sur commande...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deliveryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Délai de livraison (jours)',
                hintText: 'Ex: 2',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              final availability = availabilityController.text.trim();
              final delivery = int.tryParse(deliveryController.text);

              if (price != null && price > 0) {
                Navigator.of(context).pop({
                  'price': price,
                  'availability': availability.isNotEmpty ? availability : null,
                  'delivery_days': delivery,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un prix valide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Créer l\'offre'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}