import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Bundle containing compressed file, byte metrics, and cryptographic integrity digest.
class CompressedImageResult {
  final File file;
  final int fileSizeBytes;
  final String checksumSha256;
  final String mimeType;

  const CompressedImageResult({
    required this.file,
    required this.fileSizeBytes,
    required this.checksumSha256,
    this.mimeType = 'image/webp',
  });
}

/// Service that optimizes raw device camera captures and radiographs into lightweight WebP format.
class ImageCompressionService {
  /// Compresses [sourceFile] into WebP format with clinical resolution preservation.
  Future<CompressedImageResult> compressImage({
    required File sourceFile,
    int quality = 85,
    int minWidth = 2048,
    int minHeight = 2048,
  }) async {
    final bytes = await sourceFile.readAsBytes();
    final originalChecksum = sha256.convert(bytes).toString();

    try {
      Directory outputDir;
      try {
        outputDir = await getTemporaryDirectory();
      } catch (_) {
        outputDir = sourceFile.parent;
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(sourceFile.path)}.webp';
      final targetPath = p.join(outputDir.path, fileName);

      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.webp,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedBytes = await compressedFile.readAsBytes();
        final checksum = sha256.convert(compressedBytes).toString();
        return CompressedImageResult(
          file: compressedFile,
          fileSizeBytes: compressedBytes.length,
          checksumSha256: checksum,
          mimeType: 'image/webp',
        );
      }
    } catch (_) {
      // Graceful fallback to original file on environments without platform channel implementation
    }

    return CompressedImageResult(
      file: sourceFile,
      fileSizeBytes: bytes.length,
      checksumSha256: originalChecksum,
      mimeType: _inferMimeType(sourceFile.path),
    );
  }

  static String _inferMimeType(String path) {
    final ext = p.extension(path).toLowerCase();
    switch (ext) {
      case '.webp':
        return 'image/webp';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
