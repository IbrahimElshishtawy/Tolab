import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../../../state/app_state.dart';
import '../../../../state/auth/auth_actions.dart';
import '../../../../state/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.auth,
      distinct: true,
      onWillChange: (prev, current) {
        if (current.isloadingIn && !current.isloading) {
          Navigator.pushReplacementNamed(context, "/dashboard");
        }

        if (current.errorMessage != null && current.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(current.errorMessage!)));
        }
      },
      builder: (context, authState) {
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Admin Login",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  authState.isloading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            final email = emailController.text.trim();
                            final pass = passwordController.text.trim();

                            StoreProvider.of<AppState>(
                              context,
                            ).dispatch(LoginAction(email, pass));
                          },
                          child: Text("Login"),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
