import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/widgets/form_controls.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AppCheckbox Widget Tests', () {
    testWidgets('should render checkbox with label', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        AppCheckbox(
          checked: false,
          onChanged: (_) {},
          label: 'Test Checkbox',
        ),
      );

      // Assert
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Test Checkbox'), findsOneWidget);
    });

    testWidgets('should be checked when checked is true', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        AppCheckbox(
          checked: true,
          onChanged: (_) {},
          label: 'Test Checkbox',
        ),
      );

      // Assert
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('should call onChanged when tapped', (tester) async {
      // Arrange
      var checked = false;
      await pumpTestWidget(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return AppCheckbox(
              checked: checked,
              onChanged: (value) {
                setState(() {
                  checked = value;
                });
              },
              label: 'Test Checkbox',
            );
          },
        ),
      );

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(checked, true);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      // Arrange
      var changeCalled = false;
      await pumpTestWidget(
        tester,
        AppCheckbox(
          checked: false,
          onChanged: (_) {
            changeCalled = true;
          },
          label: 'Disabled Checkbox',
          enabled: false,
        ),
      );

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(changeCalled, false);
    });
  });

  group('AppSwitch Widget Tests', () {
    testWidgets('should render switch with label', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        AppSwitch(
          checked: false,
          onChanged: (_) {},
          label: 'Test Switch',
        ),
      );

      // Assert
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Test Switch'), findsOneWidget);
    });

    testWidgets('should render switch with label and description',
        (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        AppSwitch(
          checked: false,
          onChanged: (_) {},
          label: 'Test Switch',
          description: 'Switch description',
        ),
      );

      // Assert
      expect(find.text('Test Switch'), findsOneWidget);
      expect(find.text('Switch description'), findsOneWidget);
    });

    testWidgets('should be checked when checked is true', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        AppSwitch(
          checked: true,
          onChanged: (_) {},
          label: 'Test Switch',
        ),
      );

      // Assert
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('should call onChanged when tapped', (tester) async {
      // Arrange
      var checked = false;
      await pumpTestWidget(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return AppSwitch(
              checked: checked,
              onChanged: (value) {
                setState(() {
                  checked = value;
                });
              },
              label: 'Test Switch',
            );
          },
        ),
      );

      // Act
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Assert
      expect(checked, true);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      // Arrange
      var changeCalled = false;
      await pumpTestWidget(
        tester,
        AppSwitch(
          checked: false,
          onChanged: (_) {
            changeCalled = true;
          },
          label: 'Disabled Switch',
          enabled: false,
        ),
      );

      // Act
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Assert
      expect(changeCalled, false);
    });
  });
}

