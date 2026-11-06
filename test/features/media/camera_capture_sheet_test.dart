import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/features/media/domain/entities/diagnostic_image_entity.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_bloc.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_event.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_state.dart';
import 'package:vet_manager_mobile/features/media/presentation/widgets/camera_capture_sheet.dart';

class MockMediaBloc extends MockBloc<MediaEvent, MediaState> implements MediaBloc {}
class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockMediaBloc mockMediaBloc;
  late MockImagePicker mockImagePicker;
  late Directory tempDir;
  late File sampleFile;

  setUpAll(() {
    registerFallbackValue(const UploadMediaRequested(
      imageableType: 'clinical_case',
      imageableId: 'case-123',
      sourceFilePath: '/dummy/path.jpg',
    ));
  });

  setUp(() async {
    mockMediaBloc = MockMediaBloc();
    mockImagePicker = MockImagePicker();

    tempDir = await Directory.systemTemp.createTemp('capture_sheet_test_');
    sampleFile = File('${tempDir.path}/picked_film.webp');
    await sampleFile.writeAsBytes([1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MediaBloc>.value(
          value: mockMediaBloc,
          child: CameraCaptureSheet(
            imageableType: 'clinical_case',
            imageableId: 'case-123',
            imagePicker: mockImagePicker,
          ),
        ),
      ),
    );
  }

  group('CameraCaptureSheet', () {
    testWidgets('renders action buttons and input fields', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(const MediaInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('camera_source_button')), findsOneWidget);
      expect(find.byKey(const Key('gallery_source_button')), findsOneWidget);
      expect(find.byKey(const Key('submit_media_upload_button')), findsOneWidget);
      expect(find.text('Attach Diagnostic Media'), findsOneWidget);
    });

    testWidgets('picking an image updates preview and allows upload submission', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(const MediaInitial());
      when(() => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: any(named: 'imageQuality'),
          )).thenAnswer((_) async => XFile(sampleFile.path));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap gallery button
      await tester.tap(find.byKey(const Key('gallery_source_button')));
      await tester.pumpAndSettle();

      // Enter clinical caption
      await tester.enterText(find.byType(TextField), 'Right Stifle Lat View');
      await tester.pumpAndSettle();

      // Tap upload
      await tester.tap(find.byKey(const Key('submit_media_upload_button')));
      await tester.pump();

      verify(() => mockMediaBloc.add(UploadMediaRequested(
            imageableType: 'clinical_case',
            imageableId: 'case-123',
            sourceFilePath: sampleFile.path,
            title: 'Right Stifle Lat View',
          ))).called(1);
    });

    testWidgets('displays in-flight progress bar when uploading', (tester) async {
      when(() => mockMediaBloc.state).thenReturn(const MediaUploading(
        images: [],
        uploadProgress: 0.65,
        uploadingTitle: 'Uploading X-Ray...',
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byKey(const Key('media_upload_progress_bar')), findsOneWidget);
      expect(find.text('Compressing & streaming to cloud...'), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('shows success snackbar when upload completes', (tester) async {
      whenListen(
        mockMediaBloc,
        Stream.fromIterable([
          MediaOperationSuccess(
            message: 'Diagnostic image attached successfully.',
            attachedImage: DiagnosticImageEntity(
              id: 'img-999',
              imageableType: 'clinical_case',
              imageableId: 'case-123',
              url: 'https://storage.vetmanager.app/img-999.webp',
              fileSizeBytes: 204800,
              createdAt: DateTime.now(),
            ),
          ),
        ]),
        initialState: const MediaInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Diagnostic image attached successfully.'), findsOneWidget);
    });

    testWidgets('shows error snackbar on upload failure (error shielding)', (tester) async {
      whenListen(
        mockMediaBloc,
        Stream.fromIterable([
          const MediaFailure(message: 'Storage quota exceeded. Please check clinic plan.'),
        ]),
        initialState: const MediaInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Storage quota exceeded. Please check clinic plan.'), findsOneWidget);
    });
  });
}
