import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/common_button_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/save_changes_button.dart';

class SetAvatarBottomSheetWidget extends ConsumerStatefulWidget {
  const SetAvatarBottomSheetWidget({super.key});

  @override
  ConsumerState<SetAvatarBottomSheetWidget> createState() =>
      _SetAvatarBottomSheetWidgetState();
}

class _SetAvatarBottomSheetWidgetState
    extends ConsumerState<SetAvatarBottomSheetWidget> {
  bool isLoading = false;
  Future<void> pickPhoto(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickMedia();

      await ref.read(userNotifierProvider.notifier).pickAndUploadPhoto(image);
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
        context.router.pop();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
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
                      pickPhoto(context);
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
        ),
        isLoading
            ? SizedBox(child: Center(child: CircularProgressIndicator()))
            : SizedBox.shrink(),
      ],
    );
  }
}
