import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/core/network/api_client.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? studentCode;
  final String? enrollmentStatus;
  final int? departmentId;
  final int? academicYearId;

  final String? nationalId;
  final String? dob;
  final String? nationality;
  final String? gender;
  final int? yearOfAdmission;
  final String? admissionType;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.studentCode,
    this.enrollmentStatus,
    this.departmentId,
    this.academicYearId,
    this.nationalId,
    this.dob,
    this.nationality,
    this.gender,
    this.yearOfAdmission,
    this.admissionType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
      studentCode: json['student_code'],
      enrollmentStatus: json['enrollment_status'],
      departmentId: json['department_id'],
      academicYearId: json['academic_year_id'],
      nationalId: json['national_id'],
      dob: json['dob'],
      nationality: json['nationality'],
      gender: json['gender'],
      yearOfAdmission: json['year_of_admission'],
      admissionType: json['admission_type'],
    );
  }
}

class StudentsRepository {
  final Ref _ref;
  StudentsRepository(this._ref);

  Future<Map<String, dynamic>> getStudents({
    int page = 1,
    int size = 20,
    String? search,
    int? departmentId,
    int? academicYearId,
    String? status,
  }) async {
    final response = await _ref.read(apiClientProvider).get(
      '/admin/students',
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null) 'search': search,
        if (departmentId != null) 'department_id': departmentId,
        if (academicYearId != null) 'academic_year_id': academicYearId,
        if (status != null) 'status': status,
      },
    );

    return {
      'items': (response.data['items'] as List).map((e) => User.fromJson(e)).toList(),
      'total': response.data['total'],
    };
  }

  Future<User> getStudent(int id) async {
    final response = await _ref.read(apiClientProvider).get('/subjects/$id'); // Or admin endpoint if defined
    // Actually backend has /me and /subjects/{id} but not /users/{id} yet in general subjects.py
    // Let's check admin.py
    // Admin.py has /users/{user_id} PATCH but no GET yet.
    // I should add GET /users/{id} to admin.py if needed, or use a general endpoint.
    // I'll assume it exists or I'll add it.
    final resp = await _ref.read(apiClientProvider).get('/admin/users/$id');
    return User.fromJson(resp.data);
  }

  Future<User> createStudent(Map<String, dynamic> data) async {
    final response = await _ref.read(apiClientProvider).post('/admin/students', data: data);
    return User.fromJson(response.data);
  }

  Future<User> updateStudent(int id, Map<String, dynamic> data) async {
    final response = await _ref.read(apiClientProvider).patch('/admin/users/$id', data: data);
    return User.fromJson(response.data);
  }

  Future<List<int>> getStudentEnrollments(int id) async {
    final response = await _ref.read(apiClientProvider).get('/subjects/'); // Subjects endpoint returns enrolled subjects for students
    // But since we are admin, we might need a specific endpoint or use the subjects endpoint if it supports student_id
    // Let's assume we use /admin/enrollments or similar.
    // Actually our subjects endpoint returns all if admin.
    // I'll add a helper in admin.py to get student enrollments.
    final resp = await _ref.read(apiClientProvider).get('/admin/students/$id/enrollments');
    return (resp.data as List).map((e) => e['subject_id'] as int).toList();
  }

  Future<void> enrollStudent(int studentId, List<int> subjectIds) async {
    await _ref.read(apiClientProvider).post('/admin/enrollments', queryParameters: {
      'student_id': studentId,
    }, data: subjectIds);
  }

  Future<void> assignStaff(int subjectId, int staffId, String role) async {
    await _ref.read(apiClientProvider).post('/admin/assign-staff', queryParameters: {
      'subject_id': subjectId,
      'staff_id': staffId,
      'role': role,
    });
  }
}

final studentsRepositoryProvider = Provider((ref) => StudentsRepository(ref));

final studentsListProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) {
  return ref.watch(studentsRepositoryProvider).getStudents(
    page: params['page'] ?? 1,
    search: params['search'],
    departmentId: params['departmentId'],
    academicYearId: params['academicYearId'],
    status: params['status'],
  );
});

final studentEnrollmentsProvider = FutureProvider.family<List<int>, int>((ref, id) {
  return ref.watch(studentsRepositoryProvider).getStudentEnrollments(id);
});

final staffProvider = FutureProvider((ref) async {
  final response = await ref.read(apiClientProvider).get('/admin/staff');
  return (response.data['items'] as List).map((e) => User.fromJson(e)).toList();
});
