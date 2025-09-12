import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({super.key});
  
  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  
  final List<AdItem> ads = [
    AdItem(
      title: 'Phare avant droit',
      carModel: 'Renault Clio 2015',
      price: '85',
      status: 'active',
      views: 24,
      messages: 3,
      imageUrl: null,
      description: 'Phare en bon état, quelques rayures superficielles',
    ),
    AdItem(
      title: 'Moteur 1.6 HDI',
      carModel: 'Peugeot 308 2014',
      price: '1200',
      status: 'sold',
      views: 67,
      messages: 8,
      imageUrl: null,
      description: 'Moteur révisé, 120 000 km',
    ),
    AdItem(
      title: 'Pare-chocs avant',
      carModel: 'BMW Série 1 2016',
      price: '250',
      status: 'paused',
      views: 12,
      messages: 1,
      imageUrl: null,
      description: 'Pare-chocs avec quelques éclats de peinture',
    ),
    AdItem(
      title: 'Jantes alliage 16"',
      carModel: 'Volkswagen Golf 2013',
      price: '180',
      status: 'active',
      views: 45,
      messages: 6,
      imageUrl: null,
      description: 'Set de 4 jantes, bon état général',
    ),
  ];

  String _selectedFilter = 'all';

  List<AdItem> get filteredAds {
    switch (_selectedFilter) {
      case 'active':
        return ads.where((ad) => ad.status == 'active').toList();
      case 'sold':
        return ads.where((ad) => ad.status == 'sold').toList();
      case 'paused':
        return ads.where((ad) => ad.status == 'paused').toList();
      default:
        return ads;
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
              colors: [blue, blue.withOpacity(0.8)],
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
                  _buildFilterChip('Toutes', 'all', ads.length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Actives', 'active', ads.where((a) => a.status == 'active').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vendues', 'sold', ads.where((a) => a.status == 'sold').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pausées', 'paused', ads.where((a) => a.status == 'paused').length),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          
          // Liste des annonces
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredAds.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _AdCard(
                  ad: filteredAds[index],
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Navigation vers le détail de l'annonce
                  },
                  onEdit: () {
                    HapticFeedback.lightImpact();
                    // Navigation vers l'édition
                  },
                  onToggleStatus: () {
                    HapticFeedback.lightImpact();
                    _toggleAdStatus(filteredAds[index]);
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
          color: isSelected ? blue.withOpacity(0.1) : Colors.transparent,
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

  void _toggleAdStatus(AdItem ad) {
    setState(() {
      if (ad.status == 'active') {
        ad.status = 'paused';
      } else if (ad.status == 'paused') {
        ad.status = 'active';
      }
    });
  }
}

class _AdCard extends StatelessWidget {
  final AdItem ad;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  
  const _AdCard({
    required this.ad,
    required this.onTap,
    required this.onEdit,
    required this.onToggleStatus,
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
    
    switch (ad.status) {
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
            color: Colors.black.withOpacity(0.04),
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
                      ad.title,
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
                      color: statusColor.withOpacity(0.1),
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
              
              // Modèle et prix
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ad.carModel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${ad.price} €',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Statistiques et actions
              Row(
                children: [
                  _buildStat(Icons.visibility, '${ad.views}', 'vues'),
                  const SizedBox(width: 12),
                  _buildStat(Icons.message, '${ad.messages}', 'messages'),
                  const Spacer(),
                  
                  // Actions compactes
                  if (ad.status != 'sold') ...[
                    IconButton(
                      onPressed: onToggleStatus,
                      icon: Icon(
                        ad.status == 'active' ? Icons.pause : Icons.play_arrow,
                        color: ad.status == 'active' ? orange : green,
                        size: 20,
                      ),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: ad.status == 'active' ? 'Pause' : 'Active',
                    ),
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit, color: blue, size: 20),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Modifier',
                    ),
                  ],
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        height: 40,
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Dupliquer', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      if (ad.status != 'sold')
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
                      // Gérer les actions du menu
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

class AdItem {
  String title;
  String carModel;
  String price;
  String status; // 'active', 'sold', 'paused'
  int views;
  int messages;
  String? imageUrl;
  String description;
  
  AdItem({
    required this.title,
    required this.carModel,
    required this.price,
    required this.status,
    required this.views,
    required this.messages,
    this.imageUrl,
    required this.description,
  });
}