import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _companyNameController.dispose();
    _teamNameController.dispose();
    _managerNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Has lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // Has uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // Has digit
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // Has special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength < 0.3) return AppColors.error;
    if (_passwordStrength < 0.6) return AppColors.warning;
    if (_passwordStrength < 0.8) return AppColors.info;
    return AppColors.success;
  }

  String _getPasswordStrengthText() {
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Fair';
    if (_passwordStrength < 0.8) return 'Good';
    return 'Strong';
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final authResult = await authRepo.register(
        companyName: _companyNameController.text.trim(),
        teamName: _teamNameController.text.trim(),
        managerName: _managerNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      ref.read(currentUserProvider.notifier).state = authResult.user;
      ref.read(currentOrganizationProvider.notifier).state =
          authResult.organization;
      
      // Invalidate auth state to ensure router redirects correctly
      ref.invalidate(isLoggedInProvider);

      // CRITICAL FIX: Wait for state to stabilize before navigation
      // This ensures:
      // 1. Provider state has fully propagated
      // 2. Database transaction is fully committed and visible
      // 3. Token is confirmed saved to secure storage
      // Without this delay, home screen may load before organization
      // is visible in database, causing ORGANIZATION_NOT_FOUND error
      await Future.delayed(const Duration(milliseconds: 150));

      if (mounted) {
        // Show success message with WhatsApp-style snackbar
        AppSnackbar.showSuccess(
          context: context,
          message: 'Team created successfully! Welcome aboard!',
        );

        // Navigate to home screen with GoRouter
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('email is already registered') ||
            e.toString().contains('Email is already registered')) {
          _errorMessage =
              'This email is already registered. Please login instead.';
        } else if (e.toString().contains('slug')) {
          _errorMessage =
              'Could not create team. Please try different company/team names.';
        } else {
          _errorMessage = 'Registration failed. Please try again.';
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
                  // Logo/Branding with animation
                  Icon(
                        Icons.business_center,
                        size: 64,
                        color: colorScheme.primary,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const Gap(16),

                  Text(
                        'Create Your Team',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const Gap(32),

                  // Form Card with animation
                  Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Error Message
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: AppRadius.borderRadiusSM,
                                    border: Border.all(
                                      color: colorScheme.error.withValues(
                                        alpha: 0.3,
                                      ),
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

                              // Company Name
                              AppTextField(
                                label: 'Company Name',
                                controller: _companyNameController,
                                prefixIcon: Icons.business,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Company name is required';
                                  }
                                  if (value.length < 2) {
                                    return 'Company name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(16),

                              // Team Name
                              AppTextField(
                                label: 'Team Name',
                                controller: _teamNameController,
                                prefixIcon: Icons.group,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Team name is required';
                                  }
                                  if (value.length < 2) {
                                    return 'Team name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(16),

                              // Manager Name
                              AppTextField(
                                label: 'Your Name',
                                controller: _managerNameController,
                                prefixIcon: Icons.person,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Your name is required';
                                  }
                                  if (value.length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(16),

                              // Username
                              AppTextField(
                                label: 'Username',
                                controller: _usernameController,
                                prefixIcon: Icons.alternate_email,
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Username is required';
                                  }
                                  if (value.length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(16),

                              // Email
                              AppTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                prefixIcon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                isRequired: true,
                                validator: _validateEmail,
                              ),
                              const Gap(16),

                              // Password
                              AppTextField(
                                label: 'Password',
                                controller: _passwordController,
                                prefixIcon: Icons.lock,
                                obscureText: true,
                                isRequired: true,
                                validator: _validatePassword,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordStrength =
                                        _calculatePasswordStrength(value);
                                  });
                                },
                              ),

                              // Password Strength Indicator
                              if (_passwordController.text.isNotEmpty) ...[
                                const Gap(12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: AppRadius.borderRadiusSM,
                                        child: LinearProgressIndicator(
                                          value: _passwordStrength,
                                          backgroundColor: colorScheme.outline
                                              .withValues(alpha: 0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _getPasswordStrengthColor(),
                                              ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const Gap(12),
                                    Text(
                                      _getPasswordStrengthText(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: _getPasswordStrengthColor(),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                              const Gap(24),

                              // Register Button
                              AppButton(
                                text: 'Create Team',
                                onPressed: _isLoading ? null : _handleRegister,
                                isLoading: _isLoading,
                                isFullWidth: true,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const Gap(24),

                  // Login Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Use context.go instead of context.pop because we might have
                        // navigated here with context.go (which replaces, not pushes)
                        // This ensures the button always works regardless of navigation method
                        context.go(AppRoutes.login);
                      },
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
