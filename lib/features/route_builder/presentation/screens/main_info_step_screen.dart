import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart'
    show pageControllerProvider;
import 'package:travelcompanion/features/route_builder/presentation/providers/route_builder_notifier.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/core/domain/validators/form_validator.dart';
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
    super.initState();
    duration = widget.initialDuration;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
              // Заголовок
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryLightColor.withValues(alpha: 0.2),
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
                        Icons.edit_note_rounded,
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
                            'Основная информация',
                            style: AppTheme.titleSmallBold.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Заполните данные о маршруте',
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
              // Форма
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_rounded,
                              color: AppTheme.primaryLightColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Детали маршрута',
                            style: AppTheme.titleSmallBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFieldLabel('Название маршрута'),
                      const SizedBox(height: 6),
                            InputDataFieldWidget(
                              validator: (value) =>
                                  FormValidator.validateRequired(
                                    value,
                                    fieldName: 'название ',
                                  ),
                              controller: _nameController,
                        label: 'Введите название',
                            ),
                            const SizedBox(height: 16),
                      _buildFieldLabel('Описание маршрута'),
                      const SizedBox(height: 6),
                            InputDataFieldWidget(
                              maxLines: 4,
                              controller: _descriptionController,
                              validator: (value) =>
                                  FormValidator.validateRequired(
                                    value,
                                    fieldName: 'описание ',
                                  ),
                        label: 'Расскажите о маршруте',
                            ),
                            const SizedBox(height: 16),
                      _buildFieldLabel('Время прохождения'),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextFormField(
                              controller: _durationController,
                          inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) =>
                                  FormValidator.validatePositiveNumber(value),
                          style: AppTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'В минутах (например: 90)',
                            hintStyle: AppTheme.hintStyle,
                            prefixIcon: Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.primaryLightColor,
                              size: 20,
                            ),
                            suffixText: 'минут',
                            suffixStyle: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              // Кнопки навигации
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
                            onTap: () {
                            if (_formKey.currentState!.validate()) {
                              ref
                                  .read(pageControllerProvider)
                                  .nextPage(
                                      duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                              saveMainInfo(ref);
                            }
                          },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Продолжить',
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
            ),
          ),
        ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTheme.bodySmallBold.copyWith(
        color: Colors.black87,
      ),
    );
  }
}
