import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/app_snackbar.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppSnackbar Widget Tests', () {
    testWidgets('should show success snackbar with correct styling', (
      tester,
    ) async {
      // Arrange
      late BuildContext capturedContext;
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: Center(child: Text('Test')));
          },
        ),
      );

      // Act
      AppSnackbar.showSuccess(
        context: capturedContext,
        message: 'Success message',
      );
      await tester.pump();

      // Assert
      expect(find.text('Success message'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show error snackbar with retry action', (tester) async {
      // Arrange
      late BuildContext capturedContext;
      var actionCalled = false;
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: Center(child: Text('Test')));
          },
        ),
      );

      // Act
      AppSnackbar.showError(
        context: capturedContext,
        message: 'Error occurred',
        actionLabel: 'Retry',
        onActionPressed: () {
          actionCalled = true;
        },
      );
      await tester.pump();

      // Assert
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Tap action button
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(actionCalled, true);
    });

    testWidgets('should show warning snackbar with correct icon', (
      tester,
    ) async {
      // Arrange
      late BuildContext capturedContext;
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: Center(child: Text('Test')));
          },
        ),
      );

      // Act
      AppSnackbar.showWarning(
        context: capturedContext,
        message: 'Warning message',
      );
      await tester.pump();

      // Assert
      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('should show info snackbar with correct icon', (tester) async {
      // Arrange
      late BuildContext capturedContext;
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: Center(child: Text('Test')));
          },
        ),
      );

      // Act
      AppSnackbar.showInfo(context: capturedContext, message: 'Info message');
      await tester.pump();

      // Assert
      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should show custom snackbar with action button', (
      tester,
    ) async {
      // Arrange
      late BuildContext capturedContext;
      var actionPressed = false;
      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) {
            capturedContext = context;
            return const Scaffold(body: Center(child: Text('Test')));
          },
        ),
      );

      // Act
      AppSnackbar.show(
        context: capturedContext,
        message: 'Custom message',
        type: SnackbarType.info,
        actionLabel: 'Action',
        onActionPressed: () {
          actionPressed = true;
        },
      );
      await tester.pump();

      // Assert
      expect(find.text('Custom message'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);

      // Tap action
      await tester.tap(find.text('Action'));
      await tester.pump();
      expect(actionPressed, true);
    });
  });
}
