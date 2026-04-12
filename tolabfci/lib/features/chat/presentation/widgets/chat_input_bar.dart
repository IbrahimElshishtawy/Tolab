import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
  });

  final bool isSending;
  final Future<void> Function(String content) onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

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
            label: 'Message',
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: widget.isSending ? 'Sending...' : 'Send',
          onPressed: widget.isSending
              ? null
              : () async {
                  final content = _controller.text.trim();
                  if (content.isEmpty) {
                    return;
                  }
                  await widget.onSend(content);
                  _controller.clear();
                },
          isExpanded: false,
        ),
      ],
    );
  }
}
