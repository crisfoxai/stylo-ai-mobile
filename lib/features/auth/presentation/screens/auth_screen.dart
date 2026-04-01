import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/stylo_button.dart';
import '../../../../shared/widgets/stylo_text_field.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// BUG-002 fix: Reset form state and clear controllers when toggling modes
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _obscurePassword = true;
    });

    // BUG-001 fix: Scroll to bottom after toggle so the link stays visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_isLogin) {
      notifier.signInWithEmail(_emailController.text.trim(), _passwordController.text);
    } else {
      notifier.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (state.status == AuthStatus.authenticated) {
        if (state.user?.hasStyleProfile == true) {
          context.go('/home');
        } else {
          context.go('/style-quiz');
        }
      }
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxxl),
                // Logo
                Semantics(
                  label: 'STYLO, tu estilo potenciado por IA',
                  header: true,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'STYLO',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.accent,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tu estilo, potenciado por IA',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxxl),

                // Social auth buttons
                Semantics(
                  button: true,
                  label: 'Iniciar sesión con Google',
                  child: StyloButton(
                    label: 'Continuar con Google',
                    onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                    variant: StyloButtonVariant.outlined,
                    icon: Icons.g_mobiledata,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  button: true,
                  label: 'Iniciar sesión con Apple',
                  child: StyloButton(
                    label: 'Continuar con Apple',
                    onPressed: () => ref.read(authNotifierProvider.notifier).signInWithApple(),
                    variant: StyloButtonVariant.primary,
                    icon: Icons.apple,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Divider
                Semantics(
                  label: 'o',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Text('o', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Name fields (only for signup) — BUG-001: AnimatedSize for smooth transition
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _isLogin
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    textField: true,
                                    label: 'Campo de nombre',
                                    child: StyloTextField(
                                      controller: _firstNameController,
                                      label: 'Nombre',
                                      validator: Validators.name,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Semantics(
                                    textField: true,
                                    label: 'Campo de apellido',
                                    child: StyloTextField(
                                      controller: _lastNameController,
                                      label: 'Apellido',
                                      validator: Validators.name,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                ),

                // Email
                Semantics(
                  textField: true,
                  label: 'Campo de email',
                  child: StyloTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password
                Semantics(
                  textField: true,
                  label: 'Campo de contraseña',
                  child: StyloTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    obscureText: _obscurePassword,
                    validator: _isLogin ? null : Validators.password,
                    textInputAction: TextInputAction.done,
                    suffixIcon: Semantics(
                      button: true,
                      label: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                      child: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Submit button
                Semantics(
                  button: true,
                  label: _isLogin ? 'Iniciar sesión con email' : 'Crear cuenta nueva',
                  child: StyloButton(
                    label: _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                    onPressed: _submit,
                    isLoading: authState.status == AuthStatus.loading,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Toggle login/signup
                Center(
                  child: Semantics(
                    button: true,
                    label: _isLogin
                        ? 'Cambiar a modo registro'
                        : 'Cambiar a modo inicio de sesión',
                    child: TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLogin ? '¿No tenés cuenta? Registrate' : '¿Ya tenés cuenta? Iniciá sesión',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),

                // Legal text
                const SizedBox(height: AppSpacing.xxl),
                Semantics(
                  label: 'Al continuar, aceptás los Términos y Política de Privacidad',
                  child: Text(
                    'Al continuar, aceptás los Términos y Política de Privacidad',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
