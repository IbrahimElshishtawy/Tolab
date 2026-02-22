import 'package:flutter/material.dart';
import '../../../core/validators/app_validators.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _filter = 'All posts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tolab Community')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hello Dr. Ahmed', style: TextStyle(color: Colors.grey)),
                DropdownButton<String>(
                  value: _filter,
                  items: ['Oldest', 'All posts', 'Newest'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _filter = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => _buildPostCard(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Dr. Sarah Smith'),
            subtitle: const Text('2 hours ago'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Does anyone have the notes for the last Software Engineering lecture?'),
          ),
          ButtonBar(
            children: [
              IconButton(onPressed: () {}, icon: const Text('👍 5')),
              IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
              const Text('2 comments'),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Create New Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(maxLines: 4, decoration: const InputDecoration(labelText: 'Post Content', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add Post')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
