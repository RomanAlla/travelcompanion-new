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
                                  color: AppTheme.primaryLightColor.withOpacity(
                                    0.2,
                                  ),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.travel_explore,
                              size: 48,
                              color: AppTheme.primaryLightColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Добро пожаловать!',
                          style: AppTheme.headLineSmall.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Войдите, чтобы продолжить планировать путешествия',
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
                                'или войдите через email',
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
                              obscureText: false,

                              onTogglePasswordVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              labelText: 'Логин',
                              hintText: 'Введите ваш логин',
                              prefixIcon: Icon(
                                Icons.mail,
                                color: AppTheme.grey600,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите email';
                                }
                                return null;
                              },
                              controller: _emailController,
                            ),
                            SizedBox(height: 10),
                            TextFieldWidget(
                              obscureText: !_isPasswordVisible,
                              labelText: 'Пароль',
                              hintText: 'Введите ваш пароль',
                              prefixIcon: Icon(
                                Icons.password_outlined,
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Забыли пароль?',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryLightColor,
                              ),
                            ),
                          ),
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
                        AuthButtonWidget(text: 'Войти', onPressed: _signIn),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Нет аккаунта?',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.grey600,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignUp,
                              child: Text(
                                'Зарегистрироваться',
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
