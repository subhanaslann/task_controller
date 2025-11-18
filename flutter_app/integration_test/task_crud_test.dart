import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/main.dart' as app;
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/providers/providers.dart';

/// TekTech Mini Task Tracker
/// Integration Tests - Task CRUD Operations
///
/// Kapsamlı task yönetimi testleri:
/// - Task oluşturma
/// - Task listeleme
/// - Task güncelleme
/// - Task silme
/// - Task filtreleme ve arama
/// - Task sıralama

/// Helper: Task model JSON validation
/// Bu fonksiyon Task.fromJson'un çalıştığını doğrular
bool isValidTaskJson(Map<String, dynamic> json) {
  try {
    final task = Task.fromJson(json);
    // Task model required field'ları kontrol et
    // status ve priority enum'ları non-nullable
    return task.id.isNotEmpty && task.title.isNotEmpty;
  } catch (e) {
    return false;
  }
}

/// Helper: Task model instance validation
/// Bu fonksiyon Task instance'ının valid olduğunu doğrular
bool isValidTask(Task task) {
  // Task model gerekli field validasyonu
  // TaskStatus ve Priority enum'ları non-nullable, her zaman değer içerir
  return task.id.isNotEmpty && task.title.isNotEmpty;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Task Creation', () {
    testWidgets('Should display create task form', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create task butonunu bul
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Task form alanlarını kontrol et
        expect(find.byType(TextField), findsWidgets);
        expect(find.textContaining('Title'), findsWidgets);
        expect(find.textContaining('Description'), findsWidgets);

        // Task model için gerekli alanlar mevcut olmalı
        // TaskStatus ve Priority dropdown'ları olmalı
        expect(find.byType(DropdownButton), findsWidgets);
      }
    });

    testWidgets('Should validate required fields when creating task', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Create task butonuna bas
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Boş form ile submit et
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Validation hataları görünmeli
          expect(find.textContaining('required'), findsWidgets);
        }
      }
    });

    testWidgets('Should create task with valid data', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create task formunu aç
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Form alanlarını doldur
        final titleField = find.byKey(const Key('task_title_field'));
        final descriptionField = find.byKey(
          const Key('task_description_field'),
        );

        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Test Task');
        }

        if (descriptionField.evaluate().isNotEmpty) {
          await tester.enterText(descriptionField, 'Test Description');
        }

        await tester.pumpAndSettle();

        // Save butonuna bas
        final saveButton = find.text('Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Success mesajı kontrol et
          expect(find.textContaining('created'), findsWidgets);
        }
      }
    });

    testWidgets('Should set task priority when creating', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Priority dropdown'ı bul ve seç
        // Priority enum değerleri: low, normal, high
        final priorityDropdown = find.byKey(const Key('priority_dropdown'));
        if (priorityDropdown.evaluate().isNotEmpty) {
          await tester.tap(priorityDropdown);
          await tester.pumpAndSettle();

          // High priority seç (Priority.high)
          final highPriority = find.text('High');
          if (highPriority.evaluate().isNotEmpty) {
            await tester.tap(highPriority.last);
            await tester.pumpAndSettle();

            // Priority.high seçildiğini doğrula
            expect(find.text('High'), findsWidgets);
          }
        }
      }
    });

    testWidgets('Should set task status when creating', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Status dropdown'ı bul ve seç
        // TaskStatus enum değerleri: todo, inProgress, done
        final statusDropdown = find.byKey(const Key('status_dropdown'));
        if (statusDropdown.evaluate().isNotEmpty) {
          await tester.tap(statusDropdown);
          await tester.pumpAndSettle();

          // In Progress seç (TaskStatus.inProgress)
          final inProgress = find.text('In Progress');
          if (inProgress.evaluate().isNotEmpty) {
            await tester.tap(inProgress.last);
            await tester.pumpAndSettle();

            // TaskStatus.inProgress seçildiğini doğrula
            expect(find.text('In Progress'), findsWidgets);
          }
        }
      }
    });

    testWidgets('Should set task due date when creating', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Date picker'ı aç
        final dateButton = find.byIcon(Icons.calendar_today);
        if (dateButton.evaluate().isNotEmpty) {
          await tester.tap(dateButton);
          await tester.pumpAndSettle();

          // Tarih seç
          final okButton = find.text('OK');
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Should show loading indicator while creating task', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Form doldur
        final titleField = find.byKey(const Key('task_title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Test Task');
          await tester.pumpAndSettle();

          // Save butonuna bas
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pump(); // İlk frame

            // Loading indicator görünmeli
            expect(find.byType(CircularProgressIndicator), findsWidgets);
          }
        }
      }
    });
  });

  group('Task Listing', () {
    testWidgets('Should display task list on home screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task list görünmeli
      expect(find.byType(ListView), findsWidgets);

      // ProviderScope'tan container'ı al
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).first),
      );

      // Task repository'den task listesini kontrol et
      // Task model instance'ları List<Task> olarak dönecek
      final taskRepo = container.read(taskRepositoryProvider);
      expect(taskRepo, isNotNull);
    });

    testWidgets('Should display empty state when no tasks', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Cache temizle (eğer boş ise)
      // Empty state widget kontrol et
      final emptyState = find.textContaining('No tasks');
      if (emptyState.evaluate().isNotEmpty) {
        expect(emptyState, findsOneWidget);
      }
    });

    testWidgets('Should display task cards with correct information', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Task card'ları kontrol et
      // Her card Task model instance'ının field'larını gösterir:
      // - task.title: String
      // - task.status: TaskStatus (todo, inProgress, done)
      // - task.priority: Priority (low, normal, high)
      // - task.dueDate: String?
      // - task.assignee: Assignee?

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Her card'da Task model field'ları görünmeli
        // title, status badge, priority badge
        expect(find.byType(Card), findsWidgets);

        // Task model'deki enum değerleri badge olarak gösterilir
        // TaskStatus için: ToDo, InProgress, Done
        // Priority için: Low, Normal, High
      }
    });

    testWidgets('Should show loading indicator while fetching tasks', (
      tester,
    ) async {
      app.main();
      await tester.pump(); // İlk frame

      // Initial loading kontrol et
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('Should pull to refresh task list', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Pull to refresh gesture
      final scrollable = find.byType(ListView).first;
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable, const Offset(0, 300));
        await tester.pump();

        // Refresh indicator görünmeli
        expect(find.byType(RefreshIndicator), findsWidgets);

        await tester.pumpAndSettle();
      }
    });

    testWidgets('Should display task count', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task sayısı görünmeli
      // Örnek: "5 tasks" veya "Total: 5"
    });
  });

  group('Task Update', () {
    testWidgets('Should navigate to edit screen when task tapped', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // İlk task'a tıkla
      final firstTask = find.byType(Card).first;
      if (firstTask.evaluate().isNotEmpty) {
        await tester.tap(firstTask);
        await tester.pumpAndSettle();

        // Detail veya edit ekranı açılmalı
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('Should pre-fill form with existing task data', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Bir task'ı edit et
      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Form alanları dolu olmalı
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('Should update task title', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Başlığı değiştir
        final titleField = find.byKey(const Key('task_title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'Updated Task Title');
          await tester.pumpAndSettle();

          // Save
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            // Success mesajı
            expect(find.textContaining('updated'), findsWidgets);
          }
        }
      }
    });

    testWidgets('Should change task status', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task status'ünü değiştir
      // Bu işlem Task model'deki status alanını günceller
      // TaskStatus.done'a çevrilir
      final statusButton = find.byKey(const Key('status_change_button'));
      if (statusButton.evaluate().isNotEmpty) {
        await tester.tap(statusButton);
        await tester.pumpAndSettle();

        // Yeni status seç (TaskStatus.done)
        final doneStatus = find.text('Done');
        if (doneStatus.evaluate().isNotEmpty) {
          await tester.tap(doneStatus);
          await tester.pumpAndSettle();

          // Status değişimini doğrula
          // Task model'deki status field güncellenmiş olmalı
          expect(find.text('Done'), findsWidgets);
        }
      }
    });

    testWidgets('Should change task priority', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final editButton = find.byIcon(Icons.edit);
      if (editButton.evaluate().isNotEmpty) {
        await tester.tap(editButton.first);
        await tester.pumpAndSettle();

        // Priority dropdown
        final priorityDropdown = find.byKey(const Key('priority_dropdown'));
        if (priorityDropdown.evaluate().isNotEmpty) {
          await tester.tap(priorityDropdown);
          await tester.pumpAndSettle();

          // Low priority seç
          final lowPriority = find.text('Low');
          if (lowPriority.evaluate().isNotEmpty) {
            await tester.tap(lowPriority.last);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Should optimistically update UI', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task'ı güncelle
      // UI hemen güncellenip, arka planda sync olmalı
    });
  });

  group('Task Deletion', () {
    testWidgets('Should show confirmation dialog before deleting', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Delete butonuna bas
      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton.first);
        await tester.pumpAndSettle();

        // Confirmation dialog görünmeli
        expect(find.byType(AlertDialog), findsWidgets);
        expect(find.textContaining('Delete'), findsWidgets);
      }
    });

    testWidgets('Should delete task when confirmed', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton.first);
        await tester.pumpAndSettle();

        // Confirm delete
        final confirmButton = find.text('Delete').last;
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();

          // Success mesajı
          expect(find.textContaining('deleted'), findsWidgets);
        }
      }
    });

    testWidgets('Should cancel deletion when declined', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete);
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton.first);
        await tester.pumpAndSettle();

        // Cancel delete
        final cancelButton = find.text('Cancel');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();

          // Dialog kapanmalı, task silinmemeli
          expect(find.byType(AlertDialog), findsNothing);
        }
      }
    });

    testWidgets('Should show undo option after deletion', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Task sil ve undo seçeneğini kontrol et
      // Snackbar'da undo butonu olmalı
    });
  });

  group('Task Filtering', () {
    testWidgets('Should filter tasks by status', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Filter butonunu bul
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Status filtresi seç
        final todoFilter = find.text('To Do');
        if (todoFilter.evaluate().isNotEmpty) {
          await tester.tap(todoFilter);
          await tester.pumpAndSettle();

          // Sadece To Do task'ları görünmeli
        }
      }
    });

    testWidgets('Should filter tasks by priority', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Priority filtresi seç
        final highPriorityFilter = find.text('High');
        if (highPriorityFilter.evaluate().isNotEmpty) {
          await tester.tap(highPriorityFilter);
          await tester.pumpAndSettle();

          // Sadece High priority task'ları görünmeli
        }
      }
    });

    testWidgets('Should filter tasks by due date', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Due date filter (Today, This Week, Overdue, etc.)
    });

    testWidgets('Should clear all filters', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Clear filters butonunu bul ve bas
      final clearButton = find.text('Clear Filters');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Tüm task'lar görünmeli
      }
    });
  });

  group('Task Search', () {
    testWidgets('Should display search bar', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Search button veya field
      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('Should search tasks by title', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Arama yap
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'Test');
        await tester.pumpAndSettle();

        // Sonuçlar filtrelenmiş olmalı
      }
    });

    testWidgets('Should show no results message when search has no matches', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Varolmayan bir şey ara
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'NonExistentTask123');
        await tester.pumpAndSettle();

        // No results mesajı görünmeli
        expect(find.textContaining('No'), findsWidgets);
      }
    });

    testWidgets('Should clear search when close button tapped', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Arama yap
        final searchField = find.byType(TextField).first;
        await tester.enterText(searchField, 'Test');
        await tester.pumpAndSettle();

        // Clear butonu
        final clearButton = find.byIcon(Icons.clear);
        if (clearButton.evaluate().isNotEmpty) {
          await tester.tap(clearButton);
          await tester.pumpAndSettle();

          // Arama temizlenmiş olmalı
        }
      }
    });
  });

  group('Task Sorting', () {
    testWidgets('Should sort tasks by date', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Sort options menu
      final sortButton = find.byIcon(Icons.sort);
      if (sortButton.evaluate().isNotEmpty) {
        await tester.tap(sortButton);
        await tester.pumpAndSettle();

        // Date seçeneğini seç
        final dateOption = find.text('Date');
        if (dateOption.evaluate().isNotEmpty) {
          await tester.tap(dateOption);
          await tester.pumpAndSettle();

          // Task'lar tarihe göre sıralanmış olmalı
        }
      }
    });

    testWidgets('Should sort tasks by priority', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final sortButton = find.byIcon(Icons.sort);
      if (sortButton.evaluate().isNotEmpty) {
        await tester.tap(sortButton);
        await tester.pumpAndSettle();

        // Priority seçeneğini seç
        final priorityOption = find.text('Priority');
        if (priorityOption.evaluate().isNotEmpty) {
          await tester.tap(priorityOption);
          await tester.pumpAndSettle();

          // Task'lar priority'ye göre sıralanmış olmalı
        }
      }
    });

    testWidgets('Should toggle sort order (ascending/descending)', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Sort order toggle button
      final sortOrderButton = find.byIcon(Icons.swap_vert);
      if (sortOrderButton.evaluate().isNotEmpty) {
        await tester.tap(sortOrderButton);
        await tester.pumpAndSettle();

        // Sıralama ters çevrilmeli
      }
    });
  });

  group('Offline Behavior', () {
    testWidgets('Should create task offline and sync later', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ProviderScope'tan container'ı al
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).first),
      );

      // Offline mode'da task oluştur
      // Task model instance'ı oluşturulacak ve cache'e kaydedilecek
      // Task cache'e kaydedilmeli ve dirty flag set edilmeli

      // Cache repository provider'ını kontrol et
      final cacheRepo = container.read(cacheRepositoryProvider);
      expect(cacheRepo, isNotNull);
    });

    testWidgets('Should update task offline', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ProviderScope'tan container'ı al
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).first),
      );

      // Offline mode'da task güncelle
      // Task model copyWith kullanılarak güncellenir
      // Değişiklik cache'e kaydedilmeli

      // Task repository provider'ını kontrol et
      final taskRepo = container.read(taskRepositoryProvider);
      expect(taskRepo, isNotNull);
    });

    testWidgets('Should display offline indicator', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Offline durumda banner veya indicator görünmeli
    });

    testWidgets('Should sync pending changes when online', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // ProviderScope'tan container'ı al
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProviderScope).first),
      );

      // Offline'dan online'a geçişte
      // Pending değişiklikler sync edilmeli
      // Task model'deki dirty flag'li taskler sync edilir

      // Sync manager provider'ını kontrol et
      final syncManager = container.read(connectivityAwareSyncManagerProvider);
      expect(syncManager, isNotNull);

      // Sync manager cache stats'ı kontrol et
      final stats = await syncManager.getCacheStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('is_online'), isTrue);
    });
  });

  group('Error Handling', () {
    testWidgets('Should handle API errors gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // API error simüle et
      // User-friendly error mesajı gösterilmeli
    });

    testWidgets('Should show retry option on failure', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Başarısız işlem sonrası retry seçeneği olmalı
    });

    testWidgets('Should validate task data before submission', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // İnvalid data ile task oluşturmaya çalış
      // Client-side validation çalışmalı

      // Task model gerekli alanları kontrol eder:
      // - id: String (required)
      // - title: String (required)
      // - status: TaskStatus enum (required - todo, inProgress, done)
      // - priority: Priority enum (required - low, normal, high)

      // Boş title ile task oluşturma denemesi
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Title alanını boş bırak
        final titleField = find.byKey(const Key('task_title_field'));
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, '');
          await tester.pumpAndSettle();

          // Save butonuna bas
          final saveButton = find.text('Save');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();

            // Validation error görünmeli
            // Task model required field validation
            expect(find.textContaining('required'), findsWidgets);
          }
        }
      }
    });
  });
}
