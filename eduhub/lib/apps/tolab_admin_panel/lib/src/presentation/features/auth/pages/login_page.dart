// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../state/app_state.dart';
import '../../../../state/auth/auth_state.dart';

import '../widgets/animated_login_background.dart';
import '../widgets/login_hero_card.dart';

class LoginPage_Dashboard extends StatelessWidget {
  const LoginPage_Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AuthState>(
      converter: (store) => store.state.auth,
      distinct: true,

      onWillChange: (previous, current) {
        //
        // ========= SUCCESS: Redirect to Dashboard =========
        //
        if (current.isloadingIn && !(previous?.isloadingIn ?? false)) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, "/dashboard");
          });
        }

        //
        // ========= ERROR: Show snackbar =========
        //
        final error = current.errorMessage;
        if (error != null &&
            error.isNotEmpty &&
            error != previous?.errorMessage) {
          Future.microtask(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
            );
          });
        }
      },

      builder: (context, authState) {
        return Scaffold(
          body: Stack(
            children: [
              const AnimatedLoginBackground(),

              Center(child: LoginHeroCard(isLoading: authState.isloading)),
            ],
          ),
        );
      },
    );
  }
}
