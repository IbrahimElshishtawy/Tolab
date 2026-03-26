import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    final current = await Connectivity().checkConnectivity();
    isOnline.value = !current.contains(ConnectivityResult.none);
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
    });
    return this;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
