import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tolab/core/config/User_Provider.dart';
import 'package:tolab/core/utils/network_service.dart';
import 'package:tolab/page/auth/controllers/log/login_controller.dart';
import 'package:tolab/page/posts/controllers/post_controllers.dart';
import 'package:tolab/page/settings/app_theme.dart';
import 'package:tolab/page/subjects/presentation/domain/models/subject_view_model.dart';
import 'package:tolab/routes/app_router.dart';
import 'package:tolab/page/splash/page/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final bool hasInternet = await NetworkService.checkInternetConnection();

  if (!hasInternet) {
    runApp(const NoInternetScreen());
    return;
  }

  final User? user = FirebaseAuth.instance.currentUser;
  final bool isLoggedIn = user != null && user.emailVerified;

  if (isLoggedIn) {
    await createSelfChatIfNotExists(user.uid);
  }

  runApp(TolabApp(isLoggedIn: isLoggedIn));
}

Future<void> createSelfChatIfNotExists(String userId) async {
  final chatRef = FirebaseFirestore.instance
      .collection('chats')
      .where('members', isEqualTo: [userId]);

  final snapshot = await chatRef.get();

  if (snapshot.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('chats').add({
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'isSelfChat': true,
    });
  }
}

class TolabApp extends StatelessWidget {
  final bool isLoggedIn;

  const TolabApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => PostsController()..fetchPosts()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SubjectViewModel("defaultId")),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: isLoggedIn ? '/home' : '/splash',
        onGenerateRoute: AppRouter.generateRoute,
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const SplashScreen()),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            "❌ لا يوجد اتصال بالإنترنت",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
