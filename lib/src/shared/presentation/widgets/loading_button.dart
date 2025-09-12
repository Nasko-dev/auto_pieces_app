import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isClickable = widget.onPressed != null; // Le bouton reste visuellement actif pendant le loading
    final backgroundColor = widget.isOutlined
        ? Colors.transparent
        : (widget.backgroundColor ?? AppTheme.primaryBlue);
    final textColor = widget.isOutlined
        ? (widget.textColor ?? AppTheme.primaryBlue)
        : (widget.textColor ?? Colors.white);
    final borderColor = widget.isOutlined
        ? (widget.backgroundColor ?? AppTheme.primaryBlue)
        : Colors.transparent;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width ?? double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  color: isClickable ? backgroundColor : Colors.grey.shade300,
                  border: widget.isOutlined
                      ? Border.all(
                          color: isClickable ? borderColor : Colors.grey.shade300,
                          width: 2,
                        )
                      : null,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  boxShadow: !widget.isOutlined && isClickable
                      ? [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled ? widget.onPressed : null,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      child: widget.isLoading
                          ? _buildLoadingContent(textColor)
                          : _buildNormalContent(textColor, isClickable),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingContent(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isOutlined ? AppTheme.primaryBlue : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Chargement...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isOutlined ? AppTheme.primaryBlue : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalContent(Color textColor, bool isClickable) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: isClickable ? textColor : Colors.grey.shade500,
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isClickable ? textColor : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}