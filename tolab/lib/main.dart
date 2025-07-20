import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tolab/Features/auth/controllers/login_controller.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';
import 'package:tolab/Features/settings/app_theme.dart';
import 'package:tolab/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TolabApp());
}

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => PostsController()..fetchPosts()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
