import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/constants.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/topic.dart';
import '../../../data/datasources/api_service.dart';

class MemberTaskDialog extends ConsumerStatefulWidget {
  final String topicId;
  final String topicTitle;
  final VoidCallback? onTaskCreated;

  const MemberTaskDialog({
    Key? key,
    required this.topicId,
    required this.topicTitle,
    this.onTaskCreated,
  }) : super(key: key);

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
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red),
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
                    ),
                    child: Text(
                      _selectedDueDate == null
                          ? 'Tarih Seç'
                          : _selectedDueDate!.toLocal().toString().split(' ')[0],
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
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Kaydet',
          onPressed: _selectedDueDate == null
              ? null
              : () async {
                  if (_formKey.currentState!.validate() && currentUser != null) {
                    try {
                      // Member kendi adına görev ekliyor (self-assign)
                      print('DEBUG: Görev oluşturuluyor...');
                      await ref.read(taskRepositoryProvider).createMemberTask(
                        CreateMemberTaskRequest(
                          title: _titleController.text,
                          topicId: widget.topicId,
                          note: _noteController.text.isEmpty ? null : _noteController.text,
                          priority: _selectedPriority.value,
                          dueDate: _selectedDueDate != null 
                              ? '${_selectedDueDate!.toIso8601String().split('T')[0]}T00:00:00Z'
                              : null,
                        ),
                      );
                      print('DEBUG: Görev başarıyla oluşturuldu');
                      if (context.mounted) {
                        Navigator.pop(context);
                        widget.onTaskCreated?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Görev oluşturuldu')),
                        );
                      }
                    } catch (e, stackTrace) {
                      print('DEBUG: Görev oluşturma HATASI: $e');
                      print('DEBUG: Stack trace: $stackTrace');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: $e'),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  }
                },
        ),
      ],
    );
  }
}
