import 'package:equatable/equatable.dart';

/// Domain entity representing a diagnostic medical image, radiograph, or clinical photograph.
class DiagnosticImageEntity extends Equatable {
  final String id;
  final String imageableType;
  final String imageableId;
  final String url;
  final String? localPath;
  final String? title;
  final String mimeType;
  final int fileSizeBytes;
  final DateTime createdAt;

  const DiagnosticImageEntity({
    required this.id,
    required this.imageableType,
    required this.imageableId,
    required this.url,
    this.localPath,
    this.title,
    this.mimeType = 'image/webp',
    required this.fileSizeBytes,
    required this.createdAt,
  });

  bool get isLocalOnly =>
      url.startsWith('file:') ||
      url.startsWith('/') ||
      (localPath != null && localPath!.isNotEmpty && (url.isEmpty || !url.startsWith('http')));

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedSize => formattedFileSize;

  factory DiagnosticImageEntity.fromJson(Map<String, dynamic> json) {
    return DiagnosticImageEntity(
      id: json['id'] as String,
      imageableType: json['imageable_type'] as String? ?? 'clinical_case',
      imageableId: json['imageable_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      localPath: json['local_path'] as String?,
      title: json['title'] as String?,
      mimeType: json['mime_type'] as String? ?? 'image/webp',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageable_type': imageableType,
      'imageable_id': imageableId,
      'url': url,
      if (localPath != null) 'local_path': localPath,
      if (title != null) 'title': title,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DiagnosticImageEntity copyWith({
    String? id,
    String? imageableType,
    String? imageableId,
    String? url,
    String? localPath,
    String? title,
    String? mimeType,
    int? fileSizeBytes,
    DateTime? createdAt,
  }) {
    return DiagnosticImageEntity(
      id: id ?? this.id,
      imageableType: imageableType ?? this.imageableType,
      imageableId: imageableId ?? this.imageableId,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      title: title ?? this.title,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        imageableType,
        imageableId,
        url,
        localPath,
        title,
        mimeType,
        fileSizeBytes,
        createdAt,
      ];
}
