import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/media/domain/entities/diagnostic_image_entity.dart';
import 'package:vet_manager_mobile/features/media/domain/repositories/media_repository.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_bloc.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_event.dart';
import 'package:vet_manager_mobile/features/media/presentation/bloc/media_state.dart';

class MockMediaRepository extends Mock implements IMediaRepository {}

void main() {
  late MockMediaRepository mockRepo;

  final sampleImage = DiagnosticImageEntity(
    id: 'img-101',
    imageableType: 'clinical_case',
    imageableId: 'case-555',
    url: 'https://storage.vetmanager.app/img-101.webp',
    localPath: '/tmp/img-101.webp',
    title: 'VD Pelvis Radiograph',
    mimeType: 'image/webp',
    fileSizeBytes: 204800,
    createdAt: DateTime(2026, 11, 1),
  );

  setUp(() {
    mockRepo = MockMediaRepository();
  });

  group('MediaBloc', () {
    test('initial state is MediaInitial', () {
      final bloc = MediaBloc(repository: mockRepo);
      expect(bloc.state, equals(const MediaInitial()));
      bloc.close();
    });

    blocTest<MediaBloc, MediaState>(
      'emits [MediaLoading, MediaLoaded] when LoadCaseMediaRequested succeeds',
      build: () {
        when(() => mockRepo.getImagesForCase('case-555'))
            .thenAnswer((_) async => [sampleImage]);
        return MediaBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadCaseMediaRequested('case-555')),
      expect: () => [
        const MediaLoading(images: <DiagnosticImageEntity>[]),
        MediaLoaded(images: [sampleImage]),
      ],
      verify: (_) {
        verify(() => mockRepo.getImagesForCase('case-555')).called(1);
      },
    );

    blocTest<MediaBloc, MediaState>(
      'emits [MediaLoading, MediaFailure] with clinical error formatting when LoadCaseMediaRequested fails',
      build: () {
        when(() => mockRepo.getImagesForCase('case-555'))
            .thenThrow(const NetworkException(message: 'Connection timed out.'));
        return MediaBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const LoadCaseMediaRequested('case-555')),
      expect: () => [
        const MediaLoading(images: <DiagnosticImageEntity>[]),
        isA<MediaFailure>().having(
          (s) => s.message,
          'message',
          contains('offline'),
        ),
      ],
    );

    blocTest<MediaBloc, MediaState>(
      'emits [MediaUploading, MediaOperationSuccess, MediaLoaded] when UploadMediaRequested succeeds',
      build: () {
        when(
          () => mockRepo.captureAndUploadImage(
            imageableType: 'clinical_case',
            imageableId: 'case-555',
            sourceFilePath: '/tmp/photo.jpg',
            title: 'Chest X-Ray',
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => sampleImage);
        return MediaBloc(repository: mockRepo);
      },
      act: (bloc) => bloc.add(const UploadMediaRequested(
        imageableType: 'clinical_case',
        imageableId: 'case-555',
        sourceFilePath: '/tmp/photo.jpg',
        title: 'Chest X-Ray',
      )),
      expect: () => [
        isA<MediaUploading>().having((s) => s.uploadingTitle, 'title', 'Chest X-Ray'),
        isA<MediaOperationSuccess>().having((s) => s.images, 'images', [sampleImage]),
        MediaLoaded(images: [sampleImage]),
      ],
    );

    blocTest<MediaBloc, MediaState>(
      'emits [MediaOperationSuccess, MediaLoaded] when DeleteMediaRequested succeeds',
      build: () {
        when(() => mockRepo.deleteImage('img-101')).thenAnswer((_) async {});
        return MediaBloc(repository: mockRepo);
      },
      seed: () => MediaLoaded(images: [sampleImage]),
      act: (bloc) => bloc.add(const DeleteMediaRequested('img-101')),
      expect: () => [
        const MediaOperationSuccess(
          message: 'Image removed from case file.',
          images: <DiagnosticImageEntity>[],
        ),
        const MediaLoaded(images: <DiagnosticImageEntity>[]),
      ],
      verify: (_) {
        verify(() => mockRepo.deleteImage('img-101')).called(1);
      },
    );

    blocTest<MediaBloc, MediaState>(
      'emits MediaUploading with updated progress when UploadProgressUpdated is received',
      build: () => MediaBloc(repository: mockRepo),
      seed: () => const MediaUploading(
        images: <DiagnosticImageEntity>[],
        uploadProgress: 0.1,
        uploadingTitle: 'Uploading X-Ray',
      ),
      act: (bloc) => bloc.add(const UploadProgressUpdated(0.75)),
      expect: () => [
        const MediaUploading(
          images: <DiagnosticImageEntity>[],
          uploadProgress: 0.75,
          uploadingTitle: 'Uploading X-Ray',
        ),
      ],
    );
  });
}
