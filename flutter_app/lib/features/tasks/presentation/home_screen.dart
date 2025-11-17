import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import 'my_active_tasks_screen.dart';
import 'team_active_tasks_screen.dart';
import 'my_completed_tasks_screen.dart';
import 'guest_topics_screen.dart';
import '../../admin/presentation/admin_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _showAboutDialog = false;

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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMainContent(context),
        if (_showAboutDialog) _buildAboutDialog(),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.role == UserRole.admin ||
                     currentUser?.role == UserRole.teamManager;
    final isGuest = currentUser?.role == UserRole.guest;
    final screens = _getScreensForRole(currentUser?.role);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGuest ? 'TekTech-İşbirliği' : 'TekTech',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'admin':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminScreen(),
                    ),
                  );
                  break;
                case 'profile':
                  _showUserInfo(context, currentUser);
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'about':
                  setState(() {
                    _showAboutDialog = true;
                  });
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (isAdmin)
                PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n?.admin ?? 'Admin Mode'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n?.profile ?? 'Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              if (const bool.fromEnvironment('dart.vm.product') == false)
                PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n?.settings ?? 'About'),
                    ],
                  ),
                ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n?.logout ?? 'Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: screens[isGuest ? 0 : _selectedIndex],
      bottomNavigationBar: isGuest
          ? null // Guest kullanıcılar sadece topic görür, navigation bar yok
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.task_outlined),
                  activeIcon: const Icon(Icons.task),
                  label: 'My Active',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.people_outline),
                  activeIcon: const Icon(Icons.people),
                  label: 'Team Active',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.check_circle_outline),
                  activeIcon: const Icon(Icons.check_circle),
                  label: 'My Completed',
                ),
              ],
            ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Navigate to create task screen
                _showCreateTaskDialog(context);
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildAboutDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showAboutDialog = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('App: Mini Task Tracker'),
                const SizedBox(height: 8),
                const Text('Version: 1.0.0'),
                const SizedBox(height: 8),
                const Text('Build: Debug'),
                const SizedBox(height: 8),
                Text('API: ${ApiConstants.baseUrl}'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showAboutDialog = false;
                      });
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserInfo(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Username: ${user?.username ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Role: ${user?.role.value ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? 'N/A'}'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      ref.read(currentUserProvider.notifier).state = null;

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _showCreateTaskDialog(BuildContext context) {
    // TODO: Implement create task dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create task functionality coming soon')),
    );
  }
}
