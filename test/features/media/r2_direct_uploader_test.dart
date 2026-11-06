import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/features/media/data/services/r2_direct_uploader.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late R2DirectUploader uploader;
  late Directory tempDir;
  late File sampleFile;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() async {
    mockDio = MockDio();
    uploader = R2DirectUploader(
      dio: mockDio,
      endpoint: 'https://storage.vetmanager.test',
    );
    tempDir = await Directory.systemTemp.createTemp('r2_upload_test_');
    sampleFile = File('${tempDir.path}/sample.webp');
    await sampleFile.writeAsBytes([0x52, 0x49, 0x46, 0x46, 0x00]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('R2DirectUploader', () {
    test('uploads file via HTTP PUT with expected headers and checksum', () async {
      when(
        () => mockDio.put<dynamic>(
          'https://storage.vetmanager.test/media/tenant-abc/cases/case-1/sample.webp',
          data: any(named: 'data'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onProgress = invocation.namedArguments[#onSendProgress] as ProgressCallback?;
        onProgress?.call(2, 5);
        onProgress?.call(5, 5);
        return Response<dynamic>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        );
      });

      final progressList = <double>[];
      final url = await uploader.uploadFile(
        file: sampleFile,
        remotePath: 'media/tenant-abc/cases/case-1/sample.webp',
        mimeType: 'image/webp',
        tenantId: 'tenant-abc',
        checksumSha256: 'sha256-dummy-digest',
        onProgress: (p) => progressList.add(p),
      );

      expect(url, equals('https://storage.vetmanager.test/media/tenant-abc/cases/case-1/sample.webp'));
      expect(progressList, equals([0.4, 1.0]));

      verify(
        () => mockDio.put<dynamic>(
          'https://storage.vetmanager.test/media/tenant-abc/cases/case-1/sample.webp',
          data: any(named: 'data'),
          options: any(
            named: 'options',
            that: isA<Options>().having(
              (o) => o.headers,
              'headers',
              containsPair('Content-Type', 'image/webp'),
            ).having(
              (o) => o.headers,
              'headers',
              containsPair('X-Tenant-ID', 'tenant-abc'),
            ).having(
              (o) => o.headers,
              'headers',
              containsPair('X-Checksum-Sha256', 'sha256-dummy-digest'),
            ),
          ),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).called(1);
    });

    test('throws ServerException on 500 HTTP response', () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ));

      expect(
        () => uploader.uploadFile(
          file: sampleFile,
          remotePath: 'media/test.webp',
          mimeType: 'image/webp',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('maps Dio connection error to NetworkException', () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenThrow(DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => uploader.uploadFile(
          file: sampleFile,
          remotePath: 'media/test.webp',
          mimeType: 'image/webp',
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
