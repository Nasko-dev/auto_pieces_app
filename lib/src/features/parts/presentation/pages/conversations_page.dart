import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'conversation_detail_page.dart';
import '../../../../shared/presentation/widgets/app_menu.dart';

class MessagesPageColored extends StatefulWidget {
  const MessagesPageColored({super.key});
  @override
  State<MessagesPageColored> createState() => _MessagesPageColoredState();
}

class _MessagesPageColoredState extends State<MessagesPageColored> {
  
  // État d'ouverture/fermeture des sections (par modèle de voiture)
  final Map<String, bool> _expandedSections = {};

  final conversations = const [
    ('BMW Série 1', 'Garage Martin Auto', '97j', 'ferme'),
    ('BMW Série 1', 'Pièces Express', '105j', null),
    ('BMW Série 1', 'Auto Recyclage Pro', '2j', null),
    ('Volkswagen Golf', 'Auto Center Lyon', '169j', 'bloque'),
    ('Volkswagen Golf', 'Casse du Rhône', '5j', null),
    ('Mercedes Classe C', 'Recyclage Auto Pro', '2h', null),
    ('Peugeot 308', 'Casse Moderne', '1j', null),
  ];

  // Regrouper les conversations par modèle de voiture
  Map<String, List<(String, String, String, String?)>> get groupedConversations {
    final Map<String, List<(String, String, String, String?)>> grouped = {};
    
    for (final conversation in conversations) {
      final (carModel, company, time, state) = conversation;
      if (!grouped.containsKey(carModel)) {
        grouped[carModel] = [];
      }
      grouped[carModel]!.add((carModel, company, time, state));
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 24,
            color: AppTheme.primaryBlue,
            onPressed: () {},
            tooltip: 'Nouvelle conversation',
          ),
          const AppMenu(),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: groupedConversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final carModel = groupedConversations.keys.elementAt(i);
          final conversationsForModel = groupedConversations[carModel]!;
          final isExpanded = _expandedSections[carModel] ?? true; // Ouvert par défaut
          
          return _CarModelSection(
            carModel: carModel,
            conversations: conversationsForModel,
            isExpanded: isExpanded,
            onToggle: () {
              setState(() {
                _expandedSections[carModel] = !isExpanded;
              });
            },
          );
        },
      ),
    );
  }

}

class _CarModelSection extends StatelessWidget {
  final String carModel;
  final List<(String, String, String, String?)> conversations;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CarModelSection({
    required this.carModel,
    required this.conversations,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête cliquable
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icône voiture
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Modèle de voiture
                  Expanded(
                    child: Text(
                      carModel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                  ),
                  // Badge avec nombre de conversations
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${conversations.length}',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icône expand/collapse
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.gray,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Conversations (si ouvert)
          if (isExpanded) ...[
            const Divider(height: 1, color: AppTheme.lightGray),
            ...conversations.map((conversation) {
              final (_, company, time, state) = conversation;
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ConversationDetailPage(
                        companyName: company,
                        carModel: carModel,
                        state: state,
                      ),
                    ),
                  );
                },
                child: _ConversationCard(
                  title: company, // Le nom de l'entreprise devient le titre
                  lastMessage: 'Demande de pièces pour $carModel',
                  time: time,
                  state: state,
                  isInsideSection: true,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final String title; // Nom de l'entreprise quand isInsideSection=true
  final String lastMessage; // Description de la demande
  final String time; // ex : 97j
  final String? state; // 'ferme' | 'bloque' | null
  final bool isInsideSection; // Indique si c'est dans une section
  
  const _ConversationCard({
    required this.title,
    required this.lastMessage,
    required this.time,
    this.state,
    this.isInsideSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: isInsideSection ? Colors.transparent : AppTheme.white,
        borderRadius: BorderRadius.circular(isInsideSection ? 0 : 16),
        boxShadow: isInsideSection ? null : const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: isInsideSection ? 8 : 0,
      ),
      child: Row(
        children: [
          // Avatar avec icône appropriée
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isInsideSection 
                ? AppTheme.gray.withValues(alpha: .1)
                : AppTheme.primaryBlue.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isInsideSection ? Icons.business : Icons.directions_car,
              color: isInsideSection ? AppTheme.gray : AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppTheme.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (state != null) ...[
                      const SizedBox(width: 8),
                      _StateBadge(state: state!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Flèche de navigation
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: AppTheme.gray.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String state; // 'ferme' | 'bloque'
  const _StateBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final isClosed = state.toLowerCase().startsWith('f'); // Fermé
    final bg = isClosed ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1);
    final fg = isClosed ? AppTheme.success : AppTheme.error;
    final icon = isClosed ? Icons.lock_outline : Icons.block;
    final label = isClosed ? 'Fermé' : 'Bloqué';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: fg,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

