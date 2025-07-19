import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/auth/controllers/register_controller.dart';
import 'package:tolab/Features/auth/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text(
                "إنشاء حساب",
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              iconTheme: IconThemeData(color: theme.iconTheme.color),
              elevation: 1,
              centerTitle: true,
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: const RegisterForm(),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
