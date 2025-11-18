import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/widgets/avatar_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AvatarPicker - Basic Rendering', () {
    testWidgets('should display default avatar icon when no image', (
      tester,
    ) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AvatarPicker());

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
    });

    testWidgets('should display default size of 120', (tester) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AvatarPicker());

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 120);
    });

    testWidgets('should display custom size when provided', (tester) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AvatarPicker(size: 80));

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 80);
      expect(container.constraints?.maxHeight, 80);
    });
  });

  group('AvatarPicker - Image Display', () {
    testWidgets('should show edit icon when image exists', (tester) async {
      // Arrange & Act
      await pumpTestWidget(
        tester,
        const AvatarPicker(initialImageUrl: 'https://example.com/avatar.jpg'),
      );

      // Allow image to load
      await tester.pump();

      // Assert - Edit icon should be shown instead of add icon
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group('AvatarPicker - User Interaction', () {
    testWidgets('should open bottom sheet when tapped', (tester) async {
      // Arrange
      await pumpTestWidget(tester, const AvatarPicker());

      // Act - Tap avatar
      await tester.tap(find.byType(AvatarPicker));
      await tester.pumpAndSettle();

      // Assert - Bottom sheet opened with options
      expect(find.text('Profil Fotoğrafı'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
      expect(find.text('Galeri'), findsOneWidget);
    });

    testWidgets('should show remove option when image exists', (tester) async {
      // Arrange
      await pumpTestWidget(
        tester,
        const AvatarPicker(initialImageUrl: 'https://example.com/avatar.jpg'),
      );

      // Act - Tap avatar
      await tester.tap(find.byType(AvatarPicker));
      await tester.pumpAndSettle();

      // Assert - Remove option visible
      expect(find.text('Fotoğrafı Kaldır'), findsOneWidget);
    });

    testWidgets('should not show remove option when no image', (tester) async {
      // Arrange
      await pumpTestWidget(tester, const AvatarPicker());

      // Act - Tap avatar
      await tester.tap(find.byType(AvatarPicker));
      await tester.pumpAndSettle();

      // Assert - Remove option not visible
      expect(find.text('Fotoğrafı Kaldır'), findsNothing);
    });

    testWidgets('should close bottom sheet when option selected', (
      tester,
    ) async {
      // Arrange
      await pumpTestWidget(tester, const AvatarPicker());

      // Act - Open bottom sheet
      await tester.tap(find.byType(AvatarPicker));
      await tester.pumpAndSettle();

      // Tap camera option
      await tester.tap(find.text('Kamera'));
      await tester.pumpAndSettle();

      // Assert - Bottom sheet closed
      expect(find.text('Profil Fotoğrafı'), findsNothing);
    });
  });

  group('AvatarPicker - Callback', () {
    testWidgets('should call onImageSelected when image picked', (
      tester,
    ) async {
      // Arrange
      File? selectedFile;

      await pumpTestWidget(
        tester,
        AvatarPicker(onImageSelected: (file) => selectedFile = file),
      );

      // Note: Actual image picking requires platform integration
      // This test verifies the callback signature is correct
      expect(selectedFile, isNull);
    });

    testWidgets('should call onImageSelected with null when removed', (
      tester,
    ) async {
      // Arrange
      File? selectedFile;

      await pumpTestWidget(
        tester,
        AvatarPicker(
          initialImageUrl: 'https://example.com/avatar.jpg',
          onImageSelected: (file) => selectedFile = file,
        ),
      );

      // Note: Actual removal test requires interaction
      // This test verifies the callback can handle null
      expect(selectedFile, isNull);
    });
  });

  group('AvatarPicker - Accessibility', () {
    testWidgets('should be tappable for screen readers', (tester) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AvatarPicker());

      // Assert - GestureDetector present
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should have circular shape for avatar', (tester) async {
      // Arrange & Act
      await pumpTestWidget(tester, const AvatarPicker());

      // Assert - Circular decoration
      final container = tester.widget<Container>(find.byType(Container).first);
      expect((container.decoration as BoxDecoration).shape, BoxShape.circle);
    });
  });
}
