import 'package:flutter/material.dart';
import 'app.dart';
import 'redux/store.dart';
import 'core/localization/localization_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationManager.load('en');

  final store = createStore();
  runApp(App(store: store));
}
