import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../../../../core/providers/seller_dashboard_providers.dart';
import '../../../../../core/providers/reject_part_request_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/part_request.dart';
import '../../../domain/usecases/reject_part_request.dart';
import '../../controllers/seller_dashboard_controller.dart';
import 'conversation_detail_page.dart';

class HomeSellerPage extends ConsumerStatefulWidget {
  const HomeSellerPage({super.key});

  @override
  ConsumerState<HomeSellerPage> createState() => _HomeSellerPageState();
}

class _HomeSellerPageState extends ConsumerState<HomeSellerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerDashboardControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(sellerDashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mes Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: SellerMenu()),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              const Text(
                'Dashboard Vendeur',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 6),
              _buildWelcomeText(dashboardState),
              const SizedBox(height: 20),

              // Contenu basé sur l'état
              _buildDashboardContent(dashboardState),

              const SizedBox(height: 16),

              // Bouton "Voir plus"
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Navigation vers toutes les notifications
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: AppTheme.primaryBlue,
                    size: 18,
                  ),
                  label: const Text(
                    'Voir plus de notifications',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Ligne de séparation
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.gray.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Texte d'aide
              const Center(
                child: Text(
                  'Vous pouvez aussi déposer une annonce\nà partir d\'ici',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CTA Déposer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.go('/seller/add');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Déposer une annonce',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(SellerDashboardState dashboardState) {
    return dashboardState.when(
      initial:
          () => const Text(
            'Bienvenue dans votre espace vendeur',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
      loading:
          () => const Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
      loaded:
          (notifications, unreadCount) => Text(
            unreadCount > 0
                ? 'Vous avez $unreadCount nouvelle${unreadCount > 1 ? 's' : ''} demande${unreadCount > 1 ? 's' : ''}'
                : 'Tout est à jour ! Aucune nouvelle demande.',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
      error:
          (message) => const Text(
            'Bienvenue dans votre espace vendeur',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  Widget _buildDashboardContent(SellerDashboardState dashboardState) {
    return _buildNotificationsContent(dashboardState);
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            title: 'Ventes',
            value: '12',
            subtitle: 'Ce mois',
            icon: Icons.trending_up,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            title: 'Revenus',
            value: '2,450€',
            subtitle: 'Total',
            icon: Icons.euro,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatsCard(
            title: 'Messages',
            value: '8',
            subtitle: 'Non lus',
            icon: Icons.chat_bubble_outline,
            color: AppTheme.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Nouvelle annonce',
                subtitle: 'Déposer une pièce',
                icon: Icons.add_circle_outline,
                color: AppTheme.primaryBlue,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  context.go('/seller/add');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Mes annonces',
                subtitle: 'Gérer le stock',
                icon: Icons.inventory_2_outlined,
                color: AppTheme.success,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/seller/inventory');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Messages',
                subtitle: 'Répondre aux clients',
                icon: Icons.chat_outlined,
                color: AppTheme.warning,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/seller/messages');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Statistiques',
                subtitle: 'Voir les performances',
                icon: Icons.analytics_outlined,
                color: AppTheme.darkBlue,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/seller/stats');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsContent(SellerDashboardState state) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          ),
      loaded: (notifications, unreadCount) {
        if (notifications.isEmpty) {
          return _buildEmptyNotificationsState();
        }

        return Column(
          children: [
            // Afficher les 3 premières notifications avec le nouveau design
            ...notifications.take(3).map((notification) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModernNotificationCard(
                  partRequest: notification.partRequest,
                  onTap:
                      () => _navigateToConversationDetail(
                        notification.partRequest,
                      ),
                  onAccept:
                      () =>
                          _acceptAndRespond(context, notification.partRequest),
                  onReject:
                      () => _rejectRequest(context, notification.partRequest),
                ),
              );
            }).toList(),

            if (notifications.length > 3) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/seller/messages');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.visibility_outlined,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voir toutes les demandes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                              Text(
                                '${notifications.length - 3} autres demandes disponibles',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.gray,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
      error: (message) => _buildErrorNotificationsState(message),
    );
  }

  Widget _buildEmptyNotificationsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune nouvelle demande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les demandes de pièces de vos clients apparaîtront ici',
            style: TextStyle(fontSize: 14, color: AppTheme.gray, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorNotificationsState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(sellerDashboardControllerProvider.notifier).refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToConversationDetail(PartRequest partRequest) {
    HapticFeedback.lightImpact();
    // TODO: Implémenter navigation vers conversation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction conversation en cours de développement')),
    );
  }

  void _acceptAndRespond(BuildContext context, PartRequest partRequest) {
    // TODO: Créer une conversation et y amener le vendeur pour répondre
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction répondre en cours de développement')),
    );
    // Rafraîchir les notifications
    ref.read(sellerDashboardControllerProvider.notifier).refresh();
  }

  void _rejectRequest(BuildContext context, PartRequest partRequest) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Refuser la demande'),
            content: const Text(
              'Êtes-vous sûr de vouloir refuser cette demande ?\n'
              'Cette action ne peut pas être annulée.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _performReject(partRequest);
                },
                child: const Text('Refuser'),
              ),
            ],
          ),
    );
  }

  void _performReject(PartRequest partRequest) async {
    try {
      // Récupérer le seller ID de l'utilisateur connecté
      // Pour l'instant, on utilise un ID temporaire - il faudra récupérer le vrai ID
      const sellerId = 'current-seller-id'; // TODO: Récupérer depuis l'auth

      final rejectUseCase = ref.read(rejectPartRequestUseCaseProvider);
      final params = RejectPartRequestParams(
        sellerId: sellerId,
        partRequestId: partRequest.id,
        reason: 'Refusé par le vendeur',
      );

      final result = await rejectUseCase(params);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${failure.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        },
        (rejection) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Demande "${partRequest.partType}" refusée avec succès',
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du refus: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }

    // Rafraîchir les notifications pour refléter les changements
    ref.read(sellerDashboardControllerProvider.notifier).refresh();
  }
}

// Nouveaux composants modernes

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppTheme.gray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernNotificationCard extends StatelessWidget {
  final PartRequest partRequest;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ModernNotificationCard({
    required this.partRequest,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${partRequest.vehicleBrand} ${partRequest.vehicleModel}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          partRequest.partNames.join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Nouveau',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Refuser',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Répondre',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
