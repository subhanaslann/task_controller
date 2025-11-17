import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/debounce.dart';

void main() {
  group('Debouncer Tests', () {
    test('should execute action after specified duration', () async {
      // Arrange
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Act
      debouncer.call(() {
        executed = true;
      });

      // Assert - Should not execute immediately
      expect(executed, false);

      // Wait for debounce duration
      await Future.delayed(const Duration(milliseconds: 150));
      expect(executed, true);
    });

    test('should cancel previous call when called multiple times', () async {
      // Arrange
      var callCount = 0;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Act - Call multiple times rapidly
      debouncer.call(() {
        callCount++;
      });
      debouncer.call(() {
        callCount++;
      });
      debouncer.call(() {
        callCount++;
      });

      // Assert - Only last call should execute
      await Future.delayed(const Duration(milliseconds: 150));
      expect(callCount, 1);
    });

    test('should cancel pending action when cancel is called', () async {
      // Arrange
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Act
      debouncer.call(() {
        executed = true;
      });
      debouncer.cancel();

      // Assert
      await Future.delayed(const Duration(milliseconds: 150));
      expect(executed, false);
    });

    test('should report isActive correctly', () async {
      // Arrange
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Assert - Initially not active
      expect(debouncer.isActive, false);

      // Act - Start debounce
      debouncer.call(() {});

      // Assert - Should be active
      expect(debouncer.isActive, true);

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 150));
      expect(debouncer.isActive, false);
    });

    test('should dispose timer correctly', () {
      // Arrange
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Act
      debouncer.call(() {
        executed = true;
      });
      debouncer.dispose();

      // Assert - Should not execute after dispose
      Future.delayed(const Duration(milliseconds: 150)).then((_) {
        expect(executed, false);
      });
    });
  });
}

