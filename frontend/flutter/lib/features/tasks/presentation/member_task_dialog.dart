import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/providers/providers.dart';
import '../../../data/datasources/api_service.dart';

class MemberTaskDialog extends ConsumerStatefulWidget {
  final String topicId;
  final String topicTitle;
  final VoidCallback? onTaskCreated;

  const MemberTaskDialog({
    super.key,
    required this.topicId,
    required this.topicTitle,
    this.onTaskCreated,
  });

  @override
  ConsumerState<MemberTaskDialog> createState() => _MemberTaskDialogState();
}

class _MemberTaskDialogState extends ConsumerState<MemberTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  Priority _selectedPriority = Priority.normal;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      title: Text('Görev Ekle: ${widget.topicTitle}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Görev Başlığı',
                controller: _titleController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
                maxLines: 3,
              ),
              const Gap(16),
              AppTextField(
                label: 'Not (opsiyonel)',
                controller: _noteController,
                maxLines: 5,
              ),
              const Gap(16),
              // Priority selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Öncelik',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Düşük'),
                        selected: _selectedPriority == Priority.low,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = Priority.low;
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Normal'),
                        selected: _selectedPriority == Priority.normal,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = Priority.normal;
                            });
                          }
                        },
                      ),
                      FilterChip(
                        label: const Text('Yüksek'),
                        selected: _selectedPriority == Priority.high,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = Priority.high;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),
              // Due Date picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bitiş Tarihi *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const Gap(8),
                  OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    child: Text(
                      _selectedDueDate == null
                          ? 'Tarih Seç'
                          : _selectedDueDate!.toLocal().toString().split(
                              ' ',
                            )[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        AppButton(
          text: 'Ekle',
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            if (_selectedDueDate == null) {
              AppSnackbar.showWarning(
                context: context,
                message: 'Lütfen bir bitiş tarihi seçin',
              );
              return;
            }
            if (currentUser != null) {
              try {
                await ref
                    .read(taskRepositoryProvider)
                    .createMemberTask(
                      CreateMemberTaskRequest(
                        topicId: widget.topicId,
                        title: _titleController.text.trim(),
                        note: _noteController.text.trim().isNotEmpty
                            ? _noteController.text.trim()
                            : null,
                        priority: _selectedPriority.value,
                        dueDate: _selectedDueDate != null
                            ? '${_selectedDueDate!.toIso8601String().split('T')[0]}T00:00:00Z'
                            : null,
                      ),
                    );

                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  widget.onTaskCreated?.call();
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context: context, message: 'Hata: $e');
                }
              }
            }
          },
        ),
      ],
    );
  }
}
