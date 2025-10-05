import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';

class InputDataFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatter;
  final String? Function(String?)? validator;
  const InputDataFieldWidget({
    super.key,
    required this.controller,
    this.label,
    this.maxLines,
    this.inputFormatter,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      maxLines: maxLines,
      controller: controller,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        labelStyle: AppTheme.hintStyle,
        hintText: label,
        hintStyle: AppTheme.hintStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 232, 243, 248),
      ),
    );
  }
}
