import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import '../notifiers/organization_notifier.dart';

final organizationNotifierProvider =
    StateNotifierProvider<OrganizationNotifier, OrganizationState>((ref) {
      final repository = ref.watch(organizationRepositoryProvider);
      return OrganizationNotifier(repository);
    });

class OrganizationTab extends ConsumerStatefulWidget {
  const OrganizationTab({super.key});

  @override
  ConsumerState<OrganizationTab> createState() => _OrganizationTabState();
}

class _OrganizationTabState extends ConsumerState<OrganizationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  void _loadData() {
    // Only fetch if we don't already have organization data
    final currentOrg = ref.read(currentOrganizationProvider);
    if (currentOrg == null) {
      // Organization ID is automatically retrieved from JWT token
      ref.read(organizationNotifierProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orgState = ref.watch(organizationNotifierProvider);
    final currentOrg = ref.watch(currentOrganizationProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (orgState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orgState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const Gap(16),
            Text(orgState.error!, style: const TextStyle(color: Colors.red)),
            const Gap(16),
            AppButton(text: 'Retry', onPressed: _loadData),
          ],
        ),
      );
    }

    final organization = orgState.organization ?? currentOrg;
    final stats = orgState.stats;

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Organization Details Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: colorScheme.primary),
                      const Gap(12),
                      Text(
                        'Organization Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (currentUser?.role == UserRole.teamManager)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditOrganizationDialog(organization);
                          },
                          tooltip: 'Edit Organization',
                        ),
                    ],
                  ),
                  const Divider(),
                  const Gap(12),
                  _buildDetailRow('Company Name', organization?.name ?? 'N/A'),
                  const Gap(12),
                  _buildDetailRow('Team Name', organization?.teamName ?? 'N/A'),
                  const Gap(12),
                  _buildDetailRow(
                    'Slug',
                    organization?.slug ?? 'N/A',
                    isReadOnly: true,
                  ),
                  const Gap(12),
                  _buildDetailRow(
                    'Max Users',
                    organization?.maxUsers.toString() ?? 'N/A',
                    isReadOnly: currentUser?.role != UserRole.teamManager,
                  ),
                  const Gap(12),
                  _buildDetailRow(
                    'Status',
                    organization?.isActive ?? false ? 'Active' : 'Inactive',
                    valueColor: organization?.isActive ?? false
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),

          // Statistics Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: colorScheme.primary),
                      const Gap(12),
                      Text(
                        'Statistics',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Gap(16),
                  if (stats != null) ...[
                    // Users Stats
                    _buildStatCard(
                      icon: Icons.people,
                      title: 'Users',
                      value: '${stats.activeUserCount} / ${stats.userCount}',
                      subtitle: '${stats.activeUserCount} active users',
                      color: Colors.blue,
                    ),
                    const Gap(12),
                    // Tasks Stats
                    _buildStatCard(
                      icon: Icons.task_alt,
                      title: 'Tasks',
                      value: '${stats.activeTaskCount} / ${stats.taskCount}',
                      subtitle: '${stats.completedTaskCount} completed',
                      color: Colors.green,
                    ),
                    const Gap(12),
                    // Topics Stats
                    _buildStatCard(
                      icon: Icons.category,
                      title: 'Topics',
                      value: '${stats.activeTopicCount} / ${stats.topicCount}',
                      subtitle: '${stats.activeTopicCount} active topics',
                      color: Colors.orange,
                    ),
                  ] else
                    const Center(child: Text('No statistics available')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isReadOnly = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
              if (isReadOnly) ...[
                const Gap(8),
                const Icon(Icons.lock, size: 16, color: Colors.grey),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditOrganizationDialog(organization) {
    final nameController = TextEditingController(
      text: organization?.name ?? '',
    );
    final teamNameController = TextEditingController(
      text: organization?.teamName ?? '',
    );
    final maxUsersController = TextEditingController(
      text: organization?.maxUsers.toString() ?? '15',
    );
    final currentUser = ref.read(currentUserProvider);
    final isAdmin = currentUser?.role == UserRole.teamManager;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Company Name',
                controller: nameController,
                prefixIcon: Icons.business,
              ),
              const Gap(16),
              AppTextField(
                label: 'Team Name',
                controller: teamNameController,
                prefixIcon: Icons.group,
              ),
              if (isAdmin) ...[
                const Gap(16),
                AppTextField(
                  label: 'Max Users',
                  controller: maxUsersController,
                  prefixIcon: Icons.people,
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Save',
            onPressed: () async {
              if (organization != null) {
                await ref
                    .read(organizationNotifierProvider.notifier)
                    .updateOrganization(
                      name: nameController.text.trim(),
                      teamName: teamNameController.text.trim(),
                      maxUsers: isAdmin
                          ? int.tryParse(maxUsersController.text)
                          : null,
                    );

                // Update currentOrganizationProvider
                final updatedOrg = ref
                    .read(organizationNotifierProvider)
                    .organization;
                if (updatedOrg != null) {
                  ref.read(currentOrganizationProvider.notifier).state =
                      updatedOrg;
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Organization updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
