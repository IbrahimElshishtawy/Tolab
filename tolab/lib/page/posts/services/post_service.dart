import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab/models/post_model.dart';

class PostService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// جلب كل البوستات
  Future<List> fetchPostsFromBackend() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PostModel.fromJson(doc.data()..['id'] = doc.id);
    }).toList();
  }

  /// إضافة بوست جديد
  Future<void> addPostToBackend(PostModel post) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('posts').add({
      'content': post.content,
      'authorId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// حذف بوست معين (لو المستخدم هو اللي كتبه)
  Future<void> deletePostFromBackend(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('posts').doc(id).get();
    if (doc.exists && doc['authorId'] == user.uid) {
      await _firestore.collection('posts').doc(id).delete();
    } else {
      throw Exception('Permission denied: you can only delete your own posts.');
    }
  }
}
