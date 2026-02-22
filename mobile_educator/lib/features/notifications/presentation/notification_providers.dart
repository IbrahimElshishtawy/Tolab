import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(3);

  void reset() => state = 0;
  void increment() => state++;
}

final unreadNotificationsProvider = StateNotifierProvider<NotificationCountNotifier, int>((ref) => NotificationCountNotifier());
