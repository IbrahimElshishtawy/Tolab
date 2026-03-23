import '../../features/auth/data/models.dart';
import '../fake_delay.dart';
import '../mock_data.dart';

class AuthFakeRepo {
  Future<LoginResponse> login(String email, String password) async {
    await fakeDelay();
    final normalizedEmail = email.trim().toLowerCase();
    final matchIndex = mockAuthAccounts.indexWhere(
      (account) =>
          account['email'] == normalizedEmail &&
          account['password'] == password,
    );

    if (matchIndex == -1) {
      throw Exception(
        'Invalid mock credentials. Use one of the predefined demo accounts.',
      );
    }

    final matchedAccount = mockAuthAccounts[matchIndex];
    final role = matchedAccount['role']!;

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
