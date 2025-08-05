import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final String groupName;
  final int membersCount;
  final VoidCallback onTap;

  const GroupTile({
    super.key,
    required this.groupName,
    required this.membersCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
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
            Icon(CupertinoIcons.group_solid, color: CupertinoColors.activeBlue),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$membersCount أعضاء',
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
  }
}
