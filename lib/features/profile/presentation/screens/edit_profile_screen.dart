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
import 'package:travelcompanion/features/profile/presentation/widgets/common_button_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/country_sheet.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/save_changes_button.dart';
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
    final userData = ref.read(userNotifierProvider).user;

    _nameController.text = userData?.name ?? '';
    _emailController.text = userData?.email ?? '';
    _numberController.text = userData?.phoneNumber ?? '';
    _countryController.text = userData?.country ?? '';
    _nameController.addListener(changeColor);

    _emailController.addListener(changeColor);
    _numberController.addListener(changeColor);
    _countryController.addListener(changeColor);
    super.initState();
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
        Future.delayed(Duration(seconds: 1));
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
      builder: (context) {
        return CountrySheet(
          onSelectedCountry: (country) {
            setState(() {
              _countryController.text = country;
            });
          },
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
      builder: (context) {
        return SetAvatarBottomSheetWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userNotifierProvider).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: AppBarWidget(title: 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AvatarWidget(
                      radius: 50,
                      avatarUrl: pickedPhotoPath ?? userData!.avatarUrl,
                    ),
                  ),
                  SizedBox(height: 15),
                  CommonButtonWidget(
                    onPressed: showBottomSheetWidget,
                    text: userData!.avatarUrl != null
                        ? 'Изменить аватар'
                        : 'Добавить аватар',
                  ),
                  SizedBox(height: 20),
                  Text('Имя', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  InputDataFieldWidget(
                    controller: _nameController,
                    validator: (value) {
                      return FormValidator.validateName(value);
                    },
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => showCountryPickSheet(context),
                    child: Text('Страна', style: AppTheme.bodyMedium),
                  ),
                  GestureDetector(
                    onTap: () => showCountryPickSheet(context),
                    child: AbsorbPointer(
                      child: InputDataFieldWidget(
                        controller: _countryController,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  Text('Почта', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  InputDataFieldWidget(
                    controller: _emailController,
                    validator: (value) {
                      return FormValidator.validateEmail(value);
                    },
                  ),
                  SizedBox(height: 15),
                  Text('Телефон', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  TextFormField(
                    inputFormatters: [maskFormatter],
                    controller: _numberController,

                    decoration: InputDecoration(
                      labelStyle: AppTheme.hintStyle,
                      hintText: '+7 (999) 999-99-99',
                      hintStyle: AppTheme.hintStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 232, 243, 248),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ActionButtonWidget(
                        text: 'Сохранить',
                        backgroundColor: _buttonColor,
                        onPressed: () {
                          _buttonColor == AppTheme.primaryLightColor
                              ? updateUserInfo()
                              : null;
                        },
                      ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
