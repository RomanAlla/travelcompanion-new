import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/map/presentation/providers/route_pick_controller.dart';

import 'package:travelcompanion/features/profile/presentation/screens/route_pick_step_widget.dart';
import 'package:travelcompanion/main.dart';

@RoutePage()
class CreateRouteScreen extends ConsumerStatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  ConsumerState<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends ConsumerState<CreateRouteScreen>
    with RouteAware {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const int _totalSteps = 6;

  void _next() {
    if (_currentPage < _totalSteps - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.ease,
      );
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.ease,
      );
    }
  }

  @override
  void didPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(routePickControllerProvider.notifier).reset();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: const [
              RoutePickStepWidget(),
              MainInfoStep(),
              PhotoStep(),
              PointsStep(),
              TipsStep(),
              ConfirmStep(),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.route, color: AppTheme.primaryLightColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalSteps,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryLightColor,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${_currentPage + 1}/$_totalSteps',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.5 - 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: _prev,
                    child: Container(
                      width: 40,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(2, 0),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_left, color: Color(0xFF6C5CE7)),
                    ),
                  ),
                if (_currentPage < _totalSteps - 1)
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 40,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(0xFF6C5CE7).withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainInfoStep extends StatelessWidget {
  const MainInfoStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон
        Positioned.fill(child: Container(color: Colors.white)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF6C5CE7), size: 60),
                const SizedBox(height: 24),
                const Text(
                  'Основная информация',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 340,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Название маршрута',
                          prefixIcon: Icon(Icons.edit_location_alt_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Описание маршрута',
                          prefixIcon: Icon(Icons.notes_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items:
                            [
                                  'Тропики',
                                  'Острова',
                                  'Пещеры',
                                  'Горы',
                                  'Города',
                                  'Пляжи',
                                  'Природа',
                                  'История',
                                ]
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- ШАГ 3: Фото ---
class PhotoStep extends StatelessWidget {
  const PhotoStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Галерея на весь экран (заглушка)
        Positioned.fill(
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Text(
                'Тут будет галерея фото',
                style: TextStyle(color: Colors.grey, fontSize: 22),
              ),
            ),
          ),
        ),
        // FAB для добавления фото
        Positioned(
          bottom: 120,
          right: 32,
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: Color(0xFF6C5CE7),
            icon: Icon(Icons.add_a_photo_outlined),
            label: Text('Добавить фото'),
          ),
        ),
      ],
    );
  }
}

// --- ШАГ 4: Интересные точки ---
class PointsStep extends StatelessWidget {
  const PointsStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Карта на весь экран (заглушка)
        Positioned.fill(
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                'Тут будет карта с точками',
                style: TextStyle(color: Colors.grey, fontSize: 22),
              ),
            ),
          ),
        ),
        // Bottom sheet со списком точек
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Color(0xFF6C5CE7)),
                    SizedBox(width: 8),
                    Text(
                      'Интересные точки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Тут будет список точек',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Добавить точку'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- ШАГ 5: Советы ---
class TipsStep extends StatelessWidget {
  const TipsStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон
        Positioned.fill(child: Container(color: Colors.grey[100])),
        // Bottom sheet со списком советов
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFF6C5CE7)),
                    SizedBox(width: 8),
                    Text(
                      'Советы путешественникам',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Тут будет список советов',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Добавить совет'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- ШАГ 6: Подтверждение ---
class ConfirmStep extends StatelessWidget {
  const ConfirmStep({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Фон
        Positioned.fill(child: Container(color: Colors.white)),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF6C5CE7),
                  size: 60,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Проверьте и подтвердите маршрут',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Тут будет итоговая информация',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.save_alt),
                  label: Text('Сохранить маршрут'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
