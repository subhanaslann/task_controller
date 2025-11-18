import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final authResult = await authRepo.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      ref.read(currentUserProvider.notifier).state = authResult.user;
      ref.read(currentOrganizationProvider.notifier).state =
          authResult.organization;

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      setState(() {
        if (errorString.contains('deactivated') &&
            errorString.contains('organization')) {
          _errorMessage =
              'Your organization has been deactivated. Please contact support.';
        } else if (errorString.contains('deactivated') &&
            errorString.contains('account')) {
          _errorMessage =
              'Your account has been deactivated. Contact your team manager.';
        } else {
          _errorMessage = 'Invalid username or password';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo with animation
                  Text(
                    'TekTech',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: colorScheme.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const Gap(48),

                  // Login form card with animation
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          // Username field
                          AppTextField(
                            label: l10n?.usernameOrEmail ?? 'Username or Email',
                            controller: _usernameController,
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n?.validation_required ??
                                    'This field is required';
                              }
                              return null;
                            },
                          ),
                          const Gap(16),

                          // Password field
                          AppTextField(
                            label: l10n?.password ?? 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n?.validation_required ??
                                    'This field is required';
                              }
                              return null;
                            },
                          ),
                          const Gap(24),

                          // Error message
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: AppRadius.borderRadiusSM,
                                border: Border.all(
                                  color: colorScheme.error.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                          ],

                          // Login button
                          AppButton(
                            text: l10n?.login ?? 'Sign In',
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                            isFullWidth: true,
                          ),
                          const Gap(16),

                          // Registration link
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.register),
                              child: Text(
                                'Don\'t have a team? Register here',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
