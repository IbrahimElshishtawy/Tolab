// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final String title;
  final String content;
  final String author;
  final String date;
  final int views;
  final int likes;

  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.views,
    required this.likes,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes;
  }

  void navigateToStatsPage(BuildContext context) {
    Navigator.pushNamed(context, '/stats'); // ممكن تضيف postId لو عندك
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🟠 الصف العلوي: الصورة والاسم والتاريخ
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color.fromRGBO(152, 172, 201, 1),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.author,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      '/edit-post',
                      arguments: widget,
                    );
                  } else if (value == 'delete') {
                    // هنا ممكن تضيف منطق الحذف
                  } else if (value == 'report') {
                    // هنا ممكن تضيف منطق الإبلاغ
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('✏️ تعديل')),
                  const PopupMenuItem(value: 'delete', child: Text('🗑️ حذف')),
                  const PopupMenuItem(value: 'report', child: Text('🚩 إبلاغ')),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 📝 العنوان والمحتوى
          if (widget.title.isNotEmpty)
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (widget.title.isNotEmpty) const SizedBox(height: 6),

          Text(widget.content, style: theme.textTheme.bodyMedium),

          const SizedBox(height: 12),

          /// 🔘 التفاعلات (لف + مشاركة)
          Row(
            children: [
              /// ❤️ زر اللف + عدد اللفات
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                    likeCount += isLiked ? 1 : -1;
                  });
                },
              ),
              Text('$likeCount'),

              const SizedBox(width: 16),

              /// 📤 زر المشاركة
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share('${widget.content}\n\n- ${widget.author}');
                },
              ),
            ],
          ),

          /// 👁️ عدد المشاهدات (يؤدي إلى صفحة الإحصائيات)
          GestureDetector(
            onTap: () => navigateToStatsPage(context),
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${widget.views} مشاهدة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(thickness: 0.6, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
