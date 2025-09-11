import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:travelcompanion/core/theme/app_theme.dart';
import 'package:travelcompanion/core/widgets/app_bar.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/profile/data/api/countries_api.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/avatar_widget.dart';
import 'package:travelcompanion/features/profile/presentation/widgets/country_sheet.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/continue_action_button_widget.dart';
import 'package:travelcompanion/features/route_builder/presentation/widgets/text_field_widget.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _countryController = TextEditingController();
  final _searchController = TextEditingController();
  List<String> countries = [];

  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> updateUserInfo() async {
    final currentUser = ref.watch(authProvider).user;
    await ref
        .read(authServiceProvider)
        .updateUserProfile(userId: currentUser!.id, name: _nameController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 50),
        child: AppBarWidget(title: 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AvatarWidget(),

              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Имя', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  InputDataFieldWidget(controller: _nameController),
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
                  Text('Доп. информация', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  InputDataFieldWidget(controller: _bioController, maxLines: 3),
                  SizedBox(height: 15),
                  Text('Почта', style: AppTheme.bodyMedium),
                  SizedBox(height: 5),
                  InputDataFieldWidget(controller: _emailController),
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
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: ContinueActionButtonWidget(
                      onPressed: () {},
                      label: 'Сохранить',
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
