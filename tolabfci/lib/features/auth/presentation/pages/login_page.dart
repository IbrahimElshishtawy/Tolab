import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AdaptivePageContainer(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.isDesktop ? 560 : 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  LoginHeader(),
                  SizedBox(height: AppSpacing.xl),
                  LoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

