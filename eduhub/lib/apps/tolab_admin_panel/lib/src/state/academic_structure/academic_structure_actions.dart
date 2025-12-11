// ignore_for_file: file_names

class LoadAcademicStructureAction {}

class AcademicStructureLoadedAction {
  final List<dynamic> departments;
  final List<dynamic> programs;
  final List<dynamic> years;

  AcademicStructureLoadedAction({
    required this.departments,
    required this.programs,
    required this.years,
  });
}

class AcademicStructureFailedAction {
  final String error;
  AcademicStructureFailedAction(this.error);
}
