import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> saveStudentModuleFile({
  required String fileName,
  required Uint8List bytes,
  required List<String> allowedExtensions,
}) async {
  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    bytes: bytes,
  );
  if (path == null || path.isEmpty) return null;
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
  return path;
}
