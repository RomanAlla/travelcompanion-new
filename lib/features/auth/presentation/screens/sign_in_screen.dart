import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelcompanion/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/auth_button_widget.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/social_login_button.dart';
import 'package:travelcompanion/features/auth/presentation/widgets/textfield_widget.dart';
import 'package:travelcompanion/core/error/error_handler.dart';

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
        setState(() {
          _error = null;
        });

        final success = await ref
            .read(authProvider.notifier)
            .signIn(_emailController.text, _passwordController.text);

        if (!mounted) return;

        if (!success) {
          setState(() {
            _error = 'Ошибка входа. Попробуйте еще раз.';
          });
          return;
        }

        context.router.replacePath('/');
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = ErrorHandler.getErrorMessage(e);
          });
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
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[700]?.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[700]?.withOpacity(0.1),
              ),
            ),
          ),
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
                              Icons.travel_explore,
                              size: 48,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Добро пожаловать!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Войдите, чтобы продолжить планировать путешествия',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
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
                                prefixIcon: Icon(Icons.mail),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Пожалуйста, введите email';
                                  }
                                  return null;
                                },
                                controller: _emailController,
                              ),
                              const Divider(height: 1),
                              TextFieldWidget(
                                obscureText: !_isPasswordVisible,
                                labelText: 'Пароль',
                                hintText: 'Введите ваш пароль',
                                prefixIcon: Icon(Icons.password_outlined),
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
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Забыли пароль?',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
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
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignUp,
                              child: Text(
                                'Зарегистрироваться',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
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
