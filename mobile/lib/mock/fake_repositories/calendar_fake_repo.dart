import '../fake_delay.dart';

import '../mock_data.dart';

class CalendarFakeRepo {
  Future<List<dynamic>> getEvents() async {
    await fakeDelay();
    return mockCalendarEventsData;
  }
}
