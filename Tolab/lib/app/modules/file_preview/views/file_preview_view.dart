import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/state_views.dart';

class FilePreviewView extends StatelessWidget {
  const FilePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      appBar: PremiumAppBar(title: 'File preview'),
      body: AppEmptyView(
        title: 'Preview placeholder',
        subtitle:
            'Hook your file renderer or WebView/PDF viewer here once backend file URLs are ready.',
      ),
    );
  }
}
