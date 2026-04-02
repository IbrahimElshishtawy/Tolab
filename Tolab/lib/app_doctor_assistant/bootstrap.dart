import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';

import 'app.dart';
import 'core/services/app_dependencies.dart';
import 'state/app_state.dart';
import 'state/store.dart';

Future<void> bootstrapDoctorAssistantApp() async {
  final dependencies = await AppDependencies.initialize();
  final Store<DoctorAssistantAppState> store = createDoctorAssistantStore(
    dependencies,
  );

  runApp(DoctorAssistantApp(store: store, dependencies: dependencies));
}
