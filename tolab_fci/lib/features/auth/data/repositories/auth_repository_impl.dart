import 'package:firebase_auth/firebase_auth.dart';
import 'package:tolab_fci/features/auth/data/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';
import '../datasources/auth_role_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthRoleDataSource roleDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.roleDataSource,
  });

  @override
  Future<AuthUser> signInWithMicrosoft(String selectedRole) async {
    final UserCredential userCredential = await remoteDataSource
        .signInWithMicrosoft();

    final User? user = userCredential.user;
    if (user == null || user.email == null) {
      throw Exception('فشل تسجيل الدخول');
    }

    final String email = user.email!.toLowerCase();
    const allowedDomain = 'tanta.edu.eg';
    if (!email.endsWith(allowedDomain)) {
      throw Exception('يجب استخدام البريد الإلكتروني الجامعي فقط');
    }

    final String role = await roleDataSource.resolveUserRole(
      user,
      selectedRole,
    );
    return AuthUser(uid: user.uid, email: email, role: role);
  }

  @override
  User? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
