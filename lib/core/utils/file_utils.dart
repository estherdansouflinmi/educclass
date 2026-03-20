// lib/core/utils/file_utils.dart
class FileUtils {
  FileUtils._();

  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static bool isValidFileSize(int bytes) => bytes <= maxFileSizeBytes;

  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  static bool isPdf(String fileName) => getFileExtension(fileName) == 'pdf';

  static String getStoragePath({
    required String classroomId,
    required String folder,
    required String fileName,
  }) {
    return 'classrooms/$classroomId/$folder/$fileName';
  }
}
