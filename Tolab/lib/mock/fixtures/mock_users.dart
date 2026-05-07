import 'package:tolab_fci/data/models/user_model.dart';
import 'package:tolab_fci/domain/entities/user_entity.dart';

class MockUsers {
  static final List<UserModel> users = [
    // Super Admin
    UserModel(
      id: 'user_001',
      email: 'superadmin@tolab.edu',
      firstName: 'Ahmed',
      lastName: 'Hassan',
      phoneNumber: '+20 100 123 4567',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Ahmed',
      role: 'superAdmin',
      isActive: true,
      createdAt: DateTime(2023, 1, 15),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      departmentId: null,
      bio: 'System Administrator',
    ),
    // Admin
    UserModel(
      id: 'user_002',
      email: 'admin@tolab.edu',
      firstName: 'Fatima',
      lastName: 'Mohamed',
      phoneNumber: '+20 100 234 5678',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Fatima',
      role: 'admin',
      isActive: true,
      createdAt: DateTime(2023, 2, 10),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
      departmentId: 'dept_001',
      bio: 'Admin Officer',
    ),
    // Doctors/Instructors
    UserModel(
      id: 'user_003',
      email: 'dr.ali@tolab.edu',
      firstName: 'Ali',
      lastName: 'Ibrahim',
      phoneNumber: '+20 100 345 6789',
      profileImageUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ali',
      role: 'doctor',
      isActive: true,
      createdAt: DateTime(2022, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
      departmentId: 'dept_001',
      bio: 'Assistant Professor - Computer Science',
    ),
    UserModel(
      id: 'user_004',
      email: 'dr.sara@tolab.edu',
      firstName: 'Sara',
      lastName: 'Ahmed',
      phoneNumber: '+20 100 456 7890',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Sara',
      role: 'doctor',
      isActive: true,
      createdAt: DateTime(2022, 8, 15),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 3)),
      departmentId: 'dept_001',
      bio: 'Lecturer - Software Engineering',
    ),
    UserModel(
      id: 'user_005',
      email: 'dr.karim@tolab.edu',
      firstName: 'Karim',
      lastName: 'Hassan',
      phoneNumber: '+20 100 567 8901',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Karim',
      role: 'doctor',
      isActive: true,
      createdAt: DateTime(2022, 7, 20),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
      departmentId: 'dept_002',
      bio: 'Associate Professor - Mathematics',
    ),
    // Staff
    UserModel(
      id: 'user_006',
      email: 'staff.amira@tolab.edu',
      firstName: 'Amira',
      lastName: 'Khalil',
      phoneNumber: '+20 100 678 9012',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Amira',
      role: 'staff',
      isActive: true,
      createdAt: DateTime(2023, 3, 5),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
      departmentId: 'dept_001',
      bio: 'Teaching Assistant',
    ),
    UserModel(
      id: 'user_007',
      email: 'staff.omar@tolab.edu',
      firstName: 'Omar',
      lastName: 'Saleh',
      phoneNumber: '+20 100 789 0123',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Omar',
      role: 'staff',
      isActive: true,
      createdAt: DateTime(2023, 2, 20),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 4)),
      departmentId: 'dept_002',
      bio: 'Lab Coordinator',
    ),
    // Students
    UserModel(
      id: 'user_008',
      email: 'student.hana@tolab.edu',
      firstName: 'Hana',
      lastName: 'Noor',
      phoneNumber: '+20 100 890 1234',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Hana',
      role: 'student',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 15)),
      departmentId: 'dept_001',
      bio: 'Computer Science Student',
    ),
    UserModel(
      id: 'user_009',
      email: 'student.zain@tolab.edu',
      firstName: 'Zain',
      lastName: 'Malik',
      phoneNumber: '+20 100 901 2345',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Zain',
      role: 'student',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      departmentId: 'dept_001',
      bio: 'Computer Science Student',
    ),
    UserModel(
      id: 'user_010',
      email: 'student.layla@tolab.edu',
      firstName: 'Layla',
      lastName: 'Rashid',
      phoneNumber: '+20 100 012 3456',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Layla',
      role: 'student',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 6)),
      departmentId: 'dept_002',
      bio: 'Mathematics Student',
    ),
    UserModel(
      id: 'user_011',
      email: 'student.noor@tolab.edu',
      firstName: 'Noor',
      lastName: 'Farah',
      phoneNumber: '+20 100 123 4568',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Noor',
      role: 'student',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 8)),
      departmentId: 'dept_001',
      bio: 'Computer Science Student',
    ),
    UserModel(
      id: 'user_012',
      email: 'student.rayan@tolab.edu',
      firstName: 'Rayan',
      lastName: 'Adel',
      phoneNumber: '+20 100 234 5679',
      profileImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Rayan',
      role: 'student',
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 2)),
      departmentId: 'dept_002',
      bio: 'Mathematics Student',
    ),
  ];

  static UserEntity getUserById(String id) {
    return users.firstWhere((u) => u.id == id).toEntity();
  }

  static List<UserEntity> getUsersByRole(UserRole role) {
    final roleString = role.toString().split('.').last;
    return users
        .where((u) => u.role == roleString)
        .map((u) => u.toEntity())
        .toList();
  }

  static List<UserEntity> getAllUsers() {
    return users.map((u) => u.toEntity()).toList();
  }
}
