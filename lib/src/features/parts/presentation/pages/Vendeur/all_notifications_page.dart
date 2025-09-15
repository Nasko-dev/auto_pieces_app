import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/seller_dashboard_providers.dart';
import '../../../../../core/providers/reject_part_request_provider.dart';
import '../../../domain/entities/part_request.dart';
import '../../../domain/usecases/reject_part_request.dart';
import '../../controllers/seller_dashboard_controller.dart';
import '../../../data/datasources/conversations_remote_datasource.dart';

class AllNotificationsPage extends ConsumerStatefulWidget {
  const AllNotificationsPage({super.key});

  @override
  ConsumerState<AllNotificationsPage> createState() => _AllNotificationsPageState();
}

class _AllNotificationsPageState extends ConsumerState<AllNotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    
    // Charger les premières notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sellerDashboardControllerProvider.notifier).loadNotifications();
    });
    
    // Écouter le scroll pour charger plus
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  // Nombre initial d'items à afficher
  int _itemsLoaded = 10;
  
  void _onScroll() {
    if (_isLoadingMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Charger plus quand on est à 80% du scroll
    if (currentScroll >= maxScroll * 0.8) {
      setState(() {
        _isLoadingMore = true;
      });
      
      // Charger 10 items de plus après un délai
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _itemsLoaded += 10;
            _isLoadingMore = false;
          });
        }
      });
    }
  }
  
  int _calculateItemsToShow(int totalItems) {
    // Afficher le minimum entre les items chargés et le total disponible
    return _itemsLoaded > totalItems ? totalItems : _itemsLoaded;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(sellerDashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Toutes les notifications',
          style: TextStyle(
            fontSize: 20,
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
      ),
      body: SafeArea(
        child: _buildContent(dashboardState),
      ),
    );
  }

  Widget _buildContent(SellerDashboardState state) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      ),
      loaded: (notifications, unreadCount) {
        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        // Calculer combien d'items afficher (lazy loading)
        final itemsToShow = _calculateItemsToShow(notifications.length);
        
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _itemsLoaded = 10; // Réinitialiser le compteur
            });
            ref.read(sellerDashboardControllerProvider.notifier).refresh();
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: itemsToShow + (_isLoadingMore && itemsToShow < notifications.length ? 1 : 0),
            itemBuilder: (context, index) {
              // Afficher l'indicateur de chargement en bas
              if (index >= itemsToShow) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              
              final notification = notifications[index];
              
              // Animation d'apparition pour les nouveaux éléments
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: const Offset(0, 0),
                  curve: Curves.easeOutCubic,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationCard(
                      partRequest: notification.partRequest,
                      isNew: notification.isNew,
                      onTap: () => _navigateToConversationDetail(notification.partRequest),
                      onAccept: () => _acceptAndRespond(context, notification.partRequest),
                      onReject: () => _rejectRequest(context, notification.partRequest),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      error: (message) => _buildErrorState(message),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 50,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les nouvelles demandes de pièces\napparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 50,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 20,
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
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
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
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  void _navigateToConversationDetail(PartRequest partRequest) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonction conversation en cours de développement')),
    );
  }

  void _acceptAndRespond(BuildContext context, PartRequest partRequest) async {
    try {
      final sellerId = Supabase.instance.client.auth.currentUser?.id;
      if (sellerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur : Vendeur non connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String sellerName = 'Vendeur Professionnel';
      String? sellerCompany;

      final dataSource = ConversationsRemoteDataSourceImpl(
        supabaseClient: Supabase.instance.client,
      );

      if (partRequest.userId == null) {
        throw Exception('ID utilisateur manquant dans la demande');
      }

      final conversation = await dataSource.createOrGetConversation(
        requestId: partRequest.id,
        userId: partRequest.userId!,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerCompany: sellerCompany,
        requestTitle: partRequest.partNames.join(', '),
      );

      if (mounted) {
        context.push('/seller/conversation/${conversation.id}');
      }

      ref.read(sellerDashboardControllerProvider.notifier).refresh();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectRequest(BuildContext context, PartRequest partRequest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              backgroundColor: AppTheme.error,
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
            const SnackBar(
              content: Text('Demande refusée avec succès'),
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

    ref.read(sellerDashboardControllerProvider.notifier).refresh();
  }
}

class _NotificationCard extends StatelessWidget {
  final PartRequest partRequest;
  final bool isNew;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _NotificationCard({
    required this.partRequest,
    required this.isNew,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew 
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.gray.withOpacity(0.2),
          width: isNew ? 2 : 1,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partRequest.vehicleInfo.isNotEmpty 
                              ? partRequest.vehicleInfo 
                              : 'Véhicule non spécifié',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          partRequest.partNames.join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.gray,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Nouveau',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              if (partRequest.additionalInfo != null && partRequest.additionalInfo!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.gray,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          partRequest.additionalInfo!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Refuser',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Répondre',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTimeAgo(partRequest.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.gray,
                    ),
                  ),
                  if (partRequest.responseCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${partRequest.responseCount} réponse${partRequest.responseCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
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

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${(difference.inDays / 7).floor()} sem';
    }
  }
}