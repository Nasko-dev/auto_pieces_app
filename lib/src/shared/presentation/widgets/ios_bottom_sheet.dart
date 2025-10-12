import 'package:flutter/material.dart';
import 'dart:ui';

class IOSBottomSheet extends StatefulWidget {
  final Widget child;
  final double? height;
  final bool showHandleBar;
  final bool isDismissible;
  final Color? backgroundColor;

  const IOSBottomSheet({
    super.key,
    required this.child,
    this.height,
    this.showHandleBar = true,
    this.isDismissible = true,
    this.backgroundColor,
  });

  @override
  State<IOSBottomSheet> createState() => _IOSBottomSheetState();
}

class _IOSBottomSheetState extends State<IOSBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: widget.isDismissible ? _dismiss : null,
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.4 * _fadeAnimation.value,
                ),
              ),
            ),

            // Bottom sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(
                  0,
                  mediaQuery.size.height * _slideAnimation.value,
                ),
                child: GestureDetector(
                  onVerticalDragUpdate: widget.isDismissible
                      ? (details) {
                          if (details.delta.dy > 5) {
                            _dismiss();
                          }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    constraints: widget.height != null
                        ? BoxConstraints(maxHeight: widget.height!)
                        : null,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.backgroundColor ??
                                Colors.white.withValues(alpha: 0.95),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Handle bar
                              if (widget.showHandleBar) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Content
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: bottomPadding),
                                  child: widget.child,
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
            ),
          ],
        );
      },
    );
  }
}

// Extension pour faciliter l'utilisation
extension IOSBottomSheetExtension on BuildContext {
  Future<T?> showIOSBottomSheet<T>({
    required Widget child,
    double? height,
    bool showHandleBar = true,
    bool isDismissible = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => IOSBottomSheet(
        height: height,
        showHandleBar: showHandleBar,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }
}
