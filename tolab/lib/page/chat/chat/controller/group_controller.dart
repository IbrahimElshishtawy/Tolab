// groups/controllers/group_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// إنشاء جروب جديد
  Future<void> createGroup({
    required String groupName,
    required List<String> membersEmails,
  }) async {
    final currentUser = _auth.currentUser!;
    final groupRef = _firestore.collection('groups').doc();

    await groupRef.set({
      'id': groupRef.id,
      'name': groupName,
      'createdBy': currentUser.email,
      'members': [currentUser.email, ...membersEmails],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// جلب كل الجروبات اللي المستخدم عضو فيها
  Stream<QuerySnapshot> getUserGroups() {
    final currentUser = _auth.currentUser!;
    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUser.email)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// التحقق من إن المستخدم هو الـ Admin للجروب
  Future<bool> isUserAdmin(String groupId) async {
    final currentUser = _auth.currentUser!;
    final doc = await _firestore.collection('groups').doc(groupId).get();
    return doc['createdBy'] == currentUser.email;
  }

  /// إضافة عضو جديد للجروب
  Future<void> addMember(String groupId, String email) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([email]),
    });
  }

  /// حذف عضو من الجروب
  Future<void> removeMember(String groupId, String email) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([email]),
    });
  }

  /// حذف الجروب كاملًا (لـ Admin فقط)
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }
}
