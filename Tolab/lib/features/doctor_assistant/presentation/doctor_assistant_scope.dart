import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../app/core/app_scope.dart';
import '../../../app_doctor_assistant/state/app_state.dart';

class DoctorAssistantScope extends StatelessWidget {
  const DoctorAssistantScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<DoctorAssistantAppState>(
      store: AppScope.read(context).doctorStore,
      child: child,
    );
  }
}
