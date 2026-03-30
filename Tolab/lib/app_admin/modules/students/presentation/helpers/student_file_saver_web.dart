import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<String?> saveStudentModuleFile({
  required String fileName,
  required Uint8List bytes,
  required List<String> allowedExtensions,
}) {
  return FilePicker.platform.saveFile(
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: allowedExtensions,
    bytes: bytes,
  );
}
