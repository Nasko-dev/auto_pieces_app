import 'package:flutter/material.dart';
import 'dart:ui';

enum DialogType {
  confirmation,
  warning,
  error,
  info,
}

class IOSDialog extends StatefulWidget {
  final String title;
  final String message;
  final DialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;

  const IOSDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.confirmation,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
  });

  @override
  State<IOSDialog> createState() => _IOSDialogState();
}

class _IOSDialogState extends State<IOSDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.type) {
      case DialogType.confirmation:
        return const Color(0xFF007AFF);
      case DialogType.warning:
        return const Color(0xFFFF9500);
      case DialogType.error:
        return const Color(0xFFFF3B30);
      case DialogType.info:
        return const Color(0xFF5AC8FA);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case DialogType.confirmation:
        return Icons.help_outline_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.error:
        return Icons.error_outline_rounded;
      case DialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header avec icône
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                            child: Column(
                              children: [
                                // Icône animée
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: _getColor().withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getIcon(),
                                          color: _getColor(),
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Titre
                                Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D1D1F),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Message
                                Text(
                                  widget.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Séparateur
                          Container(
                            height: 0.5,
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                          // Boutons
                          SizedBox(
                            height: 52,
                            child: Row(
                              children: [
                                // Bouton Annuler
                                if (widget.cancelText != null)
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          await _controller.reverse();
                                          if (context.mounted) {
                                            Navigator.of(context).pop(false);
                                          }
                                          widget.onCancel?.call();
                                        },
                                        child: Center(
                                          child: Text(
                                            widget.cancelText!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                // Séparateur vertical
                                if (widget.cancelText != null && widget.confirmText != null)
                                  Container(
                                    width: 0.5,
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                // Bouton Confirmer
                                if (widget.confirmText != null)
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          await _controller.reverse();
                                          if (context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                          widget.onConfirm?.call();
                                        },
                                        child: Center(
                                          child: Text(
                                            widget.confirmText!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: widget.type == DialogType.error
                                                  ? const Color(0xFFFF3B30)
                                                  : _getColor(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Extension pour faciliter l'utilisation
extension IOSDialogExtension on BuildContext {
  Future<bool?> showIOSDialog({
    required String title,
    required String message,
    DialogType type = DialogType.confirmation,
    String? confirmText = 'Confirmer',
    String? cancelText = 'Annuler',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => IOSDialog(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // Méthodes raccourcies
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return showIOSDialog(
      title: title,
      message: message,
      type: DialogType.confirmation,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  Future<bool?> showWarningDialog({
    required String title,
    required String message,
    String confirmText = 'Continuer',
    String cancelText = 'Annuler',
  }) {
    return showIOSDialog(
      title: title,
      message: message,
      type: DialogType.warning,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  Future<bool?> showErrorDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return showIOSDialog(
      title: title,
      message: message,
      type: DialogType.error,
      confirmText: confirmText,
      cancelText: null,
    );
  }

  Future<bool?> showInfoDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
  }) {
    return showIOSDialog(
      title: title,
      message: message,
      type: DialogType.info,
      confirmText: confirmText,
      cancelText: null,
    );
  }
}