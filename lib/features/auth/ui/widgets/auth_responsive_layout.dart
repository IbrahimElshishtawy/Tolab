import 'package:flutter/material.dart';

class AuthResponsiveLayout extends StatelessWidget {
  final Widget Function(bool isCompact) heroBuilder;
  final Widget form;

  const AuthResponsiveLayout({
    super.key,
    required this.heroBuilder,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isWide ? 48 : 20,
              24,
              isWide ? 48 : 20,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(child: heroBuilder(false)),
                          const SizedBox(width: 28),
                          Expanded(child: form),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heroBuilder(true),
                          const SizedBox(height: 20),
                          form,
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
