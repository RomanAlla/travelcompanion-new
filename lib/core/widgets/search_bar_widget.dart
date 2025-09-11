import 'package:flutter/material.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;
  const SearchBarWidget({super.key, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Поиск',
        prefixIcon: Icon(Icons.search, color: AppTheme.textHintColor, size: 20),
        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textHintColor),
        fillColor: AppTheme.lightBlue,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
