import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../redux/auth_actions.dart';
import '../redux/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: StoreConnector<AppState, AuthState>(
            converter: (store) => store.state.authState,
            onWillChange: (oldState, newState) {
              if (newState.isAuthenticated) {
                context.go('/home');
              }
              if (newState.error != null && newState.error != oldState?.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(newState.error!)),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LMS Login',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            StoreProvider.of<AppState>(context).dispatch(
                              LoginAction(emailController.text, passwordController.text),
                            );
                          },
                    child: state.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
