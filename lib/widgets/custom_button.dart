import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key, 
    this.text,
    this.onPressed,
    this.isSecondary = false,
    this.child,
    this.padding,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  const CustomButton.secondary({
    super.key,
    this.text,
    this.onPressed,
    this.child,
    this.padding,
  }) : isSecondary = true, assert(text != null || child != null);

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
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: child ?? Text(
        text!,
        style: AppTextStyles.semiBold.copyWith(
          color: AppColors.backgroundColor,
          fontSize: 16,
        ),
      ),
    );
  }
}