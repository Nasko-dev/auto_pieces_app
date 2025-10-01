import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class BecomeSellerSharedWidgets {
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
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: const Color(0xFFB9CCFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
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

  static Widget buildPlateField(TextEditingController controller) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Bande UE bleue
          Container(
            width: 52,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0A4AFF),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: const Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'AA-000-AZ',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF0A4AFF),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}