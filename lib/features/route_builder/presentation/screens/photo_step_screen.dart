import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';

class PhotoStepScreen extends ConsumerStatefulWidget {
  const PhotoStepScreen({super.key});

  @override
  ConsumerState<PhotoStepScreen> createState() => _PhotoStepScreenState();
}

class _PhotoStepScreenState extends ConsumerState<PhotoStepScreen> {
  List<String> imagesList = [];
  String? errorMessage;

  void selectImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        imagesList = images.map((image) => image.path).toList();
      });
    }
  }

  void setPhotos() {
    ref.read(routeBuilderNotifierProvider.notifier).setPhotos(imagesList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
          child: Column(
            children: [
            const SizedBox(height: 20),
            // Заголовок
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Фотографии маршрута',
                          style: AppTheme.titleSmallBold.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Добавьте красивые фото',
                          style: AppTheme.bodyMini.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Галерея фотографий
            Expanded(
              child: imagesList.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: imagesList.length,
                        itemBuilder: (context, index) {
                          final image = imagesList[index];
                          return Container(
                              decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              ),
                              child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  // Кнопка удаления
                                    Positioned(
                                    top: 6,
                                    right: 6,
                                      child: Container(
                                        decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                              setState(() {
                                                imagesList.removeAt(index);
                                              });
                                            },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Номер фотографии
                                  Positioned(
                                    bottom: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLightColor.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AppTheme.primaryLightColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Добавьте фотографии',
                              style: AppTheme.titleSmallBold.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Выберите красивые фото вашего маршрута',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Кнопки навигации
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    BackActionButtonWidget(
                      label: 'Назад',
                      onPressed: () {
                        ref
                            .read(pageControllerProvider)
                            .previousPage(
                            duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                      },
                    ),
                  const SizedBox(width: 12),
                    Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryLightColor.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: selectImage,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Добавить фото',
                                    style: AppTheme.bodySmallBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: imagesList.isNotEmpty
                          ? AppTheme.successColor
                          : Colors.grey[400]!,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (imagesList.isNotEmpty
                                  ? AppTheme.successColor
                                  : Colors.grey)
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: imagesList.isNotEmpty
                            ? () async {
                        if (imagesList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                      content: const Text(
                                  'Выберите хотя-бы одно фото',
                                  style: AppTheme.bodyMedium,
                                ),
                                      backgroundColor: AppTheme.lightGrey,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(pageControllerProvider)
                            .nextPage(
                                      duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                        setPhotos();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18,
                    ),
                              const SizedBox(width: 6),
                              Text(
                                'Готово',
                                style: AppTheme.bodySmallBold.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                ),
              ),
            ],
          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
