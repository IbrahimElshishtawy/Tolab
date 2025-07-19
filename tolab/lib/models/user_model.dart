class UserModel {
  final String id;
  final String name;
  final String email;
  final String nationalId;
  final String birthDate;
  final String gender;
  final String address;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.nationalId,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.userType,
  });

  // لتحويل من JSON إلى كائن
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      nationalId: json['nationalId'] ?? '',
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      userType: json['userType'] ?? '',
    );
  }

  // لتحويل من كائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'nationalId': nationalId,
      'birthDate': birthDate,
      'gender': gender,
      'address': address,
      'userType': userType,
    };
  }
}
