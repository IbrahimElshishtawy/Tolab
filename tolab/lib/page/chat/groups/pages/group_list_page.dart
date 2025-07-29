// ignore_for_file: unnecessary_underscores

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final List<Map<String, dynamic>> allGroups = [
    {'name': 'جروب مشاريع IT', 'members': 15},
    {'name': 'شات دكاترة المادة', 'members': 6},
    {'name': 'دفعة 2025', 'members': 25},
    {'name': 'جروب Flutter', 'members': 10},
  ];

  List<Map<String, dynamic>> filteredGroups = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredGroups = allGroups;
    searchController.addListener(_filterGroups);
  }

  void _filterGroups() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredGroups = allGroups.where((group) {
        final groupName = group['name'].toLowerCase();
        return groupName.contains(query);
      }).toList();
    });
  }

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: searchController,
                placeholder: 'ابحث عن جروب...',
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredGroups.length,
                separatorBuilder: (_, __) => SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
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
          ],
        ),
      ),
    );
  }
}
