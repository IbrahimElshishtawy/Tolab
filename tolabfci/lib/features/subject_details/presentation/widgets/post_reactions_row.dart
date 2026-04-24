import 'package:flutter/material.dart';

class PostReactionsRow extends StatelessWidget {
  const PostReactionsRow({
    super.key,
    required this.reactions,
    required this.commentCount,
    required this.onReact,
    required this.onCommentsTap,
  });

  final int reactions;
  final int commentCount;
  final VoidCallback onReact;
  final VoidCallback onCommentsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onReact,
          icon: const Icon(Icons.favorite_border_rounded),
          label: Text('$reactions تفاعل'),
        ),
        TextButton.icon(
          onPressed: onCommentsTap,
          icon: const Icon(Icons.mode_comment_outlined),
          label: Text('$commentCount تعليق'),
        ),
      ],
    );
  }
}
