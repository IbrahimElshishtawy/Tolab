// ignore_for_file: avoid_print

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

  try {
    await Supabase.initialize(
      url: "https://joaibmeegtvzoloekrzd.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpvYWlibWVlZ3R2em9sb2VrcnpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMTkzNjEsImV4cCI6MjA2Nzg5NTM2MX0.UjSrEmVVVYCWqf9tpO_lGmPFzjDVsEoLJYdZtYt5TSM",
    );
    print("✅ Supabase initialized");
  } catch (e) {
    print("❌ Supabase init error: $e");
  }

  // ✅ ربط app_links handler
  final appLinksHandler = AppLinksHandler();
  appLinksHandler.initialize(); // استدعاء الاستماع للرابط

  runApp(const TolabApp());
}

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

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
