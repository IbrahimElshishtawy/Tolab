import '../fake_delay.dart';

class CalendarFakeRepo {
  Future<List<dynamic>> getEvents() async {
    await fakeDelay();
    return [];
  }
}
