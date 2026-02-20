import 'package:flutter/material.dart';
import 'app.dart';
import 'redux/store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = createStore();
  runApp(App(store: store));
}
