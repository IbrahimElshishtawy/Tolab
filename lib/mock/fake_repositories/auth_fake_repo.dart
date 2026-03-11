import '../../features/auth/data/models.dart';
import '../fake_delay.dart';

class AuthFakeRepo {
  Future<LoginResponse> login(String email, String password) async {
    await fakeDelay();
    const role = 'it';

    return LoginResponse(
      accessToken: 'fake_token_${DateTime.now().millisecondsSinceEpoch}',
      tokenType: 'bearer',
      role: role,
    );
  }

  Future<void> logout() async {
    await fakeDelay();
  }
}
