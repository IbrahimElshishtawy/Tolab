import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class AddCommentField extends StatefulWidget {
  const AddCommentField({
    super.key,
    required this.onSubmit,
  });

  final Future<void> Function(String value) onSubmit;

  @override
  State<AddCommentField> createState() => _AddCommentFieldState();
}

class _AddCommentFieldState extends State<AddCommentField> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _controller,
            label: 'Add a comment',
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: _isSubmitting ? 'Sending...' : 'Send',
          onPressed: _isSubmitting
              ? null
              : () async {
                  if (_controller.text.trim().isEmpty) {
                    return;
                  }
                  setState(() => _isSubmitting = true);
                  await widget.onSubmit(_controller.text.trim());
                  _controller.clear();
                  if (mounted) {
                    setState(() => _isSubmitting = false);
                  }
                },
          isExpanded: false,
        ),
      ],
    );
  }
}
