import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/main/presentation/providers/routes_filter_provider.dart';

class ChoiceChipBuilderWidget extends ConsumerStatefulWidget {
  const ChoiceChipBuilderWidget({super.key});

  @override
  ConsumerState<ChoiceChipBuilderWidget> createState() =>
      _ChoiceChipBuilderWidgetState();
}

class _ChoiceChipBuilderWidgetState
    extends ConsumerState<ChoiceChipBuilderWidget> {
  String _selectedCategory = 'Все';

  List<String> categoryList = ['Все', 'Созданные'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              chipAnimationStyle: ChipAnimationStyle(
                enableAnimation: AnimationStyle.noAnimation,
                selectAnimation: AnimationStyle.noAnimation,
              ),
              side: BorderSide.none,
              label: Text(
                category,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  ref.read(routesFilterProvider.notifier).state = category;
                });
              },
              backgroundColor: AppTheme.lightBlue,
              selectedColor: AppTheme.lightBlue,
              labelStyle: AppTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }
}
