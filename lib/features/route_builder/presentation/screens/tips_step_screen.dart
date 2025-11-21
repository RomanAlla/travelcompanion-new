import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/domain/entities/tip_model.dart';
import 'package:travelcompanion/core/presentation/providers/gemini_service_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/tip_widget.dart';

class TipsStepScreen extends ConsumerStatefulWidget {
  const TipsStepScreen({super.key});

  @override
  ConsumerState<TipsStepScreen> createState() => _TipsStepScreenState();
}

class _TipsStepScreenState extends ConsumerState<TipsStepScreen> {
  final List<TipModel> tips = [];
  final _tipController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Загружаем существующие советы из состояния
    final routeForm = ref.read(routeBuilderNotifierProvider);
    if (routeForm.tips != null && routeForm.tips!.isNotEmpty) {
      tips.addAll(routeForm.tips!);
    }
  }

  void saveTips() {
    ref.read(routeBuilderNotifierProvider.notifier).setTips(tips);
  }

  void deleteTip(int index) {
    setState(() {
      tips.removeAt(index);
    });
    saveTips();
  }

  Future<void> _generateAITips() async {
    final routeForm = ref.read(routeBuilderNotifierProvider);
    
    if (routeForm.startPoint == null || routeForm.endPoint == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Для генерации советов необходимо выбрать начальную и конечную точки маршрута'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final geminiService = ref.read(geminiServiceProvider);
      final generatedTips = await geminiService.generateRouteTips(
        startPoint: routeForm.startPoint!,
        endPoint: routeForm.endPoint!,
        wayPoints: routeForm.wayPoints,
        routeName: routeForm.name,
        travelDuration: routeForm.travelDuration,
      );

      if (mounted) {
        setState(() {
          // Добавляем только новые советы, избегая дубликатов
          for (final tipText in generatedTips) {
            if (!tips.any((t) => t.description == tipText)) {
              tips.add(TipModel(description: tipText));
            }
          }
          _isGenerating = false;
        });
        saveTips();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Сгенерировано ${generatedTips.length} советов'),
            backgroundColor: AppTheme.primaryLightColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при генерации советов: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _addTip() {
    final text = _tipController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      tips.add(TipModel(description: text));
      _tipController.clear();
    });
    saveTips();
  }

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Советы для маршрута',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте полезные советы или воспользуйтесь AI для автоматической генерации',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка AI генерации
            Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateAITips,
                icon: _isGenerating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 20),
                label: Text(
                  _isGenerating ? 'Генерация советов...' : 'Предложить советы (AI)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLightColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            // Список советов
            Expanded(
              child: tips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Пока нет советов',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте вручную или воспользуйтесь AI',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: tips.length,
                            itemBuilder: (context, index) {
                              final tip = tips[index];
                              return TipWidget(
                                tipText: tip.description,
                                i: index,
                                onPressed: () => deleteTip(index),
                              );
                            },
                          ),
            ),

            // Поле ввода нового совета
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _tipController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Введите совет вручную...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: _tipController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.send, color: AppTheme.primaryLightColor),
                                onPressed: _addTip,
                              )
                            : null,
                        ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (_) => _addTip(),
                    ),
              ),
                  const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ContinueActionButtonWidget(
                        label: 'Далее',
                  onPressed: () {
                    if (tips.isNotEmpty) {
                      saveTips();
                    }
                    ref
                        .read(pageControllerProvider)
                        .nextPage(
                                duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                  },
                ),
              ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
