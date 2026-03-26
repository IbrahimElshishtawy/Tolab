import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../errors/app_exception.dart';

class UploadSelection {
  const UploadSelection({
    required this.name,
    required this.bytes,
    required this.size,
    this.path,
    this.extension,
  });

  final String name;
  final List<int> bytes;
  final int size;
  final String? path;
  final String? extension;
}

class UploadService extends GetxService {
  static const int maxFileSize = 15 * 1024 * 1024;

  Future<UploadSelection?> pickFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.size > maxFileSize) {
      throw const AppException('Selected file exceeds the 15 MB limit.');
    }
    final bytes =
        file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      throw const AppException('Unable to read the selected file.');
    }

    return UploadSelection(
      name: file.name,
      bytes: bytes,
      size: file.size,
      path: file.path,
      extension: file.extension,
    );
  }
}
