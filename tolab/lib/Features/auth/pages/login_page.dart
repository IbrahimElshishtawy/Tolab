import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/posts/controllers/post_controllers.dart';
import 'package:tolab/Features/auth/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late PostsController _postsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _postsController = Provider.of<PostsController>(context, listen: false);
  }

  @override
  void dispose() {
    _postsController.dispose(); // ✅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 110),
                  Column(
                    children: [
                      Image.asset(
                        'assets/image_App/Tolab.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ToLab',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 14, 28, 226),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  const Text(
                    'Login to your account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const LoginForm(),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
