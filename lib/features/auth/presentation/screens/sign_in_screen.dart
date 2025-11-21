import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/core/domain/exceptions/error_handler.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/moderation/presentation/screens/admin_hub_screen.dart';
import 'package:travelcompanion/features/moderation/presentation/screens/moderator_hub_screen.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/auth_button_widget.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/textfield_widget.dart';

@RoutePage()
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;
  bool _isPasswordVisible = false;
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _error = null);

        final success = await ref
            .read(authProvider.notifier)
            .signIn(_emailController.text, _passwordController.text);

        if (!mounted) return;

        if (!success) {
          setState(() => _error = 'Ошибка входа. Попробуйте еще раз.');
          return;
        }

        context.router.replacePath('/');
      } catch (e) {
        if (mounted) {
          setState(() => _error = ErrorHandler.getErrorMessage(e));
        }
      }
    }
  }

  void _navigateToSignUp() {
    context.router.pushPath('/sign-up');
  }

  @override
  Widget build(BuildContext context) {
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
                          Icons.travel_explore_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Заголовок
                    Text(
                      'Добро пожаловать',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Войдите, чтобы продолжить',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Поля ввода
                    TextFieldWidget(
                      obscureText: false,
                      onTogglePasswordVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
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
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      obscureText: !_isPasswordVisible,
                      labelText: 'Пароль',
                      hintText: 'Введите ваш пароль',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.grey600,
                      ),
                      isPassword: true,
                      onTogglePasswordVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите пароль';
                        }
                        return null;
                      },
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 12),
                    // Забыли пароль
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Забыли пароль?',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                        ),
                      ),
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
                    const SizedBox(height: 24),
                    // Кнопка входа
                    AuthButtonWidget(text: 'Войти', onPressed: _signIn),
                    const SizedBox(height: 24),
                    // Регистрация
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет аккаунта? ',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSignUp,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            'Зарегистрироваться',
                            style: AppTheme.bodyMediumBold.copyWith(
                              color: AppTheme.primaryLightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Кнопки для модерации (более сдержанные)
                    Center(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModeratorHubScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Для модерации',
                              style: AppTheme.bodyMini.copyWith(
                                color: AppTheme.grey600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminHubScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Для администрации',
                              style: AppTheme.bodyMini.copyWith(
                                color: AppTheme.grey600,
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
          ),
        ),
      ),
    );
  }
}
