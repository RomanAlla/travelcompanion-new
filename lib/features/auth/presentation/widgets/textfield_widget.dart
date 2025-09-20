import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

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
        hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
        prefixIcon: prefixIcon,
        prefixStyle: TextStyle(color: AppTheme.primaryLightColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: onTogglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
