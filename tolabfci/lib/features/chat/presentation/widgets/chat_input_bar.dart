import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
    this.compact = false,
  });

  final bool isSending;
  final bool compact;
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
    final sendButton = IconButton.filled(
      tooltip: 'إرسال / Send',
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
      icon: widget.isSending
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send_rounded, size: 18),
    );

    return Row(
      children: [
        IconButton(
          tooltip: 'إرفاق ملف / Attach',
          onPressed: () {},
          icon: const Icon(Icons.attach_file_rounded, size: 20),
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: widget.compact ? 2 : 3,
            decoration: const InputDecoration(
              hintText: 'اكتب رسالة للمجموعة...',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onSubmitted: widget.isSending
                ? null
                : (value) async {
                    final content = value.trim();
                    if (content.isEmpty) {
                      return;
                    }
                    await widget.onSend(content);
                    _controller.clear();
                  },
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        sendButton,
      ],
    );
  }
}
