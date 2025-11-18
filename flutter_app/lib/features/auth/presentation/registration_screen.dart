import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/providers/providers.dart';

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
    if (_passwordStrength < 0.3) return Colors.red;
    if (_passwordStrength < 0.6) return Colors.orange;
    if (_passwordStrength < 0.8) return Colors.yellow;
    return Colors.green;
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
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      ref.read(currentUserProvider.notifier).state = authResult.user;
      ref.read(currentOrganizationProvider.notifier).state =
          authResult.organization;

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team created successfully! Welcome aboard!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Branding
                  Icon(Icons.business_center, size: 48, color: Colors.white),
                  const Gap(8),
                  Text(
                    'Create Your Team',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),

                  // Form Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Error Message
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
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
                                          color: colorScheme.error,
                                          fontSize: 14,
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
                            const Gap(12),

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
                            const Gap(12),

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
                            const Gap(12),

                            // Email
                            AppTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              isRequired: true,
                              validator: _validateEmail,
                            ),
                            const Gap(12),

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
                            if (_passwordController.text.isNotEmpty) ...[
                              const Gap(8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getPasswordStrengthColor(),
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    _getPasswordStrengthText(),
                                    style: TextStyle(
                                      color: _getPasswordStrengthColor(),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const Gap(16),

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
                    ),
                  ),
                  const Gap(16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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
    );
  }
}
