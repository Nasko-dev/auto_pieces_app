import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class SellerSharedWidgets {
  static Widget buildOptionCard({
    required String label,
    required bool selected,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primaryBlue : const Color(0xFFE6E9EF),
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            SizedBox(width: 36, height: 36, child: icon),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF14213D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool enabled = true,
    bool isLoading = false,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? AppTheme.primaryBlue;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }

  static Widget buildGhostButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE6E9EF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          foregroundColor: AppTheme.darkGray,
          backgroundColor: Colors.white,
        ),
        child: Text(label),
      ),
    );
  }

  static Widget buildIcon(IconData iconData) {
    return Icon(iconData, size: 28, color: AppTheme.darkBlue);
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF14213D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6E9EF)),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon:
                  icon != null ? Icon(icon, color: AppTheme.darkGray) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF14213D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildPlateField(TextEditingController controller) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9EF)),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Color(0xFF14213D),
          letterSpacing: 4,
        ),
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          hintText: 'AB-123-CD',
          hintStyle: TextStyle(
            color: Color(0xFFB9CCFF),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
