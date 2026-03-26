import '../../datasources/admin/admin_resource_remote_data_source.dart';
import '../../models/admin_models.dart';
import '../../models/admin_seed_data.dart';
import 'admin_resource_repository.dart';

class StudentsRepository extends AdminResourceRepository<StudentModel> {
  StudentsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/students',
        parser: StudentModel.fromJson,
        seed: AdminSeedData.students,
      );
}

class DoctorsRepository extends AdminResourceRepository<StaffModel> {
  DoctorsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/doctors',
        parser: StaffModel.fromJson,
        seed: AdminSeedData.doctors,
      );
}

class AssistantsRepository extends AdminResourceRepository<StaffModel> {
  AssistantsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/assistants',
        parser: StaffModel.fromJson,
        seed: AdminSeedData.assistants,
      );
}

class DepartmentsRepository extends AdminResourceRepository<DepartmentModel> {
  DepartmentsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/departments',
        parser: DepartmentModel.fromJson,
        seed: AdminSeedData.departments,
      );
}

class AcademicYearsRepository
    extends AdminResourceRepository<AcademicYearModel> {
  AcademicYearsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/academic-years',
        parser: AcademicYearModel.fromJson,
        seed: AdminSeedData.academicYears,
      );
}

class BatchesRepository extends AdminResourceRepository<BatchModel> {
  BatchesRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/batches',
        parser: BatchModel.fromJson,
        seed: AdminSeedData.batches,
      );
}

class SubjectsRepository extends AdminResourceRepository<SubjectModel> {
  SubjectsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/subjects',
        parser: SubjectModel.fromJson,
        seed: AdminSeedData.subjects,
      );
}

class AssignmentsRepository
    extends AdminResourceRepository<SubjectAssignmentModel> {
  AssignmentsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/subject-assignments',
        parser: SubjectAssignmentModel.fromJson,
        seed: AdminSeedData.assignments,
      );
}

class CourseOfferingsRepository
    extends AdminResourceRepository<CourseOfferingModel> {
  CourseOfferingsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/course-offerings',
        parser: CourseOfferingModel.fromJson,
        seed: AdminSeedData.offerings,
      );
}

class EnrollmentsRepository extends AdminResourceRepository<EnrollmentModel> {
  EnrollmentsRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/enrollments',
        parser: EnrollmentModel.fromJson,
        seed: AdminSeedData.enrollments,
      );
}

class ScheduleRepository extends AdminResourceRepository<ScheduleItemModel> {
  ScheduleRepository(AdminResourceRemoteDataSource remoteDataSource)
    : super(
        remoteDataSource: remoteDataSource,
        endpoint: '/admin/schedule',
        parser: ScheduleItemModel.fromJson,
        seed: AdminSeedData.schedules,
      );
}
