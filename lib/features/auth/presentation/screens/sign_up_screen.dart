import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/error_handler.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/auth_button_widget.dart';
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
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
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
                    const SizedBox(height: 40),
                    // Логотип
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryLightColor.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Заголовок
                    Text(
                      'Создайте аккаунт',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Зарегистрируйтесь, чтобы начать',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Поля ввода
                    TextFieldWidget(
                      labelText: 'Email',
                      hintText: 'Введите ваш email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppTheme.grey600,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                      controller: _emailController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      obscureText: !_isPasswordVisible,
                      labelText: 'Пароль',
                      hintText: 'Введите пароль',
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
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
                        if (value != _confirmPasswordController.text &&
                            _confirmPasswordController.text.isNotEmpty) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      obscureText: !_isConfirmPasswordVisible,
                      labelText: 'Подтвердите пароль',
                      hintText: 'Подтвердите пароль',
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.grey600,
                      ),
                      onTogglePasswordVisibility: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, подтвердите пароль';
                        }
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                      controller: _confirmPasswordController,
                    ),
                    // Ошибка
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Согласие
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppTheme.primaryLightColor,
                          size: 18,
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
                    // Кнопка регистрации
                    AuthButtonWidget(
                      onPressed: _signUp,
                      text: 'Зарегистрироваться',
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: 24),
                    // Вход
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Уже есть аккаунт? ',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            'Войти',
                            style: AppTheme.bodyMediumBold.copyWith(
                              color: AppTheme.primaryLightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
