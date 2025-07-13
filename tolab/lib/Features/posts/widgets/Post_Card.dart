// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String title; // ممكن يكون اسم الكاتب
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
                              // TODO: تنفيذ التعديل
                            } else if (value == 'delete') {
                              // TODO: تنفيذ الحذف
                            } else if (value == 'report') {
                              // TODO: تنفيذ الإبلاغ
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('✏️ Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('🗑️ Delete'),
                            ),
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('🚩 Report'),
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
