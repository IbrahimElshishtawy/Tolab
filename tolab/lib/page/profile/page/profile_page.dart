// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            userData = snapshot.data() as Map<String, dynamic>?;
          });
        }
      } catch (e) {
        print("حدث خطأ أثناء جلب البيانات: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("فشل في الاتصال، تأكد من الاتصال بالإنترنت"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditProfilePage(userData: userData)),
              // );
              fetchUserData();
            },
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueGrey,
                        child: Text(
                          userData!["name"] != null
                              ? userData!["name"][0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        userData!["name"] ?? "الاسم غير متوفر",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "البريد الإلكتروني: ${user!.email}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  if (userData!["phone"] != null)
                    Text(
                      "رقم الهاتف: ${userData!["phone"]}",
                      style: const TextStyle(fontSize: 18),
                    ),
                ],
              ),
            ),
    );
  }
}
