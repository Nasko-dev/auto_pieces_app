import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/particulier_conversations_providers.dart';
import 'auth_wrapper.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const MainWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/home':
        return 0;
      case '/requests':
        return 1;
      case '/messages-clients':
        return 2;
      case '/become-seller':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        body: widget.child,
        // Bottom bar style LinkedIn
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
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    icon: Icons.home_rounded,
                    selectedIcon: Icons.home_rounded,
                    label: 'Accueil',
                    route: '/home',
                    index: 0,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.assignment_outlined,
                    selectedIcon: Icons.assignment_rounded,
                    label: 'Demandes',
                    route: '/requests',
                    index: 1,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.forum_outlined,
                    selectedIcon: Icons.forum_rounded,
                    label: 'Messages',
                    route: '/messages-clients',
                    index: 2,
                    hasUnread: ref
                            .watch(particulierConversationsControllerProvider)
                            .unreadCount >
                        0,
                  ),
                  _buildNavItem(
                    context: context,
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront_rounded,
                    label: 'Vendeur',
                    route: '/become-seller',
                    index: 3,
                  ),
                ],
              ),
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
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    size: 26,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.gray,
                  ),
                ),
                // Point rouge pour messages non lus
                if (hasUnread)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
