import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../redux/subjects_actions.dart';
import '../../../../core/localization/localization_manager.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('subjects_nav'.tr())),
      body: StoreConnector<AppState, List<Subject>>(
        onInit: (store) => store.dispatch(FetchSubjectsAction()),
        converter: (store) => store.state.subjectsState.subjects,
        builder: (context, subjects) {
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(subject.code, style: const TextStyle(color: Colors.blue)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/subjects/${subject.id}', extra: subject.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
