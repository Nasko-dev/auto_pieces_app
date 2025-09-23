import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/parts/presentation/providers/conversations_providers.dart';

class SellerWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SellerWrapper({super.key, required this.child});

  @override
  ConsumerState<SellerWrapper> createState() => _SellerWrapperState();
}

class _SellerWrapperState extends ConsumerState<SellerWrapper> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/seller/home':
        return 0;
      case '/seller/add':
      case '/seller/create-ad':
      case '/seller/create-request':
        return 1;
      case '/seller/ads':
        return 2;
      case '/seller/messages':
        return 3;
      default:
        return 0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [Expanded(child: widget.child)]),
      // Bottom bar vendeur
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Tableau',
                  route: '/seller/home',
                  index: 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  selectedIcon: Icons.add_circle,
                  label: 'Déposer',
                  route: '/seller/add',
                  index: 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  label: 'Mes annonces',
                  route: '/seller/ads',
                  index: 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  selectedIcon: Icons.chat_bubble,
                  label: 'Messages',
                  route: '/seller/messages',
                  index: 3,
                  hasUnread: ref.watch(totalUnreadCountProvider) > 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String route,
    required int index,
    bool hasUnread = false,
  }) {
    final isSelected = _getCurrentIndex(context) == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? selectedIcon : icon,
                      size: 22,
                      color:
                          isSelected ? const Color(0xFF1976D2) : AppTheme.gray,
                    ),
                    // Point rouge pour messages non lus
                    if (hasUnread)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF1976D2) : AppTheme.gray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
