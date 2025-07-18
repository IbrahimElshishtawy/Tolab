// ignore_for_file: avoid_print, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';
import 'package:tolab/Features/settings/app_theme.dart';
import 'package:tolab/routes/app_router.dart';
import 'package:tolab/core/services/app_links_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // try {
  //   await Supabase.initialize(
  //     url: "https://joaibmeegtvzoloekrzd.supabase.co",
  //     anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  //   );
  //   print("✅ Supabase initialized");
  // } catch (e) {
  //   print("❌ Supabase init error: $e");
  // }

  runApp(const TolabApp());
}

class TolabApp extends StatefulWidget {
  const TolabApp({super.key});

  @override
  State<TolabApp> createState() => _TolabAppState();
}

class _TolabAppState extends State<TolabApp> {
  final AppLinksHandler _appLinksHandler = AppLinksHandler();

  @override
  void initState() {
    super.initState();
    _appLinksHandler.initialize(); // ✅ تفعيل الاستماع للرابط عند بدء التطبيق
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostsController()..fetchPosts()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
