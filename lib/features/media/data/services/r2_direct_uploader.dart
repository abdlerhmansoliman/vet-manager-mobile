import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/config/app_env.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/error_interceptor.dart';
import '../../../../core/network/tenant_interceptor.dart';

/// Direct HTTP uploader to Cloudflare R2 / S3 Object Storage for veterinary diagnostics.
class R2DirectUploader {
  final Dio _dio;
  final String _endpoint;

  R2DirectUploader({
    Dio? dio,
    String? endpoint,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(minutes: 3),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _endpoint = endpoint ?? AppEnv.r2StorageEndpoint;

  String get endpoint => _endpoint;

  /// Uploads [file] directly to object storage via HTTP PUT stream.
  ///
  /// Emits transfer progress via [onProgress] (0.0 to 1.0).
  /// Returns the permanent canonical media URL.
  Future<String> uploadFile({
    required File file,
    required String remotePath,
    required String mimeType,
    String? tenantId,
    String? checksumSha256,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final sanitizedPath = remotePath.startsWith('/') ? remotePath.substring(1) : remotePath;
      final fullUrl = '$_endpoint/$sanitizedPath';
      final fileLength = await file.length();

      final headers = <String, dynamic>{
        'Content-Type': mimeType,
        'Content-Length': fileLength,
        if (tenantId != null && tenantId.isNotEmpty) TenantInterceptor.headerTenantId: tenantId,
        if (checksumSha256 != null) 'X-Checksum-Sha256': checksumSha256,
      };

      final fileStream = file.openRead();

      final response = await _dio.put<dynamic>(
        fullUrl,
        data: fileStream,
        options: Options(
          headers: headers,
        ),
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode != null && (response.statusCode! >= 200 && response.statusCode! < 300)) {
        return fullUrl;
      } else {
        throw ServerException(
          message: 'Object storage upload failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorInterceptor.parseDioException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(message: 'Failed to stream media to cloud storage: $e');
    }
  }
}
