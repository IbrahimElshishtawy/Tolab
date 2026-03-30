import 'dart:typed_data';

import 'student_file_saver_stub.dart'
    if (dart.library.html) 'student_file_saver_web.dart'
    if (dart.library.io) 'student_file_saver_io.dart'
    as saver;

Future<String?> saveStudentModuleFile({
  required String fileName,
  required Uint8List bytes,
  required List<String> allowedExtensions,
}) {
  return saver.saveStudentModuleFile(
    fileName: fileName,
    bytes: bytes,
    allowedExtensions: allowedExtensions,
  );
}
