import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGroupMembersPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const EditGroupMembersPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<EditGroupMembersPage> createState() => _EditGroupMembersPageState();
}

class _EditGroupMembersPageState extends State<EditGroupMembersPage> {
  List<String> members = [];

  final TextEditingController _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final snapshot = await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get();
    final data = snapshot.data();
    if (data != null && data['members'] != null) {
      setState(() {
        members = List<String>.from(data['members']);
      });
    }
  }

  Future<void> _removeMember(String email) async {
    members.remove(email);
    await _firestore.collection('groups').doc(widget.groupId).update({
      'members': members,
    });
    setState(() {});
  }

  Future<void> _addMember(String email) async {
    if (!members.contains(email)) {
      members.add(email);
      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': members,
      });
      _emailController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل أعضاء ${widget.groupName}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'أدخل بريد عضو جديد',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addMember(_emailController.text.trim()),
                ),
              ],
            ),
          ),
          const Divider(),
          const Text(
            'الأعضاء الحاليين:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final email = members[index];
                return ListTile(
                  title: Text(email),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeMember(email),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
