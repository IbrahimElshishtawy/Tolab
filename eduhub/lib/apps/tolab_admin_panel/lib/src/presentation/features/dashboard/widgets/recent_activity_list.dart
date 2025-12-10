// TODO Implement this library.
import 'package:flutter/material.dart';
import '../../../../state/dashboard/dashboard_state.dart';

class RecentActivityList extends StatelessWidget {
  final DashboardState state;

  const RecentActivityList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: state.recentActivity.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.yellowAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.recentActivity[index],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
