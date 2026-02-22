import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/core/network/api_client.dart';

class Department {
  final int id;
  final String name;
  final String code;
  final bool isActive;

  Department({required this.id, required this.name, required this.code, required this.isActive});
  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        isActive: json['is_active'],
      );
}

class AcademicYear {
  final int id;
  final String name;
  final bool isActive;

  AcademicYear({required this.id, required this.name, required this.isActive});
  factory AcademicYear.fromJson(Map<String, dynamic> json) => AcademicYear(
        id: json['id'],
        name: json['name'],
        isActive: json['is_active'],
      );
}

class Subject {
  final int id;
  final String name;
  final String code;
  final int? doctorId;

  Subject({required this.id, required this.name, required this.code, this.doctorId});
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    id: json['id'],
    name: json['name'],
    code: json['code'],
    doctorId: json['doctor_id'],
  );
}

class AcademicRepository {
  final Ref _ref;
  AcademicRepository(this._ref);

  Future<List<Department>> getDepartments() async {
    final response = await _ref.read(apiClientProvider).get('/admin/departments');
    return (response.data as List).map((e) => Department.fromJson(e)).toList();
  }

  Future<List<AcademicYear>> getAcademicYears() async {
    final response = await _ref.read(apiClientProvider).get('/admin/academic-years');
    return (response.data as List).map((e) => AcademicYear.fromJson(e)).toList();
  }

  Future<List<Subject>> getSubjects() async {
    final response = await _ref.read(apiClientProvider).get('/admin/subjects');
    return (response.data as List).map((e) => Subject.fromJson(e)).toList();
  }

  Future<void> createDepartment(Map<String, dynamic> data) async {
    await _ref.read(apiClientProvider).post('/admin/departments', data: data);
  }

  Future<void> createAcademicYear(Map<String, dynamic> data) async {
    await _ref.read(apiClientProvider).post('/admin/academic-years', data: data);
  }

  Future<void> createSubject(Map<String, dynamic> data) async {
    await _ref.read(apiClientProvider).post('/admin/subjects', data: data);
  }
}

final academicRepositoryProvider = Provider((ref) => AcademicRepository(ref));

final departmentsProvider = FutureProvider((ref) => ref.watch(academicRepositoryProvider).getDepartments());
final academicYearsProvider = FutureProvider((ref) => ref.watch(academicRepositoryProvider).getAcademicYears());
final subjectsProvider = FutureProvider((ref) => ref.watch(academicRepositoryProvider).getSubjects());
