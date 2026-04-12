import 'package:flutter/material.dart';

import '../../../../core/widgets/adaptive_page_container.dart';
import '../widgets/verify_national_id_form.dart';

class VerifyNationalIdPage extends StatelessWidget {
  const VerifyNationalIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AdaptivePageContainer(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520),
              child: const VerifyNationalIdForm(),
            ),
          ),
        ),
      ),
    );
  }
}

