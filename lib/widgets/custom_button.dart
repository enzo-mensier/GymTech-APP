import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  const CustomButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.isSecondary = false,
  });

  const CustomButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
  }) : isSecondary = true;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.contrastColor : AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        text,
        style: AppTextStyles.semiBold.copyWith(
          color: AppColors.backgroundColor,
          fontSize: 16,
        ),
      ),
    );
  }
}