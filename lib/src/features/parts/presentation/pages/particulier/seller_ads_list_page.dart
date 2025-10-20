import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../../domain/entities/part_advertisement.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/ios_dialog.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';

class SellerAdsListPage extends ConsumerStatefulWidget {
  const SellerAdsListPage({super.key});

  @override
  ConsumerState<SellerAdsListPage> createState() => _SellerAdsListPageState();
}

class _SellerAdsListPageState extends ConsumerState<SellerAdsListPage> {
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
          const AppHeader(title: 'Mes Annonces'),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final adState = ref.watch(partAdvertisementControllerProvider);

        if (adState.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (adState.error != null) {
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
                  adState.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _reloadAdvertisements,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (adState.advertisements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune annonce',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Publiez votre première annonce pour vendre vos pièces.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/create-advertisement'),
                  icon: const Icon(Icons.add),
                  label: const Text('Publier une annonce'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _reloadAdvertisements();
          },
          child: Column(
            children: [
              // Bouton pour créer une nouvelle annonce
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.white,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/create-advertisement'),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Publier une nouvelle annonce'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: adState.advertisements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final advertisement = adState.advertisements[index];
                    return _AdvertisementCard(advertisement: advertisement);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdvertisementCard extends ConsumerWidget {
  final PartAdvertisement advertisement;

  const _AdvertisementCard({
    required this.advertisement,
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
          // Navigation vers les détails (à implémenter si nécessaire)
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
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sell,
                      color: AppTheme.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advertisement.partName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _buildVehicleInfo(advertisement),
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
                        _getTimeAgo(advertisement.createdAt),
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RenameDeleteContextMenu(
                        onRename: () => _showRenameDialog(context, ref),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sell_outlined,
                              color: AppTheme.success,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Annonce',
                              style: TextStyle(
                                color: AppTheme.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: advertisement.status),
                    ],
                  ),
                  if (advertisement.price != null)
                    Text(
                      '${advertisement.price!.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
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

  String _buildVehicleInfo(PartAdvertisement ad) {
    final parts = <String>[];

    if (ad.vehicleBrand != null && ad.vehicleBrand!.isNotEmpty) {
      parts.add(ad.vehicleBrand!);
    }

    if (ad.vehicleModel != null && ad.vehicleModel!.isNotEmpty) {
      parts.add(ad.vehicleModel!);
    }

    if (ad.vehicleYear != null) {
      parts.add(ad.vehicleYear.toString());
    }

    return parts.isNotEmpty ? parts.join(' ') : 'Véhicule non spécifié';
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

  void _showRenameDialog(BuildContext context, WidgetRef ref) async {
    debugPrint('🏷️ [SellerAdsListPage] Début _showRenameDialog');
    debugPrint('🏷️ [SellerAdsListPage] ID annonce: ${advertisement.id}');
    debugPrint('🏷️ [SellerAdsListPage] Nom actuel: ${advertisement.partName}');

    final controller = TextEditingController(text: advertisement.partName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Renommer l\'annonce',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donnez un nouveau nom à votre annonce',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Ex: Moteur 2.0 TDI excellent état',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppTheme.gray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      debugPrint('✅ [SellerAdsListPage] Nouveau nom saisi: "$result"');
      await _renameAdvertisement(context, ref, result);
    } else {
      debugPrint('❌ [SellerAdsListPage] Dialogue annulé ou nom vide');
    }

    debugPrint('🏷️ [SellerAdsListPage] Fin _showRenameDialog');
  }

  Future<void> _renameAdvertisement(
      BuildContext context, WidgetRef ref, String newName) async {
    try {
      debugPrint('🔄 [SellerAdsListPage] Début renommage');
      debugPrint('🔄 [SellerAdsListPage] Nouveau nom: $newName');

      notificationService.info(
        context,
        'Renommage en cours...',
        subtitle: 'Veuillez patienter',
      );

      final success = await ref
          .read(partAdvertisementControllerProvider.notifier)
          .updateAdvertisement(advertisement.id, {
        'part_name': newName,
      });

      if (context.mounted) {
        if (success) {
          debugPrint('✅ [SellerAdsListPage] Renommage réussi');
          notificationService.success(
            context,
            'Annonce renommée',
            subtitle: 'Le nom a été mis à jour avec succès',
          );
        } else {
          final adState = ref.read(partAdvertisementControllerProvider);
          debugPrint('❌ [SellerAdsListPage] Échec renommage: ${adState.error}');
          notificationService.error(
            context,
            'Échec du renommage',
            subtitle: adState.error ?? 'Erreur lors du renommage',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [SellerAdsListPage] Exception: $e');
      if (context.mounted) {
        notificationService.error(
          context,
          'Erreur inattendue',
          subtitle: e.toString(),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final result = await context.showDestructiveDialog(
      title: 'Supprimer l\'annonce',
      message:
          'Êtes-vous sûr de vouloir supprimer cette annonce ? Cette action est irréversible.',
      destructiveText: 'Supprimer',
      cancelText: 'Annuler',
    );

    if (result == true && context.mounted) {
      _deleteItem(context, ref);
    }
  }

  void _deleteItem(BuildContext context, WidgetRef ref) async {
    try {
      notificationService.info(
        context,
        'Suppression en cours...',
        subtitle: 'Veuillez patienter',
      );

      final success = await ref
          .read(partAdvertisementControllerProvider.notifier)
          .deleteAdvertisement(advertisement.id);

      if (context.mounted) {
        if (success) {
          notificationService.success(
            context,
            'Suppression réussie',
            subtitle: 'L\'annonce a été supprimée',
          );
        } else {
          final adState = ref.read(partAdvertisementControllerProvider);
          final errorMessage = adState.error ?? 'Erreur lors de la suppression';
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
