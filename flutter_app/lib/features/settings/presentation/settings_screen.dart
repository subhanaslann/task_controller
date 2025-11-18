import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/avatar_picker.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentOrganization = ref.watch(currentOrganizationProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          l10n?.settings ?? 'Settings',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        children: [
          // Profile Header
          if (currentUser != null)
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              color: theme.cardColor,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showAvatarPicker(context),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.cardColor,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          currentUser.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (currentOrganization != null) ...[
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              currentOrganization.teamName,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),

          const Gap(16),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingTile(
            context,
            icon: Icons.brightness_6,
            title: 'Theme',
            subtitle: _getThemeModeName(currentTheme),
            onTap: () => _showThemeDialog(),
          ),

          const Gap(8),

          // Language Section
          _buildSectionHeader(context, 'Language'),
          _buildSettingTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: _getLanguageName(currentLocale),
            onTap: () => _showLanguageDialog(),
          ),

          const Gap(8),

          // Account Actions
          _buildSectionHeader(context, 'Account'),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: l10n?.logout ?? 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => _handleLogout(),
          ),

          const Gap(8),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
          ),
          _buildSettingTile(
            context,
            icon: Icons.description,
            title: 'License',
            subtitle: 'MIT License',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Mini Task Tracker',
                applicationVersion: _appVersion,
              );
            },
          ),

          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? AppColors.error : theme.colorScheme.onSurface;

    return Material(
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : AppColors.primary.withValues(alpha: 0.7),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getLanguageName(Locale? locale) {
    if (locale == null) return 'English';
    switch (locale.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: AppRadius.borderRadiusSM,
              ),
            ),
            const Gap(24),
            AvatarPicker(
              onImageSelected: (File? file) {
                Navigator.pop(context);
                if (file != null && context.mounted) {
                  // TODO: Implement avatar upload
                  AppSnackbar.showInfo(
                    context: context,
                    message: 'Avatar update coming soon!',
                  );
                }
              },
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.logout,
    );

    if (confirmed) {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      ref.read(currentUserProvider.notifier).state = null;

      if (mounted && context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  void _showThemeDialog() {
    final currentTheme = ref.read(themeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption('Light', currentTheme == ThemeMode.light, () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.of(context).pop();
            }),
            _buildRadioOption('Dark', currentTheme == ThemeMode.dark, () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.of(context).pop();
            }),
            _buildRadioOption(
              'System Default',
              currentTheme == ThemeMode.system,
              () {
                ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption(
              'English',
              currentLocale.languageCode == 'en',
              () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            _buildRadioOption('Türkçe', currentLocale.languageCode == 'tr', () {
              ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, bool selected, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : null,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
    );
  }
}
