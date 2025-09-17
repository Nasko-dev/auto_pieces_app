import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../controllers/part_advertisement_controller.dart';
import '../../../domain/entities/part_advertisement.dart';

class MyAdsPage extends ConsumerStatefulWidget {
  const MyAdsPage({super.key});
  
  @override
  ConsumerState<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends ConsumerState<MyAdsPage> {
  
  @override
  void initState() {
    super.initState();
    // Charger les annonces au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(partAdvertisementControllerProvider.notifier).getMyAdvertisements();
    });
  }

  String _selectedFilter = 'all';

  List<PartAdvertisement> get filteredAds {
    final advertisements = ref.watch(partAdvertisementControllerProvider).advertisements;
    
    switch (_selectedFilter) {
      case 'active':
        return advertisements.where((ad) => ad.status == 'active').toList();
      case 'sold':
        return advertisements.where((ad) => ad.status == 'sold').toList();
      case 'paused':
        return advertisements.where((ad) => ad.status == 'paused').toList();
      default:
        return advertisements;
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1976D2);
    
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mes annonces',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [blue, blue.withValues(alpha: 0.8)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigation vers déposer une annonce
            },
            tooltip: 'Nouvelle annonce',
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SellerMenu(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  _buildFilterChip('Toutes', 'all', ref.watch(partAdvertisementControllerProvider).advertisements.length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Actives', 'active', ref.watch(partAdvertisementControllerProvider).advertisements.where((a) => a.status == 'active').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vendues', 'sold', ref.watch(partAdvertisementControllerProvider).advertisements.where((a) => a.status == 'sold').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pausées', 'paused', ref.watch(partAdvertisementControllerProvider).advertisements.where((a) => a.status == 'paused').length),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          
          // Liste des annonces
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(partAdvertisementControllerProvider);
                
                
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
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${state.error}',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(partAdvertisementControllerProvider.notifier).getMyAdvertisements();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (filteredAds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' 
                              ? 'Aucune annonce pour le moment'
                              : 'Aucune annonce dans cette catégorie',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _AdCard(
                      advertisement: filteredAds[index],
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Navigation vers le détail de l'annonce
                      },
                      onToggleStatus: () {
                        HapticFeedback.lightImpact();
                        _toggleAdStatus(filteredAds[index]);
                      },
                      onMarkAsSold: () {
                        HapticFeedback.lightImpact();
                        _markAsSold(filteredAds[index]);
                      },
                      onDelete: () {
                        HapticFeedback.lightImpact();
                        _showDeleteConfirmation(filteredAds[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    const blue = Color(0xFF1976D2);
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
          color: isSelected ? blue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? blue : Colors.grey.shade300,
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
                color: isSelected ? blue : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? blue : Colors.grey.shade400,
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


  void _toggleAdStatus(PartAdvertisement ad) async {
    String newStatus;
    if (ad.status == 'active') {
      newStatus = 'paused';
    } else if (ad.status == 'paused') {
      newStatus = 'active';
    } else {
      return; // Ne rien faire si l'annonce est vendue
    }
    
    await ref.read(partAdvertisementControllerProvider.notifier)
        .updateAdvertisement(ad.id, {'status': newStatus});
  }

  void _markAsSold(PartAdvertisement advertisement) async {
    await ref.read(partAdvertisementControllerProvider.notifier)
        .updateAdvertisement(advertisement.id, {'status': 'sold'});
  }

  void _showDeleteConfirmation(PartAdvertisement advertisement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'annonce "${advertisement.partName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAdvertisement(advertisement);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _deleteAdvertisement(PartAdvertisement advertisement) async {
    try {
      final controller = ref.read(partAdvertisementControllerProvider.notifier);
      final success = await controller.deleteAdvertisement(advertisement.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Le controller rafraîchit déjà automatiquement la liste
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AdCard extends StatelessWidget {
  final PartAdvertisement advertisement;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final VoidCallback onMarkAsSold;
  final VoidCallback onDelete;
  
  const _AdCard({
    required this.advertisement,
    required this.onTap,
    required this.onToggleStatus,
    required this.onMarkAsSold,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1976D2);
    const green = Color(0xFF00C853);
    const orange = Color(0xFFFF9800);
    const grey = Color(0xFF9E9E9E);
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (advertisement.status) {
      case 'active':
        statusColor = green;
        statusText = 'Active';
        statusIcon = Icons.visibility;
        break;
      case 'sold':
        statusColor = blue;
        statusText = 'Vendue';
        statusIcon = Icons.check_circle;
        break;
      case 'paused':
        statusColor = orange;
        statusText = 'Pausée';
        statusIcon = Icons.pause_circle;
        break;
      default:
        statusColor = grey;
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
              
              // Statistiques et actions
              Row(
                children: [
                  _buildStat(Icons.message, '0', 'messages'), // TODO: Implémenter les stats,
                  const Spacer(),
                  
                  // Actions compactes
                  if (advertisement.status != 'sold') ...[
                    IconButton(
                      onPressed: onToggleStatus,
                      icon: Icon(
                        advertisement.status == 'active' ? Icons.pause : Icons.play_arrow,
                        color: advertisement.status == 'active' ? orange : green,
                        size: 20,
                      ),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: advertisement.status == 'active' ? 'Pause' : 'Active',
                    ),
                  ],
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    itemBuilder: (context) => [
                      if (advertisement.status != 'sold')
                        const PopupMenuItem(
                          value: 'sold',
                          height: 40,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 18),
                              SizedBox(width: 8),
                              Text('Marquer vendue', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        height: 40,
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      HapticFeedback.lightImpact();
                      switch (value) {
                        case 'sold':
                          onMarkAsSold();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
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
    
    if (ad.vehicleEngine != null && ad.vehicleEngine!.isNotEmpty) {
      parts.add(ad.vehicleEngine!);
    }
    
    return parts.isNotEmpty ? parts.join(' ') : 'Véhicule non spécifié';
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// La classe AdItem n'est plus nécessaire car on utilise directement PartAdvertisement