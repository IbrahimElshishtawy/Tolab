import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../../../../redux/state/admin_state.dart';
import '../../redux/admin_actions.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';

class AdminSubjectsScreen extends StatelessWidget {
  const AdminSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AdminState>(
      onInit: (store) => store.dispatch(FetchAdminSubjectsAction()),
      converter: (store) => store.state.adminState,
      builder: (context, state) {
        return AppScaffold(
          title: 'Subjects',
          isLoading: state.isLoading && state.subjects.isEmpty,
          error: state.error,
          onRetry: () => StoreProvider.of<AppState>(context).dispatch(FetchAdminSubjectsAction()),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: state.subjects.length,
            itemBuilder: (context, index) {
              final subject = state.subjects[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(subject['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subject['code'] ?? ''),
                  trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
