import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/route_builder/presentation/providers/page_controller_provider.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/back_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';

class PrivacyStepScreen extends ConsumerStatefulWidget {
  const PrivacyStepScreen({super.key});

  @override
  ConsumerState<PrivacyStepScreen> createState() => _PrivacyStepScreenState();
}

class _PrivacyStepScreenState extends ConsumerState<PrivacyStepScreen> {
  bool _isPublic = true;
  final List<String> _selectedUsers = [];

  void _togglePrivacy() {
    setState(() {
      _isPublic = !_isPublic;
      if (_isPublic) {
        _selectedUsers.clear();
      }
    });
  }

  void _showUserSelector() async {
    final mockUsers = ['user1@mail.com', 'user2@mail.com', 'user3@mail.com'];

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Выберите пользователей', style: AppTheme.titleSmallBold),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mockUsers.length,
                  itemBuilder: (context, index) {
                    final user = mockUsers[index];
                    final isSelected = _selectedUsers.contains(user);
                    return CheckboxListTile(
                      title: Text(user),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUsers.add(user);
                          } else {
                            _selectedUsers.remove(user);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedUsers),
                    child: const Text('Выбрать'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedUsers.clear();
        _selectedUsers.addAll(selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.white)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 110),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Настройки приватности',
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Кому виден этот маршрут?',
                          style: AppTheme.bodyMediumBold,
                        ),
                        const SizedBox(height: 16),

                        // Переключатель публичности
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.public,
                                  color: _isPublic
                                      ? AppTheme.primaryLightColor
                                      : Colors.grey,
                                ),
                                title: Text(
                                  'Публичный',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: _isPublic
                                        ? AppTheme.primaryLightColor
                                        : Colors.grey,
                                  ),
                                ),
                                trailing: Radio<bool>(
                                  value: true,
                                  groupValue: _isPublic,
                                  onChanged: (_) => _togglePrivacy(),
                                ),
                              ),

                              ListTile(
                                leading: Icon(
                                  Icons.lock,
                                  color: !_isPublic
                                      ? AppTheme.primaryLightColor
                                      : Colors.grey,
                                ),
                                title: Text(
                                  'Приватный',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: !_isPublic
                                        ? AppTheme.primaryLightColor
                                        : Colors.grey,
                                  ),
                                ),
                                subtitle: Text(
                                  'Только для выбранных пользователей',
                                  style: AppTheme.bodyMini.copyWith(
                                    color: AppTheme.grey600,
                                  ),
                                ),
                                trailing: Radio<bool>(
                                  value: false,
                                  groupValue: _isPublic,
                                  onChanged: (_) => _togglePrivacy(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (!_isPublic) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showUserSelector,
                            icon: const Icon(Icons.people),
                            label: Text(
                              _selectedUsers.isEmpty
                                  ? 'Выбрать пользователей'
                                  : 'Выбрано: ${_selectedUsers.length}',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightBlue,
                              foregroundColor: AppTheme.primaryLightColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (_selectedUsers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLightColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedUsers.map((user) {
                                  return Chip(
                                    label: Text(user),
                                    avatar: const Icon(Icons.person, size: 18),
                                    backgroundColor: Colors.white,
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedUsers.remove(user);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],

                        const SizedBox(height: 20),
                        // Индикатор ограниченной видимости
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !_isPublic
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !_isPublic ? Colors.orange : Colors.green,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                !_isPublic ? Icons.lock : Icons.public,
                                color: !_isPublic
                                    ? Colors.orange
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  !_isPublic
                                      ? 'Маршрут будет виден только выбранным пользователям'
                                      : 'Маршрут будет виден всем пользователям',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: !_isPublic
                                        ? Colors.orange.shade800
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                        },
                      ),
                      const SizedBox(height: 10),
                      ContinueActionButtonWidget(
                        label: 'Продолжить',
                        onPressed: () {
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
          ),
        ),
      ],
    );
  }
}
