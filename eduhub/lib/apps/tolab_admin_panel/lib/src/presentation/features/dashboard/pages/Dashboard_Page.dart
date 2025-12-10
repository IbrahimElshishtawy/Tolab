// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../state/app_state.dart';
import '../../../../state/dashboard/dashboard_actions.dart';
import '../../../../state/dashboard/dashboard_state.dart';

import '../widgets/dashboard_top_bar.dart';
import '../widgets/dashboard_stat_cards.dart';
import '../widgets/dashboard_activity_list.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    StoreProvider.of<AppState>(
      context,
      listen: false,
    ).dispatch(LoadDashboardDataAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardState>(
      distinct: true,
      converter: (store) => store.state.dashboard,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const DashboardTopBar(),

                  const SizedBox(height: 20),

                  DashboardStatCards(state: state),

                  const SizedBox(height: 20),

                  Expanded(child: DashboardActivityList(state: state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
