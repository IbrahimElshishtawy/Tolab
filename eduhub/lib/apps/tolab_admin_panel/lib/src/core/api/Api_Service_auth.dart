// ignore_for_file: file_names

class ApiServiceAuth {
  Future<String> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 2)); // simulate server

    if (email == "admin@tolab.com" && password == "123456") {
      return "FAKE_TOKEN_123"; // simulated token
    } else {
      throw Exception("Invalid credentials");
    }
  }
}
