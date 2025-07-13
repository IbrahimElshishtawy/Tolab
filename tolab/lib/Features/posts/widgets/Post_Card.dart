// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String date;

  const PostCard({
    super.key,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🟠 الصف العلوي: صورة + اسم + تاريخ + ثلاث نقاط
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color.fromRGBO(152, 172, 201, 1),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔵 الاسم + التاريخ + النقاط
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            author,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // تنفيذ التعديل
                            } else if (value == 'delete') {
                              // تنفيذ الحذف
                            } else if (value == 'report') {
                              // تنفيذ الإبلاغ
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('✏️ تعديل'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('🗑️ حذف'),
                            ),
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('🚩 إبلاغ'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// 📝 محتوى البوست
                    Text(content, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔘 أزرار المشاركة والإعجاب
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share('$content\n\n- $author');
                },
              ),
            ],
          ),

          /// 🔻 خط سفلي + ظل
          Container(height: 1, color: Colors.grey.withOpacity(0.2)),
          Container(
            height: 4,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
