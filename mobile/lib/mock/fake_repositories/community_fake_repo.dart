import '../fake_delay.dart';

class CommunityFakeRepo {
  Future<List<dynamic>> getPosts() async {
    await fakeDelay();
    return [];
  }
}
