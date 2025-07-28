import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupListPage extends StatelessWidget {
  final List<Map<String, dynamic>> dummyGroups = [
    {'name': 'جروب مشاريع IT', 'members': 15},
    {'name': 'شات دكاترة المادة', 'members': 6},
    {'name': 'دفعة 2025', 'members': 25},
  ];

  GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('الجروبات'),
        trailing: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/create-group');
          },
          child: Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dummyGroups.length,
          separatorBuilder: (_, __) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final group = dummyGroups[index];
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/group-chat',
                  arguments: group['name'],
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? CupertinoColors.darkBackgroundGray
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.group_solid,
                      color: CupertinoColors.activeBlue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${group['members']} أعضاء',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
