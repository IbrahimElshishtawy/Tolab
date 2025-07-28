import 'package:flutter/material.dart';

// صفحات المصادقة
import 'package:tolab/page/auth/pages/forgot_password_page.dart';
import 'package:tolab/page/auth/pages/verify_email_page.dart';
import 'package:tolab/page/auth/pages/login_page.dart';
import 'package:tolab/page/auth/pages/register_page.dart';
import 'package:tolab/page/auth/pages/set_new_password_page.dart';
import 'package:tolab/page/auth/pages/choose_role_page.dart';
import 'package:tolab/page/chat/home/home_chat_page.dart';

// صفحات عامة
import 'package:tolab/page/splash/page/splash_page.dart';
import 'package:tolab/page/home/home_page.dart';
import 'package:tolab/page/profile/page/profile_page.dart';

// صفحات البوستات
import 'package:tolab/page/posts/pages/Add_Post_Page.dart';
import 'package:tolab/page/posts/pages/Edit_Post_Page.dart';
import 'package:tolab/page/posts/pages/Notifications_Page.dart';

// صفحات المحادثات الجماعية
import 'package:tolab/page/chat/groups/pages/create_group_page.dart';
import 'package:tolab/page/chat/groups/pages/group_chat_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/choose-role':
        return MaterialPageRoute(builder: (_) => const ChooseRolePage());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case '/verify-code':
        return MaterialPageRoute(builder: (_) => const VerifyCodePage());

      case '/set-new-password':
        return MaterialPageRoute(builder: (_) => SetNewPasswordPage());

      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());

      case '/add-post':
        return MaterialPageRoute(builder: (_) => const AddPostPage());

      case '/edit-post':
        return MaterialPageRoute(builder: (_) => const EditPostPage());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

      // ✅ صفحات الشات الجماعي
      case '/group-chat':
        // تأكد من إرسال groupId و groupName في settings.arguments
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GroupChatPage(
            groupId: args['groupId'],
            groupName: args['groupName'],
          ),
        );

      case '/create-group':
        return MaterialPageRoute(builder: (_) => const CreateGroupPage());

      case '/home-chat':
        return MaterialPageRoute(builder: (_) => const HomeChatPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('❌ Page not found'))),
        );
    }
  }
}
