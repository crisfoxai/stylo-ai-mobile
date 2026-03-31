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
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxxl),
                // Logo
                Center(
                  child: Text(
                    'STYLO',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    'Tu estilo, potenciado por IA',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxxl),

                // Social auth buttons
                StyloButton(
                  label: 'Continuar con Google',
                  onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                  variant: StyloButtonVariant.outlined,
                  icon: Icons.g_mobiledata,
                ),
                const SizedBox(height: AppSpacing.md),
                StyloButton(
                  label: 'Continuar con Apple',
                  onPressed: () => ref.read(authNotifierProvider.notifier).signInWithApple(),
                  variant: StyloButtonVariant.primary,
                  icon: Icons.apple,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text('o', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Name fields (only for signup)
                if (!_isLogin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: StyloTextField(
                          controller: _firstNameController,
                          label: 'Nombre',
                          validator: Validators.name,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StyloTextField(
                          controller: _lastNameController,
                          label: 'Apellido',
                          validator: Validators.name,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Email
                StyloTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password
                StyloTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: _obscurePassword,
                  validator: _isLogin ? null : Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Submit button
                StyloButton(
                  label: _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                  onPressed: _submit,
                  isLoading: authState.status == AuthStatus.loading,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Toggle login/signup
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? '¿No tenés cuenta? Registrate' : '¿Ya tenés cuenta? Iniciá sesión',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accent),
                    ),
                  ),
                ),

                // Legal text
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Al continuar, aceptás los Términos y Política de Privacidad',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
