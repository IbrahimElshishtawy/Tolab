import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../redux/subjects_actions.dart';
import '../redux/subjects_state.dart';
import '../../../core/ui/widgets/state_view.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subjects')),
      body: StoreConnector<AppState, SubjectsState>(
        onInit: (store) => store.dispatch(FetchSubjectsAction()),
        converter: (store) => store.state.subjectsState,
        builder: (context, state) {
          return StateView(
            isLoading: state.isLoading,
            error: state.error,
            isEmpty: state.subjects.isEmpty,
            onRetry: () => StoreProvider.of<AppState>(context).dispatch(FetchSubjectsAction()),
            child: ListView.builder(
              itemCount: state.subjects.length,
              itemBuilder: (context, index) {
              final subject = state.subjects[index];
              return ListTile(
                title: Text(subject.name),
                subtitle: Text(subject.code),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/subjects/${subject.id}', extra: subject.name),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
