import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';

class RequestsPage extends ConsumerStatefulWidget {
  const RequestsPage({super.key});

  @override
  ConsumerState<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends ConsumerState<RequestsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les demandes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(partRequestControllerProvider.notifier).loadUserPartRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          const AppHeader(title: 'Mes Demandes'),
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
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (filteredRequests.isEmpty) {
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ici vous trouverez vos recherches en cours. Pour le moment, aucune recherche n\'est en cours.',
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
            },
          ),
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final PartRequest request;

  const _RequestCard({
    required this.request,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Navigation vers les détails de la demande
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
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
                          request.vehicleInfo.isNotEmpty
                              ? request.vehicleInfo
                              : 'Véhicule non spécifié',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request.partNames.join(', '),
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
                        _getTimeAgo(request.createdAt),
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  _StatusBadge(status: request.status),
                  if (request.hasResponses)
                    _ResponseCountBadge(count: request.responseCount),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final result = await context.showDestructiveDialog(
      title: 'Supprimer la demande',
      message:
          'Êtes-vous sûr de vouloir supprimer cette demande ? Cette action est irréversible.',
      destructiveText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _deleteRequest(context, ref);
    }
  }

  void _deleteRequest(BuildContext context, WidgetRef ref) async {
    try {
      // Afficher l'indicateur de suppression
      notificationService.info(
        context,
        'Suppression en cours...',
        subtitle: 'Veuillez patienter',
      );

      // Appeler la fonction de suppression du controller
      final success = await ref
          .read(partRequestControllerProvider.notifier)
          .deletePartRequest(request.id);

      // Afficher le résultat
      if (context.mounted) {
        if (success) {
          notificationService.showPartRequestDeleted(context);
        } else {
          final state = ref.read(partRequestControllerProvider);
          final errorMessage = state.error ?? 'Erreur lors de la suppression';
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

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
