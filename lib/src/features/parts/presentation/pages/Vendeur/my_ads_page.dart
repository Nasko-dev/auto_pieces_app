import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_advertisement.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';

part 'my_ads_page.freezed.dart';

// Classe pour unifier les annonces et les demandes
@freezed
class UnifiedItem with _$UnifiedItem {
  const factory UnifiedItem.advertisement(PartAdvertisement advertisement) =
      _Advertisement;
  const factory UnifiedItem.request(PartRequest request) = _Request;
}

class MyAdsPage extends ConsumerStatefulWidget {
  const MyAdsPage({super.key});

  @override
  ConsumerState<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends ConsumerState<MyAdsPage> {
  @override
  void initState() {
    super.initState();
    // Charger les annonces et demandes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(partAdvertisementControllerProvider.notifier)
          .getMyAdvertisements();
      ref.read(partRequestControllerProvider.notifier).loadUserPartRequests();
    });
  }

  String _selectedFilter = 'all';
  // Variable supprimée car non utilisée

  List<PartAdvertisement> get filteredAds {
    final advertisements =
        ref.watch(partAdvertisementControllerProvider).advertisements;

    final filtered = switch (_selectedFilter) {
      'active' => advertisements.where((ad) => ad.status == 'active').toList(),
      'sold' => advertisements.where((ad) => ad.status == 'sold').toList(),
      'paused' => advertisements.where((ad) => ad.status == 'paused').toList(),
      _ => advertisements,
    };

    return filtered;
  }

  List<PartRequest> get sellerRequests {
    final allRequests = ref.watch(partRequestControllerProvider).requests;
    final sellerRequests =
        allRequests.where((request) => request.isSellerRequest).toList();
    return sellerRequests;
  }

  // Liste unifiée d'annonces et de demandes
  List<UnifiedItem> get unifiedItems {
    final advertisements = filteredAds;
    final requests = sellerRequests;

    List<UnifiedItem> items = [];

    // Ajouter les annonces
    for (final ad in advertisements) {
      items.add(UnifiedItem.advertisement(ad));
    }

    // Ajouter les demandes vendeur
    for (final request in requests) {
      items.add(UnifiedItem.request(request));
    }

    // Trier par date de création (plus récent en premier)
    items.sort((a, b) {
      final dateA = a.when(
        advertisement: (ad) => ad.createdAt,
        request: (req) => req.createdAt,
      );
      final dateB = b.when(
        advertisement: (ad) => ad.createdAt,
        request: (req) => req.createdAt,
      );
      return dateB.compareTo(dateA);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          SellerHeader(
            title: 'Mes annonces',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.darkGray),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(partAdvertisementControllerProvider.notifier)
                      .getMyAdvertisements();
                  ref
                      .read(partRequestControllerProvider.notifier)
                      .loadUserPartRequests();
                },
                tooltip: 'Actualiser',
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppTheme.darkGray),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Navigation vers déposer une annonce
                },
                tooltip: 'Nouvelle annonce',
              ),
              const SellerMenu(),
            ],
          ),
          // Filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  _buildFilterChip(
                      'Toutes',
                      'all',
                      ref
                          .watch(partAdvertisementControllerProvider)
                          .advertisements
                          .length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'Actives',
                      'active',
                      ref
                          .watch(partAdvertisementControllerProvider)
                          .advertisements
                          .where((a) => a.status == 'active')
                          .length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'Vendues',
                      'sold',
                      ref
                          .watch(partAdvertisementControllerProvider)
                          .advertisements
                          .where((a) => a.status == 'sold')
                          .length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'Pausées',
                      'paused',
                      ref
                          .watch(partAdvertisementControllerProvider)
                          .advertisements
                          .where((a) => a.status == 'paused')
                          .length),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // Liste des annonces et demandes
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(partAdvertisementControllerProvider);
                // Variable supprimée car non utilisée

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
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${state.error}',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(partAdvertisementControllerProvider
                                    .notifier)
                                .getMyAdvertisements();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                // Check if both ads and requests are empty
                if (filteredAds.isEmpty && sellerRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune annonce ou demande',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(partAdvertisementControllerProvider.notifier)
                        .getMyAdvertisements();
                    await ref
                        .read(partRequestControllerProvider.notifier)
                        .loadUserPartRequests();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 200,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Annonces et Demandes
                          Text(
                            'Mes Annonces (${unifiedItems.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Liste unifiée des annonces et demandes
                          if (unifiedItems.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Aucune annonce',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vos annonces et demandes apparaîtront ici',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...unifiedItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _UnifiedItemCard(item: item),
                                )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes supprimées car non utilisées (toggleAdStatus, markAsSold, showDeleteConfirmation, deleteAdvertisement)
}

// Widget unifié pour afficher une annonce ou une demande
class _UnifiedItemCard extends StatelessWidget {
  final UnifiedItem item;

  const _UnifiedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return item.when(
      advertisement: (advertisement) =>
          _AdvertisementCard(advertisement: advertisement),
      request: (request) => _RequestCard(request: request),
    );
  }
}

// Widget pour afficher une annonce
class _AdvertisementCard extends ConsumerWidget {
  final PartAdvertisement advertisement;

  const _AdvertisementCard({required this.advertisement});

  void _showOptionsMenu(BuildContext context, WidgetRef ref, RenderBox button) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + buttonSize.width - 160, // Aligner à droite du bouton
        position.dy + buttonSize.height,
        position.dx + buttonSize.width,
        position.dy + buttonSize.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        // Bouton Modifier (fictif)
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {
            // Utiliser Future.delayed pour éviter le conflit avec Navigator.pop
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                notificationService.info(
                  context,
                  'Fonctionnalité à venir',
                );
              }
            });
          },
          child: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 12),
              Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Bouton Supprimer
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {
            // Utiliser Future.delayed pour éviter le conflit avec Navigator.pop
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                _showDeleteConfirmation(context, ref);
              }
            });
          },
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Supprimer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Supprimer l\'annonce ?',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'annonce "${advertisement.partName}" ? Cette action est irréversible.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Appeler la méthode de suppression du controller
                final success = await ref
                    .read(partAdvertisementControllerProvider.notifier)
                    .deleteAdvertisement(advertisement.id);

                if (context.mounted) {
                  if (success) {
                    notificationService.success(
                      context,
                      'Annonce supprimée avec succès',
                    );
                  } else {
                    final errorMsg =
                        ref.read(partAdvertisementControllerProvider).error ??
                            'Erreur lors de la suppression';
                    notificationService.error(
                      context,
                      errorMsg,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (advertisement.status) {
      case 'active':
        statusColor = AppTheme.success;
        statusText = 'Active';
        statusIcon = Icons.visibility;
        break;
      case 'sold':
        statusColor = AppTheme.primaryBlue;
        statusText = 'Vendue';
        statusIcon = Icons.check_circle;
        break;
      case 'paused':
        statusColor = AppTheme.warning;
        statusText = 'Pausée';
        statusIcon = Icons.pause_circle;
        break;
      default:
        statusColor = AppTheme.gray;
        statusText = 'Inconnue';
        statusIcon = Icons.help;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge "ANNONCE" en haut à droite avec menu 3 points
            Row(
              children: [
                Expanded(
                  child: Text(
                    advertisement.partName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Badge ANNONCE
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store, color: AppTheme.primaryBlue, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'ANNONCE',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Statut
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Menu 3 points
                Builder(
                  builder: (BuildContext buttonContext) {
                    return IconButton(
                      icon: Icon(Icons.more_vert,
                          color: AppTheme.darkGray, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final button =
                            buttonContext.findRenderObject() as RenderBox;
                        _showOptionsMenu(context, ref, button);
                      },
                      tooltip: 'Options',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Prix et informations véhicule
            Row(
              children: [
                Text(
                  '${advertisement.price?.toStringAsFixed(0) ?? '0'}€',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(advertisement.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Informations véhicule
            Text(
              _buildVehicleInfo(advertisement),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // Indicateur de stock
            _buildStockIndicator(advertisement),
          ],
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

    if (ad.vehicleEngine != null && ad.vehicleEngine!.isNotEmpty) {
      parts.add(ad.vehicleEngine!);
    }

    return parts.isNotEmpty ? parts.join(' ') : 'Véhicule non spécifié';
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }

  Widget _buildStockIndicator(PartAdvertisement ad) {
    Color stockColor;
    IconData stockIcon;
    String stockText;
    Color backgroundColor;

    // Déterminer le statut du stock
    if (ad.stockType == 'unlimited') {
      stockColor = AppTheme.success;
      backgroundColor = AppTheme.success.withValues(alpha: 0.1);
      stockIcon = Icons.all_inclusive;
      stockText = 'Stock illimité';
    } else if (ad.isOutOfStock) {
      stockColor = AppTheme.error;
      backgroundColor = AppTheme.error.withValues(alpha: 0.1);
      stockIcon = Icons.remove_circle_outline;
      stockText = 'Épuisé';
    } else if (ad.isLowStock) {
      stockColor = AppTheme.warning;
      backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
      stockIcon = Icons.warning_amber;
      stockText = 'Stock bas (${ad.availableQuantity})';
    } else {
      stockColor = AppTheme.success;
      backgroundColor = AppTheme.success.withValues(alpha: 0.1);
      stockIcon = Icons.check_circle_outline;
      stockText = ad.stockType == 'single'
        ? 'En stock'
        : 'En stock (${ad.availableQuantity})';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: stockColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stockIcon, color: stockColor, size: 16),
          const SizedBox(width: 6),
          Text(
            stockText,
            style: TextStyle(
              color: stockColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Afficher info réservation si applicable
          if (ad.reservedQuantity > 0 && ad.stockType != 'unlimited') ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${ad.reservedQuantity} réservé${ad.reservedQuantity > 1 ? 's' : ''}',
                style: TextStyle(
                  color: stockColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget pour afficher une demande vendeur
class _RequestCard extends ConsumerWidget {
  final PartRequest request;

  const _RequestCard({required this.request});

  void _showOptionsMenu(BuildContext context, WidgetRef ref, RenderBox button) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + buttonSize.width - 160,
        position.dy + buttonSize.height,
        position.dx + buttonSize.width,
        position.dy + buttonSize.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        // Bouton Modifier (fictif)
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                notificationService.info(
                  context,
                  'Fonctionnalité à venir',
                );
              }
            });
          },
          child: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 20),
              SizedBox(width: 12),
              Text(
                'Modifier',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Bouton Supprimer
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: () {
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                _showDeleteConfirmation(context, ref);
              }
            });
          },
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Supprimer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Supprimer la demande ?',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette demande ? Cette action est irréversible.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Fonctionnalité en cours de développement
                notificationService.info(
                  context,
                  'Fonctionnalité en cours de développement',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec badges
          Row(
            children: [
              Expanded(
                child: Text(
                  request.partNames.join(', '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Badge DEMANDE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, color: AppTheme.warning, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'DEMANDE',
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge PRO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Menu 3 points
              Builder(
                builder: (BuildContext buttonContext) {
                  return IconButton(
                    icon: Icon(Icons.more_vert,
                        color: AppTheme.darkGray, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final button =
                          buttonContext.findRenderObject() as RenderBox;
                      _showOptionsMenu(context, ref, button);
                    },
                    tooltip: 'Options',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Informations véhicule
          if (request.vehicleInfo.isNotEmpty)
            Text(
              request.vehicleInfo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

          // Type de pièce
          Text(
            'Type: ${request.partType == 'engine' ? 'Moteur' : 'Carrosserie'}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),

          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              _buildStat(Icons.schedule, _timeAgo(request.createdAt), 'Créée'),
              const SizedBox(width: 16),
              _buildStat(Icons.reply, '${request.responseCount}', 'Réponses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }
}
