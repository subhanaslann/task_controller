import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentOrganization = ref.watch(currentOrganizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeName(currentTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(),
                ),
              ],
            ),
          ),

          // Language Section
          _buildSectionHeader('Language'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  subtitle: Text(_getLanguageName(currentLocale)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(),
                ),
              ],
            ),
          ),

          // Account Section
          if (currentUser != null) ...[
            _buildSectionHeader('Account'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        currentUser.name.isNotEmpty
                            ? currentUser.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(currentUser.name),
                    subtitle: Text(currentUser.email),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(currentOrganization?.name ?? 'Organization'),
                    subtitle: Text(currentOrganization?.teamName ?? ''),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Role'),
                    subtitle: Text(_getRoleName(currentUser.role.name)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => _handleLogout(),
                  ),
                ],
              ),
            ),
          ],

          // About Section
          _buildSectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: Text(_appVersion.isNotEmpty ? _appVersion : 'Loading...'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('License'),
                  subtitle: const Text('MIT License'),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Mini Task Tracker',
                      applicationVersion: _appVersion,
                    );
                  },
                ),
              ],
            ),
          ),

          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
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

  String _getRoleName(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrator';
      case 'TEAM_MANAGER':
      case 'TEAMMANAGER':
        return 'Team Manager';
      case 'MEMBER':
        return 'Member';
      case 'GUEST':
        return 'Guest';
      default:
        return role;
    }
  }

  Future<void> _handleLogout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showThemeDialog() {
    final currentTheme = ref.read(themeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale?.languageCode ?? 'en',
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: currentLocale?.languageCode ?? 'en',
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

