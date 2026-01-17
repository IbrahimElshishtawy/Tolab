import 'package:firebase_auth/firebase_auth.dart';
import 'auth_role_ds.dart';

class AuthRoleDataSourceImpl implements AuthRoleDataSource {
  @override
  Future<String> resolveUserRole(User user, String selectedRole) async {
    return selectedRole;
  }
}
