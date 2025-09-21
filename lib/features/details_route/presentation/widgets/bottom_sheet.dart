import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcompanion/core/error/error_handler.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/average_user_routes_rating.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_count_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comments_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/user_routes_count_provider.dart';
import 'package:travelcompanion/features/route_builder/data/models/route_model.dart';

class BottomSheetWidget extends ConsumerStatefulWidget {
  final RouteModel route;
  const BottomSheetWidget({super.key, required this.route});

  @override
  ConsumerState<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends ConsumerState<BottomSheetWidget> {
  int _rating = 0;
  final _textController = TextEditingController();
  List<String> _coverImagePaths = [];
  String? _error;

  Future<void> createComment() async {
    final rep = ref.read(commentRepositoryProvider);
    final user = ref.watch(authProvider).user;

    try {
      if (_rating == 0 || _textController.text.isEmpty) {
        setState(() {
          _error = 'Заполните все данные';
        });
        return;
      }
      List<String> imageUrls = [];
      if (_coverImagePaths.isNotEmpty) {
        final files = _coverImagePaths.map((path) => File(path)).toList();
        final uploadedUrls = await rep.updateCommentImages(
          files: files,
          routeId: widget.route.id,
        );
        if (uploadedUrls != null) {
          imageUrls = uploadedUrls;
        }
      }
      await rep.addComment(
        creatorId: user!.id,
        routeId: widget.route.id,
        text: _textController.text,
        images: imageUrls.isNotEmpty ? imageUrls : null,
        rating: _rating,
      );
      ref.invalidate(commentsProvider(widget.route.id));
      ref.invalidate(commentsCountProvider(widget.route.id));
      ref.invalidate(userRoutesCountProvider(widget.route.creatorId));
      ref.invalidate(averageUserRoutesRatingProvider(widget.route.creatorId));

      if (mounted) {
        context.router.pop();
      }
    } catch (e) {
      ErrorHandler.getErrorMessage(e);
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (context) {
        return PickPhotoBottomSheet(
          coverImagePaths: _coverImagePaths,
          onUpload: (selectedPaths) {
            setState(() {
              _coverImagePaths = selectedPaths;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 60,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Text(
            widget.route.name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text('Адрес', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _textController,
            autofocus: true,
            maxLines: 4,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'Напишите отзыв',
              fillColor: Colors.grey[100],
              filled: true,
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
            ),
          ),
          SizedBox(height: 5),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
          SizedBox(height: 5),
          Wrap(
            children: [
              Text(
                'Были здесь? Поставьте оценку и поделитесь впечатлениями',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: showBottomSheet,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 50,
                  width: 158,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.lightBlueAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 25, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Добавить Фото',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: createComment,
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Container(
                    height: 50,
                    width: 127,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blueAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 25, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Отправить',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
          SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: _coverImagePaths.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _coverImagePaths.length,
                    itemBuilder: (context, index) {
                      final image = _coverImagePaths[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: SizedBox(
                          height: 60,
                          width: 80,
                          child: Image.file(
                            File(image),
                            fit: BoxFit.cover,
                            width: 80,
                            height: 60,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class PickPhotoBottomSheet extends StatefulWidget {
  final List<String> coverImagePaths;
  final void Function(List<String> selected)? onUpload;
  const PickPhotoBottomSheet({
    super.key,
    required this.coverImagePaths,
    this.onUpload,
  });

  @override
  State<PickPhotoBottomSheet> createState() => _PickPhotoBottomSheetState();
}

class _PickPhotoBottomSheetState extends State<PickPhotoBottomSheet> {
  Set<int> selectedIndexes = {};
  List<String> localImagePaths = [];

  @override
  void initState() {
    super.initState();
    localImagePaths = List.from(widget.coverImagePaths);
  }

  void closeBottomSheet(BuildContext context) {
    context.router.pop();
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        localImagePaths = images.map((image) => image.path).toList();
        selectedIndexes.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedIndexes.isNotEmpty;
    return Container(
      height: MediaQuery.of(context).size.height / 3.8,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              SizedBox(width: 20),
              Text('Выбор фото', style: AppTheme.bodyMediumBold),
              Spacer(),
              GestureDetector(
                onTap: () => closeBottomSheet(context),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(Icons.close),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: localImagePaths.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: localImagePaths.length,
                    itemBuilder: (context, index) {
                      final image = localImagePaths[index];
                      final isSelected = selectedIndexes.contains(index);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Container(
                            height: 60,
                            width: 80,
                            decoration: BoxDecoration(color: Colors.black),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    File(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  bottom: 6,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white.withOpacity(0.7),
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text('Нет выбранных фото')),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: hasSelection
                ? () {
                    final selectedPaths = selectedIndexes
                        .map((i) => localImagePaths[i])
                        .toList();
                    if (widget.onUpload != null) {
                      widget.onUpload!(selectedPaths);
                    }
                    context.router.pop();
                  }
                : pickImages,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: hasSelection
                    ? AppTheme.primaryLightColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSelection ? Icons.cloud_upload : Icons.image,
                    color: hasSelection ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    hasSelection
                        ? 'Загрузить (${selectedIndexes.length})'
                        : 'Выбрать из галереи',
                    style: AppTheme.bodyMediumBold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
