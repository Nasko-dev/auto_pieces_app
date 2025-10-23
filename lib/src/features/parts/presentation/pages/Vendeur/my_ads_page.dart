import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../../../../shared/presentation/widgets/context_menu.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_advertisement.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/providers/providers.dart';

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

  List<PartRequest> get sellerRequests {
    final allRequests = ref.watch(partRequestControllerProvider).requests;
    final sellerRequests =
        allRequests.where((request) => request.isSellerRequest).toList();
    return sellerRequests;
  }

  // Liste unifiée d'annonces et de demandes
  List<UnifiedItem> get unifiedItems {
    final advertisements = ref.watch(partAdvertisementControllerProvider).advertisements;
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
                if (state.advertisements.isEmpty && sellerRequests.isEmpty) {
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

  // Méthodes supprimées car non utilisées (toggleAdStatus, markAsSold, showDeleteConfirmation, deleteAdvertisement, buildFilterChip)
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

  void _showEditModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _EditAdvertisementModal(advertisement: advertisement);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Titre avec menu 3 points
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
                // Menu 3 points
                EditDeleteContextMenu(
                  onEdit: () => _showEditModal(context, ref),
                  onDelete: () => _showDeleteConfirmation(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Nom de la pièce
            Text(
              advertisement.partName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Indicateur de stock et date
            Row(
              children: [
                _buildStockIndicator(context, ref, advertisement),
                const Spacer(),
                Text(
                  _timeAgo(advertisement.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildVehicleInfo(PartAdvertisement ad) {
    // Si un titre personnalisé existe, l'utiliser
    if (ad.title != null && ad.title!.isNotEmpty) {
      return ad.title!;
    }

    // Sinon, construire à partir des infos véhicule
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

  Widget _buildStockIndicator(BuildContext context, WidgetRef ref, PartAdvertisement ad) {
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStockStatusMenu(context, ref, ad);
      },
      child: Container(
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
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: stockColor,
              size: 18,
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
      ),
    );
  }

  void _showStockStatusMenu(BuildContext context, WidgetRef ref, PartAdvertisement ad) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Titre
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Modifier le statut',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Option: En stock
            _buildStatusOption(
              context: context,
              icon: Icons.check_circle_outline,
              label: 'En stock',
              color: AppTheme.success,
              isSelected: !ad.isOutOfStock && !ad.isLowStock,
              onTap: () async {
                Navigator.pop(context);
                await _updateStockStatus(context, ref, ad, 'in_stock');
              },
            ),

            const Divider(height: 1),

            // Option: En attente
            _buildStatusOption(
              context: context,
              icon: Icons.schedule,
              label: 'En attente',
              color: AppTheme.warning,
              isSelected: ad.isLowStock,
              onTap: () async {
                Navigator.pop(context);
                await _updateStockStatus(context, ref, ad, 'pending');
              },
            ),

            const Divider(height: 1),

            // Option: Épuisé
            _buildStatusOption(
              context: context,
              icon: Icons.remove_circle_outline,
              label: 'Épuisé',
              color: AppTheme.error,
              isSelected: ad.isOutOfStock,
              onTap: () async {
                Navigator.pop(context);
                await _updateStockStatus(context, ref, ad, 'out_of_stock');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStockStatus(
    BuildContext context,
    WidgetRef ref,
    PartAdvertisement ad,
    String status,
  ) async {
    Map<String, dynamic> updates = {};
    String successMessage = '';

    // Déterminer la quantité selon le statut
    if (status == 'in_stock') {
      // En stock : quantité supérieure au seuil
      final newQuantity = (ad.lowStockThreshold + 5).clamp(1, 999);
      updates['quantity'] = newQuantity;
      successMessage = 'Statut mis à jour: En stock';
    } else if (status == 'pending') {
      // En attente : quantité égale au seuil (low stock)
      updates['quantity'] = ad.lowStockThreshold;
      successMessage = 'Statut mis à jour: En attente';
    } else if (status == 'out_of_stock') {
      // Épuisé : quantité = 0
      updates['quantity'] = 0;
      successMessage = 'Statut mis à jour: Épuisé';
    }

    // Mettre à jour via le controller
    final controller = ref.read(partAdvertisementControllerProvider.notifier);
    final success = await controller.updateAdvertisement(ad.id, updates);

    if (!context.mounted) return;

    if (success) {
      notificationService.success(context, successMessage);
    } else {
      notificationService.error(
        context,
        'Erreur lors de la mise à jour du statut',
      );
    }
  }

  Widget _buildStatusOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : AppTheme.darkGray,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

// Widget pour afficher une demande vendeur
class _RequestCard extends ConsumerWidget {
  final PartRequest request;

  const _RequestCard({required this.request});

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
              EditDeleteContextMenu(
                onEdit: () {
                  notificationService.info(
                    context,
                    'Fonctionnalité à venir',
                  );
                },
                onDelete: () => _showDeleteConfirmation(context, ref),
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

// Modal d'édition style iOS
class _EditAdvertisementModal extends ConsumerStatefulWidget {
  final PartAdvertisement advertisement;

  const _EditAdvertisementModal({required this.advertisement});

  @override
  ConsumerState<_EditAdvertisementModal> createState() => _EditAdvertisementModalState();
}

class _EditAdvertisementModalState extends ConsumerState<_EditAdvertisementModal> {
  late TextEditingController _titleController;
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _selectedParts = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;
  late int _initialPartsCount;
  late List<String> _initialParts;
  late List<String> _initialSelectedParts; // État initial de _selectedParts
  late String _initialTitle;

  @override
  void initState() {
    super.initState();
    // Initialiser avec les infos du véhicule comme titre par défaut
    final vehicleInfo = _buildVehicleInfo(widget.advertisement);
    _initialTitle = vehicleInfo;
    _titleController = TextEditingController(text: vehicleInfo);
    _searchController = TextEditingController();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && mounted) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });

    // Initialiser avec les pièces du partName actuel
    if (widget.advertisement.partName.isNotEmpty) {
      final partNameLower = widget.advertisement.partName.toLowerCase();

      // Détecter si c'est une catégorie large (moteur complet, ensemble, kit, etc.)
      final isLargeCategory = partNameLower.contains('complet') ||
          partNameLower.contains('ensemble') ||
          partNameLower.contains('kit') ||
          partNameLower.contains('tout') ||
          partNameLower.contains('intégral') ||
          partNameLower.contains('total');

      if (isLargeCategory) {
        // Pour les catégories larges : NE PAS afficher le nom comme chip
        // Forcer l'input de recherche pour sélectionner les pièces spécifiques
        _initialParts = [];
        _initialPartsCount = 999; // Force l'affichage de l'input
        _initialSelectedParts = [];
        // Ne pas pré-remplir _selectedParts
      } else {
        // Pour les annonces normales : parser le part_name
        final parsedParts = widget.advertisement.partName
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        // _initialParts contient TOUJOURS les pièces du partName (pour l'affichage)
        _initialParts = parsedParts;
        _initialPartsCount = _initialParts.length;

        // Mais _selectedParts ne contient que les pièces disponibles (quantity > 0)
        if (widget.advertisement.quantity != null && widget.advertisement.quantity! > 0) {
          _selectedParts.addAll(_initialParts);
        } else {
          // _selectedParts reste vide = toutes les pièces décochées
        }

        // Mémoriser l'état initial de _selectedParts pour la comparaison
        _initialSelectedParts = List.from(_selectedParts);
      }
    } else {
      _initialParts = [];
      _initialPartsCount = 0;
      _initialSelectedParts = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.rpc(
        'search_parts',
        params: {
          'search_query': query,
          'filter_category': null,
          'limit_results': 10,
        },
      );

      if (response != null && mounted) {
        final parts = (response as List)
            .cast<Map<String, dynamic>>()
            .map((data) => data['name'] as String?)
            .where((name) => name != null && name.isNotEmpty)
            .cast<String>()
            .toList();

        setState(() {
          _suggestions = parts;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    }
  }

  void _addPart(String part) {
    if (!_selectedParts.contains(part)) {
      setState(() {
        _selectedParts.add(part);
        _searchController.clear();
        _suggestions = [];
        _showSuggestions = false;
      });
      HapticFeedback.mediumImpact();
      _searchFocusNode.unfocus();
    }
  }

  String _buildVehicleInfo(PartAdvertisement ad) {
    // Si un titre personnalisé existe, l'utiliser
    if (ad.title != null && ad.title!.isNotEmpty) {
      return ad.title!;
    }

    // Sinon, construire à partir des infos véhicule
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

  Future<void> _saveAdvertisementChanges(BuildContext context, WidgetRef ref) async {
    // Préparer les updates
    Map<String, dynamic> updates = {};

    // Debug: afficher l'état actuel
    // Vérifier si le titre a changé
    final currentTitle = _titleController.text.trim();
    final hasTitleChanged = currentTitle != _initialTitle && currentTitle.isNotEmpty;

    if (hasTitleChanged) {
      // Sauvegarder le titre personnalisé dans le champ title
      updates['title'] = currentTitle;
    }

    // Vérifier si les pièces ont changé (comparer avec l'état INITIAL de _selectedParts)
    final selectedPartsSorted = _selectedParts.toList()..sort();
    final initialSelectedPartsSorted = _initialSelectedParts.toList()..sort();

    final hasPartsChanged = selectedPartsSorted.length != initialSelectedPartsSorted.length ||
        !selectedPartsSorted.every((part) => initialSelectedPartsSorted.contains(part));

    if (hasPartsChanged) {
      if (_initialPartsCount < 5) {
        // Cas < 5 pièces : mettre à jour avec les pièces encore disponibles (cochées)
        if (_selectedParts.isNotEmpty) {
          updates['part_name'] = _selectedParts.join(', ');
          // Mettre à jour la quantity selon le nombre de pièces sélectionnées
          final currentQuantity = widget.advertisement.quantity ?? 0;
          if (currentQuantity == 0 || _selectedParts.length != _initialSelectedParts.length) {
            updates['quantity'] = _selectedParts.length;
          }
        } else {
          // Toutes les pièces ont été vendues, marquer comme épuisé
          updates['part_name'] = widget.advertisement.partName; // Garder le nom original
          updates['quantity'] = 0; // Marquer comme épuisé
        }
      } else {
        // Cas >= 5 pièces : les pièces sélectionnées sont celles vendues
        // On met à jour pour indiquer les pièces vendues
        if (_selectedParts.isNotEmpty) {
          // Créer une note des pièces vendues dans le part_name
          final soldPartsText = 'Pièces vendues: ${_selectedParts.join(', ')}';
          updates['part_name'] = '${widget.advertisement.partName} ($soldPartsText)';
        }
      }
    }

    // Si aucune modification, fermer simplement
    if (updates.isEmpty) {
      if (!mounted) return;
      Navigator.pop(context);
      notificationService.info(context, 'Aucune modification à enregistrer');
      return;
    }

    // Capturer le context avant les appels async
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Sauvegarder via le controller
    final controller = ref.read(partAdvertisementControllerProvider.notifier);
    final success = await controller.updateAdvertisement(
      widget.advertisement.id,
      updates,
    );

    if (!mounted) return;

    if (success) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Modifications enregistrées'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
          backgroundColor: AppTheme.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Empêche la fermeture en tapant sur le contenu
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle (barre de glissement)
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                color: AppTheme.error,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Modifier l\'annonce',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await _saveAdvertisementChanges(context, ref);
                            },
                            child: const Text(
                              'Enregistrer',
                              style: TextStyle(
                                color: AppTheme.primaryBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Contenu scrollable
                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Section Titre
                          const Text(
                            'Titre de l\'annonce',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Ex: Renault Clio 2015 1.5 dCi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryBlue,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 32),

                          // Section Pièces - Affichage conditionnel
                          Text(
                            _initialPartsCount < 5
                                ? 'Veuillez décocher les pièces que vous avez vendues'
                                : 'Veuillez sélectionner les pièces que vous avez vendues',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cas 1: Moins de 5 pièces - Afficher seulement les pièces initiales
                          if (_initialPartsCount < 5) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _initialParts.map((part) {
                                final isSelected = _selectedParts.contains(part);
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      if (isSelected) {
                                        _selectedParts.remove(part);
                                      } else {
                                        _selectedParts.add(part);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.success.withValues(alpha: 0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.success
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: AppTheme.success,
                                            ),
                                          ),
                                        Flexible(
                                          child: Text(
                                            part,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppTheme.success
                                                  : AppTheme.darkGray,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          isSelected ? Icons.expand_less : Icons.expand_more,
                                          size: 16,
                                          color: isSelected
                                              ? AppTheme.success
                                              : Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Cas 2: 5 pièces ou plus - Afficher l'input de recherche
                          if (_initialPartsCount >= 5) ...[
                            // Champ de recherche Supabase
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher une pièce...',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    suffixIcon: _isSearching
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryBlue,
                                                ),
                                              ),
                                            ),
                                          )
                                        : _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  setState(() {
                                                    _suggestions = [];
                                                    _showSuggestions = false;
                                                  });
                                                },
                                              )
                                            : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 15),
                                ),

                                // Liste des suggestions
                                if (_showSuggestions && _suggestions.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(
                                      maxHeight: 250,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: _suggestions.length,
                                      separatorBuilder: (context, index) => Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      ),
                                      itemBuilder: (context, index) {
                                        final suggestion = _suggestions[index];
                                        final isAlreadySelected = _selectedParts.contains(suggestion);

                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            suggestion,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isAlreadySelected
                                                  ? Colors.grey[400]
                                                  : Colors.black87,
                                              fontWeight: isAlreadySelected
                                                  ? FontWeight.w400
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          trailing: isAlreadySelected
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: AppTheme.success,
                                                  size: 20,
                                                )
                                              : const Icon(
                                                  Icons.add_circle_outline,
                                                  color: AppTheme.primaryBlue,
                                                  size: 20,
                                                ),
                                          onTap: isAlreadySelected
                                              ? null
                                              : () => _addPart(suggestion),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ],

                          // Pièces vendues/épuisées - Affichage conditionnel
                          // Pour < 5 pièces : afficher les pièces DÉCOCHÉES (vendues)
                          // Pour >= 5 pièces : afficher les pièces AJOUTÉES (vendues)
                          if (_initialPartsCount < 5) ...[
                            // Cas < 5 : Afficher les pièces décochées
                            () {
                              final soldParts = _initialParts.where((part) => !_selectedParts.contains(part)).toList();
                              if (soldParts.isNotEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 24),
                                    Text(
                                      'Pièces vendues (${soldParts.length})',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: soldParts.map((part) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.error.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppTheme.error,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.remove_circle,
                                                size: 14,
                                                color: AppTheme.error,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  part,
                                                  style: const TextStyle(
                                                    color: AppTheme.error,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            }(),
                          ] else if (_initialPartsCount >= 5 && _selectedParts.isNotEmpty) ...[
                            // Cas >= 5 : Afficher les pièces ajoutées
                            const SizedBox(height: 24),
                            Text(
                              'Pièces vendues (${_selectedParts.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedParts.map((part) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.remove_circle,
                                        size: 14,
                                        color: AppTheme.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          part,
                                          style: const TextStyle(
                                            color: AppTheme.error,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            _selectedParts.remove(part);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppTheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Info sélection
                          if (_selectedParts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${_selectedParts.length} pièce${_selectedParts.length > 1 ? 's' : ''} sélectionnée${_selectedParts.length > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
