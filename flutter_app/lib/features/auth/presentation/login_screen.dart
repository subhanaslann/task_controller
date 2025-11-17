import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/locale_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      ref.read(currentOrganizationProvider.notifier).state = authResult.organization;

      if (mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      final errorString = e.toString().toLowerCase();
      setState(() {
        if (errorString.contains('deactivated') && errorString.contains('organization')) {
          _errorMessage = 'Your organization has been deactivated. Please contact support.';
        } else if (errorString.contains('deactivated') && errorString.contains('account')) {
          _errorMessage = 'Your account has been deactivated. Contact your team manager.';
        } else {
          _errorMessage = l10n.loginErrorMessage;
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
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = ref.read(localeProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Language switcher button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await localeNotifier.toggleLocale();
                      },
                      icon: Icon(Icons.language, color: colorScheme.onSurface),
                      tooltip: 'Dil Değiştir / Change Language',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo/Icon with animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Text(
                                'TekTech',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const Gap(48),
                          // Login form with animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: const Interval(
                                        0.3,
                                        1.0,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radius24,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppTheme.spacing24,
                                  ),
                                  child: Column(
                                    children: [
                                      // Username field
                                      AppTextField(
                                        label: l10n.usernameOrEmail,
                                        controller: _usernameController,
                                        prefixIcon: Icons.person,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.validation_required;
                                          }
                                          return null;
                                        },
                                      ),
                                      const Gap(16),
                                      // Password field
                                      AppTextField(
                                        label: l10n.password,
                                        controller: _passwordController,
                                        obscureText: true,
                                        prefixIcon: Icons.lock,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return l10n.validation_required;
                                          }
                                          return null;
                                        },
                                      ),
                                      const Gap(24),
                                      // Error message
                                      if (_errorMessage != null)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme.errorContainer,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.error
                                                  .withOpacity(0.3),
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
                                                    color: colorScheme
                                                        .onErrorContainer,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (_errorMessage != null) const Gap(16),
                                      // Login button
                                      AppButton(
                                        text: l10n.login,
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                        isLoading: _isLoading,
                                        isFullWidth: true,
                                      ),
                                      const Gap(16),
                                      // Registration link
                                      Center(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed('/register');
                                          },
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
