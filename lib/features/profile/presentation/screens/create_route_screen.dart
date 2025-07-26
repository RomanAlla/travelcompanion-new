import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:travelcompanion/core/router/router.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/details_route/presentation/widgets/map_display_widget.dart';
import 'package:travelcompanion/features/profile/data/interesting_point_model.dart';
import 'package:travelcompanion/features/routes/presentation/providers/interesting_route_points_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/route_repository_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/routes_list_provider.dart';
import 'package:travelcompanion/features/routes/presentation/providers/tip_repository_provider.dart';

@RoutePage()
class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _coverImagePaths = [];
  LatLng? point;
  final List<Map<String, dynamic>> interestingPoints = [];
  final List<Map<String, dynamic>> tips = [];

  String? _routeType;

  final List<String> _routeTypes = [
    "Тропики",
    "Острова",
    "Пещеры",
    "Горы",
    "Города",
    "Пляжи",
    "Природа",
    "История",
  ];

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _coverImagePaths = images.map((image) => image.path).toList();
      });
    }
  }

  Future<void> createRoute() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _coverImagePaths.isEmpty ||
        point == null) {
      return;
    }
    final user = ref.watch(authProvider).user;
    try {
      final route = await ref
          .read(routeRepositoryProvider)
          .createRoute(
            creatorId: user!.id,
            name: _nameController.text,
            description: _descriptionController.text,
            longitude: point!.longitude,
            latitude: point!.latitude,
            routeType: _routeType,
          );
      if (_coverImagePaths.isNotEmpty) {
        final files = _coverImagePaths.map((path) => File(path)).toList();
        await ref
            .read(routeRepositoryProvider)
            .updateRoutePhotos(files: files, id: route.id);
      }
      if (interestingPoints.isNotEmpty) {
        for (var point in interestingPoints) {
          await ref
              .read(interestingRoutePointsRepositoryProvider)
              .createPoint(
                routeId: route.id,
                name: point['name'],
                description: point['description'],
                latitude: point['point'].latitude,
                longitude: point['point'].longitude,
              );
        }
      }
      if (tips.isNotEmpty) {
        for (var tip in tips) {
          await ref
              .read(tipRepositoryProvider)
              .createTip(
                routeId: route.id,
                name: tip['name'],
                description: tip['description'],
              );
        }
      }

      if (mounted) {
        ref.invalidate(routesListProvider);
        ref.invalidate(userRoutesListProvider);
        context.router.push(UserRoutesRoute());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildRouteTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Категория маршрута',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _routeType,
                isExpanded: true,
                hint: const Text('Выберите категорию'),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF6C5CE7),
                ),
                items: _routeTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getIconForRouteType(type),
                          color: const Color(0xFF6C5CE7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(type),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _routeType = value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForRouteType(String type) {
    switch (type) {
      case "Тропики":
        return Icons.wb_sunny_outlined;
      case "Острова":
        return Icons.beach_access_outlined;
      case "Пещеры":
        return Icons.terrain_outlined;
      case "Горы":
        return Icons.landscape_outlined;
      case "Города":
        return Icons.location_city_outlined;
      case "Пляжи":
        return Icons.beach_access_outlined;
      case "Природа":
        return Icons.park_outlined;
      case "История":
        return Icons.history_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Создать маршрут',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _coverImagePaths.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Добавить фотографии',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: _coverImagePaths.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Image.file(
                                    File(_coverImagePaths[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _coverImagePaths.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Основная информация',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Название маршрута',
                        prefixIcon: const Icon(
                          Icons.edit_location_alt_rounded,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: 'Описание маршрута',
                        prefixIcon: const Icon(
                          Icons.notes_rounded,
                          color: Colors.black87,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRouteTypeSelector(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: pointContainer(context),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: tipsContainer(context),
              ),
              const SizedBox(height: 20),
              MapDisplayWidget(
                marker: point != null
                    ? Marker(
                        point: point!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      )
                    : null,
                onPointSelected: (selectedPoint) {
                  setState(() {
                    point = selectedPoint;
                  });
                },
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: createRoute,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Сохранить маршрут',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget pointContainer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Интересные точки маршрута',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await context.router
                    .push<InterestingPointModel?>(InterestingPointsMapRoute());
                if (result != null) {
                  setState(() {
                    interestingPoints.add({
                      'name': result.name,
                      'description': result.description,
                      'point': result.point,
                    });
                  });
                }
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
              label: const Text(
                'Добавить',
                style: TextStyle(color: Color(0xFF6C5CE7)),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (interestingPoints.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 32,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Добавьте интересные места',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Отметьте на карте важные точки вашего маршрута',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: interestingPoints.length,
            itemBuilder: (context, index) {
              final point = interestingPoints[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      title: Text(
                        point['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        point['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF6C5CE7),
                            ),
                            onPressed: () => _showEditPointDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deletePoint(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget tipsContainer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Советы путешественникам',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTipDialog(),
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
              label: const Text(
                'Добавить',
                style: TextStyle(color: Color(0xFF6C5CE7)),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (tips.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 32,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Добавьте полезные советы',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Поделитесь своим опытом и помогите другим путешественникам',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF6C5CE7),
                        ),
                      ),
                      title: Text(
                        tip['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        tip['description'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF6C5CE7),
                            ),
                            onPressed: () => _showEditTipDialog(index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteTip(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showEditTipDialog(int index) {
    final tip = tips[index];
    final nameController = TextEditingController(text: tip['name']);
    final descriptionController = TextEditingController(
      text: tip['description'],
    );
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Редактировать точку',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    prefixIcon: Icon(Icons.title, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Описание',
                    prefixIcon: Icon(Icons.description, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Отмена'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          setState(() {
                            tips[index] = {
                              ...tip,
                              'name': nameController.text,
                              'description': descriptionController.text,
                            };
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Сохранить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditPointDialog(int index) {
    final point = interestingPoints[index];
    final nameController = TextEditingController(text: point['name']);
    final descriptionController = TextEditingController(
      text: point['description'],
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Редактировать точку',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Название',
                  prefixIcon: Icon(Icons.title, color: Colors.black87),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.description, color: Colors.black87),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          interestingPoints[index] = {
                            ...point,
                            'name': nameController.text,
                            'description': descriptionController.text,
                          };
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Сохранить'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePoint(int index) {
    setState(() {
      interestingPoints.removeAt(index);
    });
  }

  void _deleteTip(int index) {
    setState(() {
      tips.removeAt(index);
    });
  }

  void _showAddTipDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Новый совет',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Заголовок совета',
                  hintText: 'Например: Лучшее время для посещения',
                  prefixIcon: const Icon(Icons.title, color: Color(0xFF6C5CE7)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Описание совета',
                  hintText: 'Подробно опишите ваш совет...',
                  prefixIcon: const Icon(
                    Icons.description,
                    color: Color(0xFF6C5CE7),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Отмена',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          tips.add({
                            'name': nameController.text,
                            'description': descriptionController.text,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Добавить совет',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
