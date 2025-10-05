import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

@RoutePage()
class PointDescriptionScreen extends ConsumerStatefulWidget {
  final LatLng selectedPoint;
  const PointDescriptionScreen({super.key, required this.selectedPoint});

  @override
  ConsumerState<PointDescriptionScreen> createState() =>
      _PointDescriptionScreenState();
}

class _PointDescriptionScreenState
    extends ConsumerState<PointDescriptionScreen> {
  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Добавить детали точки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Название точки',
                labelText: 'Название',
                labelStyle: TextStyle(color: Colors.black87),
                hintStyle: TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Описание точки',
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.black87),
                hintStyle: TextStyle(color: Colors.black54),
              ),
              maxLines: 3,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите название точки')),
                  );
                  return;
                }
              },
              child: const Text('Сохранить точку'),
            ),
          ],
        ),
      ),
    );
  }
}
