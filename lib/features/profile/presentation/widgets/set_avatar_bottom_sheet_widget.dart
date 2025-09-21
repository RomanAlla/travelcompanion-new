import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/common_button_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/save_changes_button.dart';

class SetAvatarBottomSheetWidget extends ConsumerWidget {
  const SetAvatarBottomSheetWidget({super.key});

  Future<void> pickPhoto(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).pickAndUploadPhoto();
      if (context.mounted) {
        context.router.pop();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionButtonWidget(
                onPressed: () {},
                backgroundColor: AppTheme.primaryLightColor,
                text: 'Сделать фото',
              ),
              SizedBox(height: 10),
              ActionButtonWidget(
                onPressed: () async {
                  pickPhoto(ref, context);
                },
                backgroundColor: AppTheme.primaryLightColor,
                text: 'Выбрать из библиотеки',
              ),
              SizedBox(height: 10),
              CommonButtonWidget(
                onPressed: () => context.router.pop(context),
                text: 'Отмена',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
