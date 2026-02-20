import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../redux/calendar_actions.dart';
import '../redux/calendar_state.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CalendarState>(
      onInit: (store) => store.dispatch(FetchEventsAction()),
      converter: (store) => store.state.calendarState,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Schedule')),
          body: Column(
            children: [
              _buildCalendarHeader(),
              Expanded(
                child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.events.length,
                      itemBuilder: (context, index) {
                        final event = state.events[index];
                        return _buildScheduleItem(
                          context,
                          event['start_at'].split('T')[1].substring(0, 5),
                          event['title'],
                          event['location'],
                          route: event['deep_link'],
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
          final isToday = index == 2; // Mock Wednesday as today
          return Column(
            children: [
              Text(days[index], style: TextStyle(color: isToday ? Colors.blue : Colors.grey)),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: isToday ? Colors.blue : Colors.transparent,
                child: Text('${15 + index}', style: TextStyle(color: isToday ? Colors.white : Colors.black)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, String time, String title, String location, {String? route}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(time.split(' ')[1], style: const TextStyle(fontSize: 10)),
          ],
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (route != null) {
            GoRouter.of(context).push(route);
          }
        },
      ),
    );
  }
}
