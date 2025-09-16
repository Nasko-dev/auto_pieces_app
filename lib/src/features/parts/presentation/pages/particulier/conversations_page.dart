import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/providers/particulier_conversations_providers.dart';
import '../../../../../shared/presentation/widgets/french_license_plate.dart';
import 'conversation_detail_page.dart';
import '../../../domain/entities/particulier_conversation.dart';

class MessagesPageColored extends ConsumerStatefulWidget {
  const MessagesPageColored({super.key});

  @override
  ConsumerState<MessagesPageColored> createState() => _MessagesPageColoredState();
}

class _MessagesPageColoredState extends ConsumerState<MessagesPageColored> {
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    // Charger les conversations au démarrage et initialiser le realtime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(particulierConversationsControllerProvider.notifier);
      controller.loadConversations();
      
      // Initialiser le realtime pour refresh automatique instantané
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        controller.initializeRealtime(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(particulierConversationsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5EA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        title: const Text(
          'Mes conversations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Bouton pour accéder au test des messages non lus
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test messages non lus',
            onPressed: () {
              context.push('/test-unread');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(conversationsState),
    );
  }

  Widget _buildBody(ParticulierConversationsState conversationsState) {
    if (conversationsState.isLoading && conversationsState.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
        ),
      );
    }
    
    if (conversationsState.error != null && conversationsState.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: ${conversationsState.error}'),
          ],
        ),
      );
    }
    
    return _buildConversationsList(conversationsState.conversations);
  }

  Widget _buildConversationsList(List<ParticulierConversation> conversations) {
    if (conversations.isEmpty) {
      return const Center(
        child: Text('Aucune conversation'),
      );
    }

    final groupedConversations = _groupConversationsByVehicle(conversations);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: groupedConversations.length,
      itemBuilder: (context, index) {
        final group = groupedConversations[index];
        final isExpanded = _expandedCategories.contains(group['key']);
        
        return _VehicleGroup(
          group: group,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(group['key']);
              } else {
                _expandedCategories.add(group['key']);
              }
            });
          },
          onConversationTap: (conversation) {
            // Navigation vers les détails
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupConversationsByVehicle(List<ParticulierConversation> conversations) {
    final Map<String, List<ParticulierConversation>> groups = {};
    
    for (final conversation in conversations) {
      // Utiliser vehiclePlate ou partType comme titre de groupe
      final title = conversation.vehiclePlate ?? 
                   conversation.partType ?? 
                   conversation.partNames?.join(', ') ?? 
                   'Véhicule non spécifié';
      if (!groups.containsKey(title)) {
        groups[title] = [];
      }
      groups[title]!.add(conversation);
    }

    return groups.entries.map((entry) {
      final conversations = entry.value;
      final totalUnread = conversations.fold<int>(
        0,
        (sum, conv) => sum + ((conv.unreadCount ?? 0) as int),
      );
      
      return {
        'key': entry.key,
        'title': entry.key,
        'conversations': conversations,
        'unreadCount': totalUnread,
      };
    }).toList();
  }
}

class _VehicleGroup extends StatelessWidget {
  final Map<String, dynamic> group;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(ParticulierConversation) onConversationTap;

  const _VehicleGroup({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    final conversations = group['conversations'] as List<ParticulierConversation>;
    final unreadCount = group['unreadCount'] as int;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header du groupe - exactement comme l'image WhatsApp
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    // Icône phare voiture exactement comme WhatsApp
                    const Icon(
                      Icons.car_repair,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    
                    // Titre du véhicule
                    Expanded(
                      child: Text(
                        group['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Badge avec nombre (exactement comme WhatsApp)
                    if (conversations.length > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${conversations.length}',
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Flèche exactement comme WhatsApp
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Liste des conversations - exactement comme WhatsApp
          if (isExpanded)
            ...conversations.asMap().entries.map((entry) {
              final index = entry.key;
              final conversation = entry.value;
              final isLast = index == conversations.length - 1;
              
              return _ConversationItem(
                conversation: conversation,
                isLast: isLast,
                onTap: () => onConversationTap(conversation),
              );
            }),
        ],
      ),
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final ParticulierConversation conversation;
  final bool isLast;
  final VoidCallback onTap;

  const _ConversationItem({
    required this.conversation,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast ? const Border(
              bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
            ) : null,
          ),
          child: Row(
            children: [
              // Avatar vendeur exactement comme WhatsApp
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store,
                  color: Color(0xFF8E8E93),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Contenu du message exactement comme WhatsApp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Nom du vendeur
                        Expanded(
                          child: Text(
                            conversation.sellerName ?? 'Vendeur',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                        
                        // Heure exactement comme WhatsApp
                        Text(
                          _formatTime(conversation.lastMessageAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    
                    // Aperçu du message avec statut
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.messages.isNotEmpty 
                              ? conversation.messages.last.content
                              : 'Demande d\'informations sur cet...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8E8E93),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Statut "Refuse" exactement comme WhatsApp
                        if (_hasRejectStatus())
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Refuse',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Flèche droite exactement comme WhatsApp
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '2h';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'maintenant';
    }
  }

  bool _hasRejectStatus() {
    // Simuler un statut "refusé" pour certaines conversations comme dans WhatsApp
    return conversation.id.hashCode % 4 == 0;
  }
}