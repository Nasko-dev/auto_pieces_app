import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_advertisement.dart';
import '../../../domain/entities/part_request.dart';

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

  List<PartAdvertisement> get advertisements {
    return ref.watch(partAdvertisementControllerProvider).advertisements;
  }

  List<PartRequest> get sellerRequests {
    final allRequests = ref.watch(partRequestControllerProvider).requests;
    final sellerRequests =
        allRequests.where((request) => request.isSellerRequest).toList();
    return sellerRequests;
  }

  // Liste unifiée d'annonces et de demandes
  List<UnifiedItem> get unifiedItems {
    final ads = advertisements;
    final requests = sellerRequests;

    List<UnifiedItem> items = [];

    // Ajouter les annonces
    for (final ad in ads) {
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
                if (advertisements.isEmpty && sellerRequests.isEmpty) {
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
class _AdvertisementCard extends StatelessWidget {
  final PartAdvertisement advertisement;

  const _AdvertisementCard({required this.advertisement});

  @override
  Widget build(BuildContext context) {
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
            // Informations véhicule et statut
            Row(
              children: [
                Expanded(
                  child: Text(
                    _buildVehicleInfo(advertisement),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Badge Statut
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
              ],
            ),

            const SizedBox(height: 8),

            // Nom de la pièce
            Text(
              advertisement.partName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            // Date de création
            Text(
              _timeAgo(advertisement.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 12),

            // Stock disponible (cliquable)
            _StockBadge(advertisement: advertisement),
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
}

// Widget badge de stock cliquable
class _StockBadge extends ConsumerWidget {
  final PartAdvertisement advertisement;

  const _StockBadge({required this.advertisement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = advertisement.quantityAvailable;
    Color stockColor;
    String stockLabel;

    if (stock == 0) {
      stockColor = AppTheme.error;
      stockLabel = 'Rupture de stock';
    } else if (stock <= 2) {
      stockColor = AppTheme.warning;
      stockLabel = 'Stock limité';
    } else {
      stockColor = AppTheme.success;
      stockLabel = 'En stock';
    }

    return GestureDetector(
      onTap: () => _showStockDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: stockColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: stockColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2, color: stockColor, size: 16),
            const SizedBox(width: 8),
            Text(
              '$stockLabel : ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$stock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: stockColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, color: stockColor, size: 14),
          ],
        ),
      ),
    );
  }

  void _showStockDialog(BuildContext context, WidgetRef ref) {
    int currentStock = advertisement.quantityAvailable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  const Text(
                    'Gérer le stock',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nom de la pièce
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      advertisement.partName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Compteur avec boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bouton -
                      GestureDetector(
                        onTap: currentStock > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  currentStock--;
                                });
                              }
                            : null,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: currentStock > 0
                                ? AppTheme.error.withValues(alpha: 0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: currentStock > 0
                                ? AppTheme.error
                                : Colors.grey[400],
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Affichage du stock
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$currentStock',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Bouton +
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            currentStock++;
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppTheme.success,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Boutons d'action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Bouton Valider
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              Navigator.of(bottomSheetContext).pop();
                              await _updateStock(context, ref, currentStock);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Valider',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bouton Annuler
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(bottomSheetContext).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStock(
      BuildContext context, WidgetRef ref, int newStock) async {
    try {
      // Appeler le controller pour mettre à jour le stock
      final success = await ref
          .read(partAdvertisementControllerProvider.notifier)
          .updateStock(advertisement.id, newStock);

      if (context.mounted) {
        if (success) {
          notificationService.success(
            context,
            'Stock mis à jour',
            subtitle: 'Nouveau stock : $newStock',
          );
        } else {
          final error = ref.read(partAdvertisementControllerProvider).error;
          notificationService.error(
            context,
            'Erreur',
            subtitle: error ?? 'Erreur lors de la mise à jour du stock',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        notificationService.error(
          context,
          'Erreur',
          subtitle: e.toString(),
        );
      }
    }
  }
}

// Widget pour afficher une demande vendeur
class _RequestCard extends StatelessWidget {
  final PartRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
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
