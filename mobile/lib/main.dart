import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:tolab_fci/core/localization/localization_manager.dart';
import 'package:tolab_fci/core/routing/app_router.dart';
import 'package:tolab_fci/redux/app_state.dart';
import 'package:tolab_fci/redux/reducers.dart';
import 'package:tolab_fci/redux/middleware.dart';

// --- Redux Store ---

Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      thunkMiddleware,
      ...createMiddlewares(),
    ],
  );
}

// --- App Root ---

class App extends StatelessWidget {
  final Store<AppState> store;

  const App({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'LMS Platform',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// --- Main Entry ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization with English by default
  await LocalizationManager.load('en');

  final store = createStore();
  runApp(App(store: store));
}
