import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../controllers/part_request_controller.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../../domain/entities/part_request.dart';
import '../../../domain/entities/part_advertisement.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';

// Classe wrapper pour unifier requests et advertisements
class UnifiedItem {
  final String id;
  final String type; // 'request' ou 'advertisement'
  final String vehicleInfo;
  final String partInfo;
  final DateTime createdAt;
  final String status;
  final int? responseCount;
  final PartRequest? request;
  final PartAdvertisement? advertisement;

  UnifiedItem({
    required this.id,
    required this.type,
    required this.vehicleInfo,
    required this.partInfo,
    required this.createdAt,
    required this.status,
    this.responseCount,
    this.request,
    this.advertisement,
  });

  factory UnifiedItem.fromRequest(PartRequest request) {
    return UnifiedItem(
      id: request.id,
      type: 'request',
      vehicleInfo: request.vehicleInfo,
      partInfo: request.partNames.join(', '),
      createdAt: request.createdAt,
      status: request.status,
      responseCount: request.responseCount,
      request: request,
    );
  }

  factory UnifiedItem.fromAdvertisement(PartAdvertisement ad) {
    final vehicleParts = <String>[];
    if (ad.vehicleBrand != null) vehicleParts.add(ad.vehicleBrand!);
    if (ad.vehicleModel != null) vehicleParts.add(ad.vehicleModel!);
    if (ad.vehicleYear != null) vehicleParts.add(ad.vehicleYear.toString());
    if (ad.vehicleEngine != null) vehicleParts.add(ad.vehicleEngine!);

    return UnifiedItem(
      id: ad.id,
      type: 'advertisement',
      vehicleInfo: vehicleParts.isNotEmpty
          ? vehicleParts.join(' - ')
          : 'Véhicule non spécifié',
      partInfo: ad.partName,
      createdAt: ad.createdAt,
      status: ad.status,
      advertisement: ad,
    );
  }
}

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _reloadAdvertisements();
      }
    });
  }

  void _reloadAdvertisements() {
    // Le datasource récupère automatiquement l'ID stable via device_id
    ref.read(partRequestControllerProvider.notifier).loadUserPartRequests();
    ref
        .read(partAdvertisementControllerProvider.notifier)
        .getMyAdvertisements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          const AppHeader(title: 'Mes Recherches'),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(partRequestControllerProvider);

        // Filtrer pour ne montrer que les demandes particulier (non-vendeur)
        final filteredRequests = state.requests
            .where((request) => !request.isSellerRequest)
            .toList();

        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.error != null) {
        final requestState = ref.watch(partRequestControllerProvider);
        final adState = ref.watch(partAdvertisementControllerProvider);

        // Filtrer pour ne montrer que les demandes particulier (non-vendeur)
        final filteredRequests = requestState.requests
            .where((request) => !request.isSellerRequest)
            .map((r) => UnifiedItem.fromRequest(r))
            .toList();

        // Convertir les annonces en UnifiedItem
        final advertisements = adState.advertisements
            .map((ad) => UnifiedItem.fromAdvertisement(ad))
            .toList();

        // Fusionner et trier par date
        final allItems = [...filteredRequests, ...advertisements];
        allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (requestState.isLoading || adState.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (requestState.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  requestState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(partRequestControllerProvider.notifier)
                        .loadUserPartRequests();
                  },
                  onPressed: _reloadAdvertisements,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (filteredRequests.isEmpty) {
        if (allItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune recherches',
                  'Aucune recherche',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ici vous trouverez vos recherches en cours. Pour le moment, aucune recherche n\'est en cours.',
                  'Ici vous trouverez vos recherches et annonces en cours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.add),
                  label: const Text('Lancer une recherche'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(partRequestControllerProvider.notifier)
                .loadUserPartRequests();
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: filteredRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
              return _RequestCard(request: request);
            _reloadAdvertisements();
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: allItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = allItems[index];
              return _UnifiedItemCard(item: item);
            },
          ),
        );
      },
    );
  }
}

class _UnifiedItemCard extends ConsumerWidget {
  final UnifiedItem item;

  const _UnifiedItemCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdvertisement = item.type == 'advertisement';

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
      child: InkWell(
        onTap: () {
          // Navigation vers les détails
        },
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
                      color: isAdvertisement
                          ? AppTheme.success.withValues(alpha: 0.1)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isAdvertisement ? Icons.sell : Icons.search,
                      color: isAdvertisement
                          ? AppTheme.success
                          : AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.vehicleInfo.isNotEmpty
                              ? request.vehicleInfo
                          item.vehicleInfo.isNotEmpty
                              ? item.vehicleInfo
                              : 'Véhicule non spécifié',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.partInfo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _getTimeAgo(item.createdAt),
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Menu différent selon le type
                      if (isAdvertisement)
                        EditDeleteContextMenu(
                          onEdit: () => _showEditDialog(context, ref),
                          onDelete: () => _showDeleteDialog(context, ref),
                        )
                      else
                        DeleteContextMenu(
                          onDelete: () => _showDeleteDialog(context, ref),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _TypeBadge(isAdvertisement: isAdvertisement),
                      const SizedBox(width: 8),
                      _StatusBadge(
                          status: item.status,
                          isAdvertisement: isAdvertisement),
                    ],
                  ),
                  if (item.responseCount != null && item.responseCount! > 0)
                    _ResponseCountBadge(count: item.responseCount!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${(difference.inDays / 7).floor()}sem';
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // TODO: Navigation vers la page de modification de l'annonce
    // Pour l'instant, afficher un message
    notificationService.info(
      context,
      'Modification',
      subtitle: 'La page de modification sera bientôt disponible',
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final isAdvertisement = item.type == 'advertisement';
    final result = await context.showDestructiveDialog(
      title: 'Supprimer la demande',
      message:
          'Êtes-vous sûr de vouloir supprimer cette demande ? Cette action est irréversible.',
      title: isAdvertisement ? 'Supprimer l\'annonce' : 'Supprimer la demande',
      message:
          'Êtes-vous sûr de vouloir supprimer ${isAdvertisement ? 'cette annonce' : 'cette demande'} ? Cette action est irréversible.',
      destructiveText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _deleteItem(context, ref);
    }
  }

  void _deleteItem(BuildContext context, WidgetRef ref) async {
    final isAdvertisement = item.type == 'advertisement';

    try {
      // Afficher l'indicateur de suppression
      notificationService.info(
        context,
        'Suppression en cours...',
        subtitle: 'Veuillez patienter',
      );

      bool success;
      if (isAdvertisement) {
        success = await ref
            .read(partAdvertisementControllerProvider.notifier)
            .deleteAdvertisement(item.id);
      } else {
        success = await ref
            .read(partRequestControllerProvider.notifier)
            .deletePartRequest(item.id);
      }

      // Afficher le résultat
      if (context.mounted) {
        if (success) {
          notificationService.success(
            context,
            'Suppression réussie',
            subtitle: isAdvertisement
                ? 'L\'annonce a été supprimée'
                : 'La demande a été supprimée',
          );
        } else {
          String errorMessage = 'Erreur lors de la suppression';
          if (isAdvertisement) {
            final adState = ref.read(partAdvertisementControllerProvider);
            errorMessage = adState.error ?? errorMessage;
          } else {
            final reqState = ref.read(partRequestControllerProvider);
            errorMessage = reqState.error ?? errorMessage;
          }
          notificationService.error(
            context,
            'Échec de la suppression',
            subtitle: errorMessage,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        notificationService.error(
          context,
          'Erreur inattendue',
          subtitle: e.toString(),
        );
      }
    }
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isAdvertisement});

  final bool isAdvertisement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdvertisement
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdvertisement ? Icons.sell_outlined : Icons.search,
            color: isAdvertisement ? AppTheme.success : AppTheme.primaryBlue,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isAdvertisement ? 'Annonce' : 'Recherche',
            style: TextStyle(
              color: isAdvertisement ? AppTheme.success : AppTheme.primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isAdvertisement});

  final String status;
  final bool isAdvertisement;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    if (isAdvertisement) {
      // Statuts pour les annonces
      switch (status) {
        case 'active':
          backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
          textColor = AppTheme.warning;
          icon = Icons.visibility;
          label = 'Active';
          break;
        case 'sold':
          backgroundColor = AppTheme.gray.withValues(alpha: 0.1);
          textColor = AppTheme.gray;
          icon = Icons.check_circle_outline;
          label = 'Vendue';
          break;
        case 'inactive':
          backgroundColor = AppTheme.gray.withValues(alpha: 0.1);
          textColor = AppTheme.gray;
          icon = Icons.cancel_outlined;
          label = 'Inactive';
          break;
        default:
          backgroundColor = AppTheme.gray.withValues(alpha: 0.1);
          textColor = AppTheme.gray;
          icon = Icons.help_outline;
          label = 'Inconnu';
      }
    } else {
      // Statuts pour les demandes
      switch (status) {
        case 'active':
          backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
          textColor = AppTheme.warning;
          icon = Icons.schedule;
          label = 'Active';
          break;
        case 'fulfilled':
          backgroundColor = AppTheme.success.withValues(alpha: 0.1);
          textColor = AppTheme.success;
          icon = Icons.check_circle_outline;
          label = 'Terminé';
          break;
        case 'closed':
          backgroundColor = AppTheme.gray.withValues(alpha: 0.1);
          textColor = AppTheme.gray;
          icon = Icons.cancel_outlined;
          label = 'Fermé';
          break;
        default:
          backgroundColor = AppTheme.gray.withValues(alpha: 0.1);
          textColor = AppTheme.gray;
          icon = Icons.help_outline;
          label = 'Inconnu';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCountBadge extends StatelessWidget {
  final int count;

  const _ResponseCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: AppTheme.success,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$count réponse${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppTheme.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
