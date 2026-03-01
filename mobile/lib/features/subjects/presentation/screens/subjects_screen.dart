import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../redux/app_state.dart';
import '../../data/models.dart';
import '../../redux/subjects_actions.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/app_scaffold.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Subject>>(
        onInit: (store) => store.dispatch(FetchSubjectsAction()),
        converter: (store) => store.state.subjectsState.subjects,
        builder: (context, subjects) {
          return AppScaffold(
            title: 'subjects_nav'.tr(),
            isEmpty: subjects.isEmpty,
            child: AnimationLimiter(
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
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 16),
                          onTap: () => context.push('/subjects/${subject.id}', extra: subject.name),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(subject.name, style: Theme.of(context).textTheme.titleLarge),
                            subtitle: Text(subject.code, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
  }
}
