import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travelcompanion/core/presentation/router/router.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/core/domain/validators/form_validator.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/features/auth/presentation/providers/user_notifier_provider.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/country_sheet.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/set_avatar_bottom_sheet_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/text_field_widget.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _countryController = TextEditingController();
  final _searchController = TextEditingController();
  List<String> countries = [];
  final _formKey = GlobalKey<FormState>();
  Color _buttonColor = Colors.grey;
  bool isLoading = false;
  String? pickedPhotoPath;

  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    final userData = ref.read(userNotifierProvider).user;

    _nameController.text = userData?.name ?? '';
    _emailController.text = userData?.email ?? '';
    _numberController.text = userData?.phoneNumber ?? '';
    _countryController.text = userData?.country ?? '';
    _nameController.addListener(changeColor);
    _emailController.addListener(changeColor);
    _numberController.addListener(changeColor);
    _countryController.addListener(changeColor);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isLoading = true;
        });
        final currentUser = ref.watch(userNotifierProvider).user;
        await ref
            .read(userNotifierProvider.notifier)
            .updateProfile(
              userId: currentUser!.id,
              name: _nameController.text,
              country: _countryController.text,
              email: _emailController.text,
              phoneNumber: _numberController.text,
            );
        Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          context.router.pushAndPopUntil(
            ProfileRoute(),
            predicate: (route) => false,
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void showCountryPickSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CountrySheet(
          onSelectedCountry: (country) {
            setState(() {
              _countryController.text = country;
            });
          },
          ),
        );
      },
    );
  }

  void changeColor() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _buttonColor = AppTheme.primaryLightColor;
      });
    }
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _buttonColor = AppTheme.lightGrey;
      });
    }
  }

  void showBottomSheetWidget() {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SetAvatarBottomSheetWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 60),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryLightColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBarWidget(title: 'Редактировать профиль'),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Аватар
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
                child: Column(
                  children: [
                    Stack(
                children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryLightColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                    child: AvatarWidget(
                      radius: 50,
                      avatarUrl: pickedPhotoPath ?? userData!.avatarUrl,
                    ),
                  ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryLightColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: showBottomSheetWidget,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: showBottomSheetWidget,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: AppTheme.primaryLightColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  userData!.avatarUrl != null
                        ? 'Изменить аватар'
                        : 'Добавить аватар',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.primaryLightColor,
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
              ),
              const SizedBox(height: 20),
              // Форма редактирования
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
                            Icons.person_rounded,
                            color: AppTheme.primaryLightColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Личная информация',
                          style: AppTheme.titleSmallBold.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel('Имя'),
                    const SizedBox(height: 6),
                  InputDataFieldWidget(
                    controller: _nameController,
                    validator: (value) {
                      return FormValidator.validateName(value);
                    },
                  ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Страна'),
                    const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => showCountryPickSheet(context),
                    child: AbsorbPointer(
                      child: InputDataFieldWidget(
                        controller: _countryController,
                      ),
                    ),
                  ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Почта'),
                    const SizedBox(height: 6),
                  InputDataFieldWidget(
                    controller: _emailController,
                    validator: (value) {
                      return FormValidator.validateEmail(value);
                    },
                  ),
                    const SizedBox(height: 16),
                    _buildFieldLabel('Телефон'),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextFormField(
                    inputFormatters: [maskFormatter],
                    controller: _numberController,
                        style: AppTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '+7 (999) 999-99-99',
                      hintStyle: AppTheme.hintStyle,
                          prefixIcon: Icon(
                            Icons.phone_rounded,
                            color: AppTheme.primaryLightColor,
                            size: 20,
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
              const SizedBox(height: 20),
              // Кнопка сохранения
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isLoading
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: _buttonColor == AppTheme.primaryLightColor
                              ? AppTheme.primaryLightColor
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (_buttonColor == AppTheme.primaryLightColor
                                      ? AppTheme.primaryLightColor
                                      : Colors.grey)
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _buttonColor == AppTheme.primaryLightColor
                                ? updateUserInfo
                                : null,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                      ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Сохранить изменения',
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
