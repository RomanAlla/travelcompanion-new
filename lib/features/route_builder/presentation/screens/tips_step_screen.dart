import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/domain/entities/tip_model.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/text_field_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/tip_widget.dart';

class TipsStepScreen extends ConsumerStatefulWidget {
  const TipsStepScreen({super.key});

  @override
  ConsumerState<TipsStepScreen> createState() => _TipsStepScreenState();
}

class _TipsStepScreenState extends ConsumerState<TipsStepScreen> {
  final List<TipModel> tips = [];

  final _tipController = TextEditingController();

  void saveTips() {
    ref.read(routeBuilderNotifierProvider.notifier).setTips(tips);
  }

  void deleteTip(index) {
    setState(() {
      tips.removeAt(index);
    });
  }

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 50),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Текущие советы', style: AppTheme.titleMediumBold),
                  SizedBox(height: 20),
                  tips.isNotEmpty
                      ? Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
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
                        )
                      : SizedBox(),
                  SizedBox(height: 15),
                  InputDataFieldWidget(
                    controller: _tipController,
                    label: 'Введите совет',
                    maxLines: 4,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _tipController.text.trim();

                        setState(() {
                          tips.add(TipModel(description: text));
                          _tipController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLightColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Добавить',
                          style: AppTheme.bodyMediumBold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                ContinueActionButtonWidget(
                  label: 'Завершить',
                  onPressed: () {
                    if (tips.isNotEmpty) {
                      saveTips();
                    }
                    ref
                        .read(pageControllerProvider)
                        .nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
