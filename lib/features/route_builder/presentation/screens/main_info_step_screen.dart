import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart'
    show pageControllerProvider;
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/form_validator.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/text_field_widget.dart';

class MainInfoStepScreen extends ConsumerStatefulWidget {
  final int initialDuration;
  const MainInfoStepScreen({super.key, this.initialDuration = 90});

  @override
  ConsumerState<MainInfoStepScreen> createState() => _MainInfoStepScreenState();
}

class _MainInfoStepScreenState extends ConsumerState<MainInfoStepScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late int duration;
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void initState() {
    duration = widget.initialDuration;
    super.initState();
  }

  void saveMainInfo(WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;
    ref.read(routeBuilderNotifierProvider.notifier)
      ..setName(_nameController.text)
      ..setDescription(_descriptionController.text)
      ..setDuration(int.parse(_durationController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext contex) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.white)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Основная информация',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),

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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputDataFieldWidget(
                              validator: (value) =>
                                  FormValidator.validateRequired(
                                    value,
                                    fieldName: 'название ',
                                  ),
                              controller: _nameController,
                              label: 'Название маршрута',
                            ),
                            const SizedBox(height: 16),
                            InputDataFieldWidget(
                              maxLines: 4,
                              controller: _descriptionController,
                              validator: (value) =>
                                  FormValidator.validateRequired(
                                    value,
                                    fieldName: 'описание ',
                                  ),
                              label: 'Описание маршрута',
                            ),
                            const SizedBox(height: 16),
                            InputDataFieldWidget(
                              controller: _durationController,
                              label: 'Время прохождения (в минутах)',
                              inputFormatter: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) =>
                                  FormValidator.validatePositiveNumber(value),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        const SizedBox(height: 10),
                        ContinueActionButtonWidget(
                          label: 'Готово',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(pageControllerProvider)
                                  .nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                              saveMainInfo(ref);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
