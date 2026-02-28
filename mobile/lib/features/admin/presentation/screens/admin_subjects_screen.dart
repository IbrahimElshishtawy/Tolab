import 'package:flutter/material.dart';

class AdminSubjectsScreen extends StatelessWidget {
  const AdminSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text('Subject $index'),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
