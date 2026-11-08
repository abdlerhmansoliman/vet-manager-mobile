import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/media/domain/entities/diagnostic_image_entity.dart';
import 'package:vet_manager_mobile/features/media/domain/repositories/media_repository.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_bloc.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_event.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_state.dart';
import 'package:vet_manager_mobile/features/media/presentation/screens/photo_viewer_screen.dart';
import 'package:vet_manager_mobile/features/media/presentation/widgets/camera_capture_sheet.dart';
import 'package:vet_manager_mobile/features/media/presentation/widgets/diagnostic_media_gallery.dart';

class MockMediaBloc extends MockBloc<MediaEvent, MediaState> implements MediaBloc {}

void main() {
  late MockMediaBloc mockMediaBloc;
  late Directory tempDir;
  late File localSampleFile;
  late DiagnosticImageEntity sampleImage;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gallery_test_');
    localSampleFile = File('${tempDir.path}/sample_xray.webp');
    await localSampleFile.writeAsBytes([1, 2, 3, 4]);

    sampleImage = DiagnosticImageEntity(
      id: 'img-alpha',
      imageableType: 'clinical_case',
      imageableId: 'case-001',
      url: '',
      localPath: localSampleFile.path,
      title: 'Lateral Thorax X-Ray',
      mimeType: 'image/webp',
      fileSizeBytes: 524288, // 512 KB
      createdAt: DateTime(2026, 11, 3),
    );
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() {
    mockMediaBloc = MockMediaBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DiagnosticMediaGallery(
            imageableType: 'clinical_case',
            imageableId: 'case-001',
            bloc: mockMediaBloc,
          ),
        ),
      ),
    );
  }

  group('DiagnosticMediaGallery', () {
    testWidgets('renders empty state when no media is attached', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(const MediaLoaded(images: []));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Diagnostic Media & X-Rays'), findsOneWidget);
      expect(find.text('No radiographs or clinical photos attached yet'), findsOneWidget);
      expect(find.text('Tap to photograph wound, X-ray, or ultrasound'), findsOneWidget);
    });

    testWidgets('renders thumbnail items with title and formatted size when images present', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(MediaLoaded(images: [sampleImage]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Lateral Thorax X-Ray'), findsOneWidget);
      expect(find.text('512.0 KB'), findsOneWidget);
      expect(find.byKey(const Key('add_diagnostic_media_button')), findsOneWidget);
    });

    testWidgets('tapping thumbnail opens PhotoViewerScreen', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(MediaLoaded(images: [sampleImage]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lateral Thorax X-Ray'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PhotoViewerScreen), findsOneWidget);
    });

    testWidgets('tapping add button opens CameraCaptureSheet bottom sheet', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(MediaLoaded(images: [sampleImage]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_diagnostic_media_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CameraCaptureSheet), findsOneWidget);
    });

    testWidgets('tapping delete button shows confirmation dialog and confirms deletion', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(MediaLoaded(images: [sampleImage]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteBtn = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Remove Diagnostic Image?'), findsOneWidget);
      expect(find.text('Delete Image'), findsOneWidget);

      await tester.tap(find.text('Delete Image'));
      await tester.pumpAndSettle();

      verify(() => mockMediaBloc.add(const DeleteMediaRequested('img-alpha'))).called(1);
    });

    testWidgets('resolves repository from RepositoryProvider and creates local bloc', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RepositoryProvider<IMediaRepository>.value(
            value: mockMediaBloc is IMediaRepository ? mockMediaBloc as IMediaRepository : _DummyRepo(),
            child: const Scaffold(
              body: DiagnosticMediaGallery(
                imageableType: 'clinical_case',
                imageableId: 'case-001',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Diagnostic Media & X-Rays'), findsOneWidget);
    });

    testWidgets('fallback to in-memory repository does not throw UnimplementedError', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DiagnosticMediaGallery(
              imageableType: 'clinical_case',
              imageableId: 'case-001',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Diagnostic Media & X-Rays'), findsOneWidget);
    });
  });
}

class _DummyRepo implements IMediaRepository {
  @override
  Future<DiagnosticImageEntity> captureAndUploadImage({
    required String imageableType,
    required String imageableId,
    required String sourceFilePath,
    String? title,
    String? tenantId,
    void Function(double progress)? onProgress,
  }) async {
    return DiagnosticImageEntity(
      id: 'dummy',
      imageableType: imageableType,
      imageableId: imageableId,
      url: sourceFilePath,
      fileSizeBytes: 100,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<DiagnosticImageEntity>> getImagesForCase(String caseId) async => [];

  @override
  Future<List<DiagnosticImageEntity>> getImagesForPatient(String patientId) async => [];

  @override
  Future<void> deleteImage(String imageId) async {}

  @override
  Future<int> retryPendingUploads() async => 0;
}
