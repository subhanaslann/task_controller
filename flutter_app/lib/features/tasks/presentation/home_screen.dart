import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';

import 'my_active_tasks_screen.dart';
import 'team_active_tasks_screen.dart';
import 'my_completed_tasks_screen.dart';
import 'guest_topics_screen.dart';
import '../../admin/presentation/admin_dialogs.dart';
import '../../../data/models/user.dart';
import '../../../data/datasources/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  List<Widget> _getScreensForRole(UserRole? role) {
    if (role == UserRole.guest) {
      return [const GuestTopicsScreen()];
    }
    return [
      const MyActiveTasksScreen(),
      const TeamActiveTasksScreen(),
      const MyCompletedTasksScreen(),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isGuest = currentUser?.role == UserRole.guest;
    final screens = _getScreensForRole(currentUser?.role);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary, // WhatsApp Teal
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: l10n?.search ?? 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                autofocus: true,
              ).animate().fadeIn(duration: 200.ms)
            : Text(
                isGuest ? 'TekTech-İşbirliği' : 'TekTech',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
        actions: [
          if (!isGuest)
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  if (_isSearchVisible) {
                    _searchController.clear();
                  }
                  _isSearchVisible = !_isSearchVisible;
                });
              },
            ),
          _buildPopupMenu(context, currentUser, l10n),
        ],
      ),
      body: screens[isGuest ? 0 : _selectedIndex],
      bottomNavigationBar: isGuest
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.2),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.task_outlined),
                  selectedIcon: const Icon(
                    Icons.task,
                    color: AppColors.primary,
                  ),
                  label: l10n?.myTasks ?? 'My Tasks',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(
                    Icons.people,
                    color: AppColors.primary,
                  ),
                  label: l10n?.teamTasks ?? 'Team Tasks',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.check_circle_outline),
                  selectedIcon: const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  ),
                  label: l10n?.completedTasks ?? 'Completed',
                ),
              ],
            ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () => _showCreateTaskDialog(context),
              backgroundColor: AppColors.secondary, // WhatsApp Green
              child: const Icon(Icons.add, color: Colors.white),
            ).animate().scale(
              delay: 500.ms,
              duration: 300.ms,
              curve: Curves.easeOutBack,
            ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    User? currentUser,
    AppLocalizations? l10n,
  ) {
    final isAdmin =
        currentUser?.role == UserRole.admin ||
        currentUser?.role == UserRole.teamManager;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusSM),
      onSelected: (String value) {
        switch (value) {
          case 'admin':
            context.push(AppRoutes.admin);
            break;
          case 'profile':
            _showUserInfo(context, currentUser);
            break;
          case 'settings':
            context.push(AppRoutes.settings);
            break;
          case 'about':
            _showAboutDialog(context);
            break;
          case 'logout':
            _handleLogout(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (isAdmin)
          PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 20),
                const Gap(12),
                Text(l10n?.admin ?? 'Admin Mode'),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 20),
              const Gap(12),
              Text(l10n?.profile ?? 'Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings, size: 20),
              const Gap(12),
              Text(l10n?.settings ?? 'Settings'),
            ],
          ),
        ),
        if (const bool.fromEnvironment('dart.vm.product') == false)
          const PopupMenuItem(
            value: 'about',
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                Gap(12),
                Text('About'),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.error),
              const Gap(12),
              Text(
                l10n?.logout ?? 'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted || !context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: Row(
          children: [
            const Icon(Icons.info, color: AppColors.primary),
            const Gap(12),
            const Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('App', packageInfo.appName),
            _buildInfoRow('Version', packageInfo.version),
            _buildInfoRow('Build', packageInfo.buildNumber),
            const Gap(16),
            Text(
              'API Endpoint:',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Text(
              ApiConstants.baseUrl,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  void _showUserInfo(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        title: const Text('User Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (user?.name ?? '').isNotEmpty
                      ? user!.name.substring(0, 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              title: Text(user?.name ?? 'N/A'),
              subtitle: Text(user?.username ?? 'N/A'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            _buildInfoRow('Role', user?.role.value ?? 'N/A'),
            _buildInfoRow('Email', user?.email ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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

  void _showCreateTaskDialog(BuildContext context) async {
    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final topics = await adminRepo.getTopics();
      final users = await adminRepo.getUsers();

      if (!mounted || !context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => TaskCreateDialog(
          topics: topics,
          users: users,
          onSave:
              (
                title,
                topicId,
                note,
                assigneeId,
                status,
                priority,
                dueDate,
              ) async {
                try {
                  await ref
                      .read(taskRepositoryProvider)
                      .createTask(
                        CreateTaskRequest(
                          title: title,
                          topicId: topicId,
                          note: note,
                          assigneeId: assigneeId,
                          status: status,
                          priority: priority,
                          dueDate: dueDate,
                        ),
                      );

                  if (context.mounted) {
                    AppSnackbar.showSuccess(
                      context: context,
                      message: 'Görev başarıyla oluşturuldu',
                    );
                    // Trigger refresh via provider/state if needed,
                    // though Riverpod streams should auto-update if set up correctly
                    setState(() {});
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'Hata: $e',
                    );
                  }
                }
              },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Veriler yüklenemedi: $e',
        );
      }
    }
  }
}
