import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../redux/subjects_actions.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/ui/widgets/university_widgets.dart';

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
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: UniversityCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        onTap: () => context.push('/subjects/${subject.id}', extra: subject.name),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(subject.name, style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text(subject.code, style: const TextStyle(color: Colors.blue)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
