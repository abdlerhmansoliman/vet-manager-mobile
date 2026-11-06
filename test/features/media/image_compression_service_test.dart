import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_manager_mobile/features/media/data/services/image_compression_service.dart';

void main() {
  late ImageCompressionService service;
  late Directory tempDir;

  setUp(() async {
    service = ImageCompressionService();
    tempDir = await Directory.systemTemp.createTemp('media_compress_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ImageCompressionService', () {
    test('computes correct sha256 checksum and file size on image file', () async {
      final sampleBytes = utf8.encode('veterinary-radiograph-raw-pixel-data-12345');
      final expectedChecksum = sha256.convert(sampleBytes).toString();

      final file = File('${tempDir.path}/test_radiograph.jpg');
      await file.writeAsBytes(sampleBytes);

      final result = await service.compressImage(sourceFile: file);

      expect(result.file.path, equals(file.path));
      expect(result.fileSizeBytes, equals(sampleBytes.length));
      expect(result.checksumSha256, equals(expectedChecksum));
      expect(result.mimeType, equals('image/jpeg'));
    });

    test('infers correct mime types for various image extensions', () async {
      final pngFile = File('${tempDir.path}/ultrasound.png');
      await pngFile.writeAsBytes([1, 2, 3, 4]);
      final pngResult = await service.compressImage(sourceFile: pngFile);
      expect(pngResult.mimeType, equals('image/png'));

      final webpFile = File('${tempDir.path}/dental.webp');
      await webpFile.writeAsBytes([5, 6, 7]);
      final webpResult = await service.compressImage(sourceFile: webpFile);
      expect(webpResult.mimeType, equals('image/webp'));

      final gifFile = File('${tempDir.path}/animation.gif');
      await gifFile.writeAsBytes([8, 9]);
      final gifResult = await service.compressImage(sourceFile: gifFile);
      expect(gifResult.mimeType, equals('image/gif'));
    });
  });
}
