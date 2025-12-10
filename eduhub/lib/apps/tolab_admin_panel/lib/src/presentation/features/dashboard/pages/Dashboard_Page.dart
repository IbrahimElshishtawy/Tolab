// ignore_for_file: file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../state/app_state.dart';
import '../../../../state/dashboard/dashboard_state.dart';
import '../../../../state/dashboard/dashboard_selectors.dart';

import '../widgets/stats_cards.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/dashboard_top_bar.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DashboardState>(
      converter: (store) => selectDashboardState(store.state),
      onInit: (store) {
        store.dispatch(LoadDashboardDataAction());
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -------------------
                  // TOP BAR
                  // -------------------
                  const DashboardTopBar(),
                  const SizedBox(height: 20),

                  // -------------------
                  // STATS CARDS
                  // -------------------
                  StatsCards(state: state),
                  const SizedBox(height: 30),

                  // -------------------
                  // QUICK ACTIONS
                  // -------------------
                  const QuickActions(),
                  const SizedBox(height: 24),

                  // -------------------
                  // RECENT ACTIVITY
                  // -------------------
                  Expanded(child: RecentActivityList(state: state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
