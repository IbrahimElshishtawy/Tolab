// ignore_for_file: unnecessary_underscores

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tolab/page/chat/groups/widget/group_tile.dart';

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
        middle: const Text('الجروبات'),
        trailing: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/create-group');
          },
          child: const Icon(CupertinoIcons.add),
        ),
        backgroundColor: isDark ? CupertinoColors.black : CupertinoColors.white,
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
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
                  return GroupTile(
                    groupName: group['name'],
                    membersCount: group['members'],
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/group-settings',
                        arguments: group,
                      );
                    },
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
