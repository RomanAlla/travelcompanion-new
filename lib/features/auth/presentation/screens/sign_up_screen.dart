import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/error_handler.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/auth_button_widget.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/social_login_button.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/textfield_widget.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _error = null);

        await ref
            .read(authProvider.notifier)
            .signUp(_emailController.text, _passwordController.text);

        if (!mounted) return;

        context.router.replacePath('/');
      } catch (e) {
        if (mounted) {
          setState(() => _error = ErrorHandler.getErrorMessage(e));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue[700]!.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 48,
                              color: AppTheme.primaryLightColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Создайте аккаунт',
                          style: AppTheme.headLineSmall.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Зарегистрируйтесь, чтобы начать планировать путешествия',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: SocialLoginButton(
                                icon: Icons.g_mobiledata,
                                label: 'Google',
                                onTap: () {},
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: SocialLoginButton(
                                icon: Icons.facebook,
                                label: 'Facebook',
                                onTap: () {},
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: SocialLoginButton(
                                icon: Icons.apple,
                                label: 'Apple',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'или зарегистрируйтесь через email',
                                style: AppTheme.bodyMini.copyWith(
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Column(
                          children: [
                            TextFieldWidget(
                              labelText: 'Логин',
                              hintText: 'Введите логин',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: AppTheme.grey600,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите логин';
                                }
                                return null;
                              },
                              controller: _emailController,
                              obscureText: false,
                            ),
                            SizedBox(height: 10),
                            TextFieldWidget(
                              obscureText: !_isPasswordVisible,
                              labelText: 'Пароль',
                              hintText: 'Введите пароль',
                              isPassword: true,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppTheme.grey600,
                              ),
                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                }
                                if (value.length < 6) {
                                  return 'Пароль должен содержать минимум 6 символов';
                                }
                                if (value != _confirmPasswordController.text) {
                                  return 'Пароли не совпадают';
                                }

                                return null;
                              },
                              controller: _passwordController,
                            ),
                            SizedBox(height: 10),
                            TextFieldWidget(
                              obscureText: !_isConfirmPasswordVisible,
                              labelText: 'Подтвердите пароль',
                              hintText: 'Подтвердите пароль',
                              isPassword: true,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppTheme.grey600,
                              ),
                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите пароль';
                                }
                                if (value.length < 6) {
                                  return 'Пароль должен содержать минимум 6 символов';
                                }
                                return null;
                              },
                              controller: _confirmPasswordController,
                            ),
                          ],
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.primaryLightColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Регистрируясь, вы соглашаетесь с нашими условиями использования и политикой конфиденциальности',
                                style: AppTheme.bodyMini.copyWith(
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AuthButtonWidget(
                          onPressed: _signUp,
                          text: 'Зарегистрироваться',
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Уже есть аккаунт?',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.grey600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Войти',
                                style: AppTheme.bodySmallBold.copyWith(
                                  color: AppTheme.primaryLightColor,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
