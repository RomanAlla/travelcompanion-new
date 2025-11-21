import 'package:flutter/material.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class TextFieldWidget extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Widget prefixIcon;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final void Function()? onTap;
  final bool obscureText;
  final bool isPassword;
  final VoidCallback? onTogglePasswordVisibility;

  const TextFieldWidget({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    required this.controller,
    this.onTap,
    required this.obscureText,
    this.isPassword = false,
    this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.grey600),
        hintStyle: AppTheme.bodySmall.copyWith(color: Colors.grey[400]),
        prefixIcon: prefixIcon,
        prefixStyle: const TextStyle(color: AppTheme.primaryLightColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey[600],
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppTheme.primaryLightColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
