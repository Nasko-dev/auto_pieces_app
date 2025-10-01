import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
}

// Wrapper pour gérer proprement l'overlay
class IOSNotificationWrapper extends StatefulWidget {
  final String message;
  final String? subtitle;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const IOSNotificationWrapper({
    super.key,
    required this.message,
    this.subtitle,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onTap,
    this.showCloseButton = false,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<IOSNotificationWrapper> createState() => _IOSNotificationWrapperState();
}

class _IOSNotificationWrapperState extends State<IOSNotificationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto-dismiss après la durée spécifiée (sauf pour loading)
    if (widget.type != NotificationType.loading) {
      Future.delayed(widget.duration, () {
        if (mounted && !_isExiting) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isExiting || !mounted) return;
    setState(() => _isExiting = true);

    try {
      await _controller.reverse();
    } catch (e) {
      // Ignorer les erreurs d'animation si le widget est détruit
    }

    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSNotification(
      message: widget.message,
      subtitle: widget.subtitle,
      type: widget.type,
      controller: _controller,
      slideAnimation: _slideAnimation,
      fadeAnimation: _fadeAnimation,
      scaleAnimation: _scaleAnimation,
      onTap: widget.onTap,
      onDismiss: _dismiss,
      showCloseButton: widget.showCloseButton,
      actionLabel: widget.actionLabel,
      onAction: widget.onAction,
    );
  }
}

class IOSNotification extends StatelessWidget {
  final String message;
  final String? subtitle;
  final NotificationType type;
  final AnimationController controller;
  final Animation<double> slideAnimation;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  final bool showCloseButton;
  final String? actionLabel;
  final VoidCallback? onAction;

  const IOSNotification({
    super.key,
    required this.message,
    this.subtitle,
    required this.type,
    required this.controller,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    this.onTap,
    required this.onDismiss,
    this.showCloseButton = false,
    this.actionLabel,
    this.onAction,
  });

  IconData _getIcon() {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.cancel;
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.loading:
        return Icons.hourglass_empty;
    }
  }

  Color _getColor() {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF34C759); // iOS green
      case NotificationType.error:
        return const Color(0xFFFF3B30); // iOS red
      case NotificationType.warning:
        return const Color(0xFFFF9500); // iOS orange
      case NotificationType.info:
        return const Color(0xFF007AFF); // iOS blue
      case NotificationType.loading:
        return const Color(0xFF8E8E93); // iOS gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          top: safeAreaTop + 10,
          left: 16,
          right: 16,
          child: Transform.translate(
            offset: Offset(0, slideAnimation.value * 100),
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Opacity(
                opacity: fadeAnimation.value,
                child: _buildNotificationContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationContent() {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -5) {
          onDismiss();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icône animée
                  _buildAnimatedIcon(),

                  const SizedBox(width: 12),

                  // Contenu du message
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                            height: 1.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action button ou close button
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        onAction!();
                        onDismiss();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        backgroundColor: _getColor().withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getColor(),
                        ),
                      ),
                    ),
                  ] else if (showCloseButton || type == NotificationType.loading) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    if (type == NotificationType.loading) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getColor().withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              size: 18,
              color: _getColor(),
            ),
          ),
        );
      },
    );
  }
}

// Extension pour faciliter l'utilisation
extension IOSNotificationExtension on BuildContext {
  void showIOSNotification({
    required String message,
    String? subtitle,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool showCloseButton = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Haptic feedback selon le type
    switch (type) {
      case NotificationType.success:
        HapticFeedback.lightImpact();
        break;
      case NotificationType.error:
        HapticFeedback.mediumImpact();
        break;
      case NotificationType.warning:
        HapticFeedback.mediumImpact();
        break;
      default:
        HapticFeedback.selectionClick();
    }

    // Créer un overlay pour afficher la notification
    final overlay = Overlay.of(this);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => IOSNotificationWrapper(
        message: message,
        subtitle: subtitle,
        type: type,
        duration: duration,
        onTap: onTap,
        showCloseButton: showCloseButton,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          try {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          } catch (e) {
            // Ignorer si déjà supprimé
          }
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  // Méthodes raccourcies
  void showSuccess(String message, {String? subtitle}) {
    showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: NotificationType.success,
    );
  }

  void showError(String message, {String? subtitle}) {
    showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: NotificationType.error,
      duration: const Duration(seconds: 4),
    );
  }

  void showWarning(String message, {String? subtitle}) {
    showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: NotificationType.warning,
    );
  }

  void showInfo(String message, {String? subtitle}) {
    showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: NotificationType.info,
    );
  }

  void showLoading(String message, {String? subtitle}) {
    showIOSNotification(
      message: message,
      subtitle: subtitle,
      type: NotificationType.loading,
      duration: const Duration(seconds: 30), // Long duration for loading
      showCloseButton: true,
    );
  }
}