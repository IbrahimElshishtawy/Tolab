Future<void> fakeDelay([int milliseconds = 800]) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}
