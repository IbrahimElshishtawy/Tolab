import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tolab/page/auth/widgets/role/role_details_state.dart';

class RoleDetailsCubit extends Cubit<RoleDetailsState> {
  RoleDetailsCubit() : super(RoleDetailsInitial());

  Future<void> saveRoleDetails({
    required String role,
    required String nationalId,
    String? name,
    String? year,
    String? department,
  }) async {
    emit(RoleDetailsLoading());
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(RoleDetailsError("لم يتم العثور على المستخدم"));
      return;
    }
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'role': role.toLowerCase(), // 'dr' أو 'ta' أو 'student'
        'nationalId': nationalId,
        if (name != null && name.isNotEmpty) 'name': name,
        if (role == "Student") 'year': year,
        if (role == "Student") 'department': department,
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      emit(RoleDetailsSuccess());
    } catch (e) {
      emit(RoleDetailsError("حدث خطأ أثناء الحفظ"));
    }
  }
}

// داخل RoleDetail
