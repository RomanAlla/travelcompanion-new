import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/presentation/widgets/delete_button.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/add_something_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart'
    show ContinueActionButtonWidget;

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
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              imagesList.isNotEmpty
                  ? Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: imagesList.length,
                        itemBuilder: (context, index) {
                          final image = imagesList[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 3,
                                      bottom: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: DeleteButtonWidget(
                                            onPressed: () {
                                              setState(() {
                                                imagesList.removeAt(index);
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Text(
                          'Добавьте фотографии маршрута',
                          style: TextStyle(color: Colors.grey, fontSize: 22),
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  children: [
                    BackActionButtonWidget(
                      label: 'Назад',
                      onPressed: () {
                        ref
                            .read(pageControllerProvider)
                            .previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                      },
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: AddSomethingButtonWidget(onPressed: selectImage),
                    ),
                    SizedBox(width: 20),
                    ContinueActionButtonWidget(
                      label: 'Готово',
                      onPressed: () async {
                        if (imagesList.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text(
                                  'Выберите хотя-бы одно фото',
                                  style: AppTheme.bodyMedium,
                                ),
                              ),
                              backgroundColor: AppTheme.lightGrey,
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(pageControllerProvider)
                            .nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                        setPhotos();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
