class Subject {
  final int id;
  final String academicYearName;
  final String batchName;
  final String departmentName;
  final String subjectName;

  Subject({
    required this.id,
    required this.academicYearName,
    required this.batchName,
    required this.departmentName,
    required this.subjectName,
  });
}

class Lecture {
  final int id;
  final int subjectId;
  final int weekNumber;
  final String lectureName;
  final String doctorName;
  final String? videoUrl;
  final String? pdfUrl;

  Lecture({
    required this.id,
    required this.subjectId,
    required this.weekNumber,
    required this.lectureName,
    required this.doctorName,
    this.videoUrl,
    this.pdfUrl,
  });
}

class Section {
  final int id;
  final int subjectId;
  final int weekNumber;
  final String sectionName;
  final String assistantName;
  final String? videoUrl;
  final String? pdfUrl;

  Section({
    required this.id,
    required this.subjectId,
    required this.weekNumber,
    required this.sectionName,
    required this.assistantName,
    this.videoUrl,
    this.pdfUrl,
  });
}

enum QuizType { online, offline }

class Quiz {
  final int id;
  final int subjectId;
  final int weekNumber;
  final String title;
  final String authorName;
  final QuizType type;
  final String? link;
  final DateTime date;

  Quiz({
    required this.id,
    required this.subjectId,
    required this.weekNumber,
    required this.title,
    required this.authorName,
    required this.type,
    this.link,
    required this.date,
  });
}

class Task {
  final int id;
  final int subjectId;
  final int weekNumber;
  final String refName;
  final String authorName;
  final String pdfUrl;

  Task({
    required this.id,
    required this.subjectId,
    required this.weekNumber,
    required this.refName,
    required this.authorName,
    required this.pdfUrl,
  });
}
