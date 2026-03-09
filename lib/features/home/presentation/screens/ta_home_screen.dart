import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../redux/app_state.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../../../../core/ui/widgets/university_widgets.dart';
import '../../../../core/ui/widgets/business_widgets.dart';
import '../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../core/ui/tokens/color_tokens.dart';

class TaHomeScreen extends StatelessWidget {
  const TaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.authState.email,
      builder: (context, email) {
        final userName = email?.split('@').first ?? 'TA';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    userName: userName.toUpperCase(),
                    role: 'Teaching Assistant',
                  ),
                  const SearchBarWidget(hintText: 'Search labs or students...'),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'Laboratory Status'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.l),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.biotech_rounded, color: AppColors.success),
                          ),
                          const SizedBox(width: AppSpacing.l),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Next Session: Data Structures', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Lab 402 • Starts in 15 mins', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                          AppButton(
                            text: 'Enter',
                            isTonal: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    child: SectionHeader(title: 'TA Toolbelt'),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                    mainAxisSpacing: AppSpacing.m,
                    crossAxisSpacing: AppSpacing.m,
                    childAspectRatio: 1.5,
                    children: [
                      _buildTaAction(context, 'Grades', Icons.grading_rounded, Colors.teal),
                      _buildTaAction(context, 'Queries', Icons.forum_rounded, Colors.indigo),
                      _buildTaAction(context, 'Attendance', Icons.fact_check_rounded, Colors.deepOrange),
                      _buildTaAction(context, 'Calendar', Icons.event_note_rounded, Colors.brown),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaAction(BuildContext context, String label, IconData icon, Color color) {
    return AppCard(
      onTap: () {},
      color: color.withOpacity(0.05),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
