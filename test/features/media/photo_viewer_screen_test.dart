import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vet_manager_mobile/features/media/domain/entities/diagnostic_image_entity.dart';
import 'package:vet_manager_mobile/features/media/presentation/screens/photo_viewer_screen.dart';

void main() {
  late Directory tempDir;
  late File localImageFile;
  late DiagnosticImageEntity testImage;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('photo_viewer_test_');
    localImageFile = File('${tempDir.path}/sample_radiograph.webp');
    await localImageFile.writeAsBytes([1, 2, 3, 4]);

    testImage = DiagnosticImageEntity(
      id: 'test-img-01',
      imageableType: 'clinical_case',
      imageableId: 'case-99',
      url: '',
      localPath: localImageFile.path,
      title: 'VD Canine Pelvis Radiograph',
      mimeType: 'image/webp',
      fileSizeBytes: 1048576, // 1 MB
      createdAt: DateTime(2026, 11, 2),
    );
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PhotoViewerScreen', () {
    testWidgets('renders PhotoView, title, file size, and filter button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoViewerScreen(image: testImage),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('VD Canine Pelvis Radiograph'), findsOneWidget);
      expect(find.text('1.0 MB • image/webp'), findsOneWidget);
      expect(find.byType(PhotoView), findsOneWidget);
      expect(find.byKey(const Key('radiograph_filter_menu_button')), findsOneWidget);
    });

    testWidgets('can toggle Invert (Film) and High Contrast filter modes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoViewerScreen(image: testImage),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Open filter popup menu
      await tester.tap(find.byKey(const Key('radiograph_filter_menu_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Select Invert (Film)
      await tester.tap(find.text('Invert (Film)').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify active filter indicator pill appears
      expect(find.byIcon(Icons.filter_vintage_rounded), findsOneWidget);

      // Open filter popup menu again
      await tester.tap(find.byKey(const Key('radiograph_filter_menu_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Select High Contrast
      await tester.tap(find.text('High Contrast').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.filter_vintage_rounded), findsOneWidget);
    });

    testWidgets('back button dismisses the viewer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => PhotoViewerScreen(image: testImage),
                  ),
                );
              },
              child: const Text('Open Viewer'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Open Viewer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(PhotoViewerScreen), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(PhotoViewerScreen), findsNothing);
    });
  });
}
