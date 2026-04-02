import 'package:flutter/widgets.dart';

import 'app_doctor_assistant/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapDoctorAssistantApp();
}
