import 'package:flutter/material.dart';

class AdminOfferingsScreen extends StatelessWidget {
  const AdminOfferingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Offerings')),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text('Offering $index'),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.assignment_ind)),
    );
  }
}
