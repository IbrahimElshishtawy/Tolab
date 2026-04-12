import 'package:flutter/material.dart';

class ResultsHeader extends StatelessWidget {
  const ResultsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Results', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'Track academic performance by subject with a layout that scales across screen sizes.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
