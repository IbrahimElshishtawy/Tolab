import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../models/content_models.dart';

class ContentSeedService {
  const ContentSeedService();

  ContentRepositoryBundle createBundle() {
    final subjects = [
      const ContentSubjectOption(
        id: 'subj-mobile',
        code: 'CS401',
        title: 'Mobile App Architecture',
        courseOfferingId: 'cof-mobile',
      ),
      const ContentSubjectOption(
        id: 'subj-ai',
        code: 'AI302',
        title: 'Applied Artificial Intelligence',
        courseOfferingId: 'cof-ai',
      ),
      const ContentSubjectOption(
        id: 'subj-net',
        code: 'NT215',
        title: 'Computer Networks',
        courseOfferingId: 'cof-net',
      ),
    ];

    final sections = [
      const ContentSectionOption(
        id: 'sec-mobile-a',
        subjectId: 'subj-mobile',
        title: 'Section A',
        capacity: 120,
      ),
      const ContentSectionOption(
        id: 'sec-mobile-b',
        subjectId: 'subj-mobile',
        title: 'Section B',
        capacity: 90,
      ),
      const ContentSectionOption(
        id: 'sec-ai-a',
        subjectId: 'subj-ai',
        title: 'Lab 1',
        capacity: 84,
      ),
      const ContentSectionOption(
        id: 'sec-net-a',
        subjectId: 'subj-net',
        title: 'Section C',
        capacity: 110,
      ),
    ];

    final instructors = [
      const ContentInstructorOption(
        id: 'inst-hassan',
        name: 'Dr. Mariam Hassan',
        title: 'Lead Instructor',
        accentColor: AppColors.primary,
      ),
      const ContentInstructorOption(
        id: 'inst-nader',
        name: 'Prof. Kareem Nader',
        title: 'Assessment Owner',
        accentColor: AppColors.info,
      ),
      const ContentInstructorOption(
        id: 'inst-salma',
        name: 'Eng. Salma Adel',
        title: 'Section Instructor',
        accentColor: AppColors.secondary,
      ),
    ];

    final mobile = subjects.first;
    final ai = subjects[1];
    final networks = subjects[2];
    final now = DateTime.now();

    return ContentRepositoryBundle(
      subjects: subjects,
      sections: sections,
      instructors: instructors,
      items: [
        ContentRecord(
          id: 'cnt-lecture-state',
          title: 'State Management Deep Dive',
          description:
              'Architecture notes for Redux-driven Flutter admin flows with selector-first rendering.',
          type: ContentType.lecture,
          status: ContentStatus.published,
          visibility: ContentVisibility.enrolledOnly,
          subject: mobile,
          section: sections.first,
          instructor: instructors.first,
          publishAt: now.subtract(const Duration(days: 2)),
          dueAt: null,
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(hours: 3)),
          attachments: [
            _attachment(
              'att-1',
              'redux-architecture.pdf',
              'application/pdf',
              1284000,
            ),
            _attachment(
              'att-2',
              'selector-patterns.key',
              'application/vnd.apple.keynote',
              4260000,
            ),
          ],
          students: _students(
            names: const [
              'Alaa Samir',
              'Rahma Tarek',
              'Omar Yasser',
              'Hana Adel',
            ],
            sectionLabel: 'Section A',
            statuses: const [
              SubmissionStatus.submitted,
              SubmissionStatus.graded,
              SubmissionStatus.pending,
              SubmissionStatus.submitted,
            ],
          ),
          submissions: [
            _submission(
              'sub-1',
              'Alaa Samir',
              SubmissionStatus.submitted,
              1,
              91,
            ),
            _submission('sub-2', 'Rahma Tarek', SubmissionStatus.graded, 1, 96),
            _submission(
              'sub-3',
              'Hana Adel',
              SubmissionStatus.submitted,
              1,
              88,
            ),
          ],
          activity: [
            _activity(
              'act-lecture-1',
              'Lecture published',
              'Visible to enrolled students',
              now.subtract(const Duration(hours: 3)),
              Icons.publish_rounded,
              AppColors.secondary,
            ),
            _activity(
              'act-lecture-2',
              '3 new downloads',
              'Students accessed the lecture assets',
              now.subtract(const Duration(hours: 1)),
              Icons.download_rounded,
              AppColors.info,
            ),
          ],
          gradeBands: _gradeBands(const [0, 8, 17, 9]),
          permissions: const ContentPermissionSet(),
          assessmentSettings: null,
          enrollmentCount: 96,
          viewCount: 78,
          completionRate: 0.82,
          isPinned: true,
        ),
        ContentRecord(
          id: 'cnt-quiz-widget',
          title: 'Widget Lifecycle Quiz',
          description:
              'Short formative assessment covering build phases, element tree updates, and disposal rules.',
          type: ContentType.quiz,
          status: ContentStatus.scheduled,
          visibility: ContentVisibility.enrolledOnly,
          subject: mobile,
          section: sections[1],
          instructor: instructors[1],
          publishAt: now.add(const Duration(days: 1)),
          dueAt: now.add(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now.subtract(const Duration(hours: 6)),
          attachments: [
            _attachment(
              'att-3',
              'quiz-blueprint.pdf',
              'application/pdf',
              640000,
            ),
          ],
          students: _students(
            names: const ['Layla Mostafa', 'Ahmed Emad', 'Noha Magdy'],
            sectionLabel: 'Section B',
            statuses: const [
              SubmissionStatus.pending,
              SubmissionStatus.pending,
              SubmissionStatus.pending,
            ],
          ),
          submissions: const [],
          activity: [
            _activity(
              'act-quiz-1',
              'Quiz scheduled',
              'Auto-publish set for tomorrow at 09:00',
              now.subtract(const Duration(hours: 5)),
              Icons.schedule_rounded,
              AppColors.warning,
            ),
          ],
          gradeBands: _gradeBands(const [0, 0, 0, 0]),
          permissions: const ContentPermissionSet(),
          assessmentSettings: const ContentAssessmentSettings(
            mode: AssessmentMode.mcq,
            questionCount: 18,
            durationMinutes: 20,
            attemptsAllowed: 1,
            allowLateSubmission: false,
          ),
          enrollmentCount: 84,
          viewCount: 52,
          completionRate: 0.34,
          isPinned: false,
        ),
        ContentRecord(
          id: 'cnt-task-model',
          title: 'Mini Model Evaluation Task',
          description:
              'Students submit a rubric-based evaluation comparing compact and frontier model behavior on fixed prompts.',
          type: ContentType.task,
          status: ContentStatus.published,
          visibility: ContentVisibility.allStudents,
          subject: ai,
          section: sections[2],
          instructor: instructors[1],
          publishAt: now.subtract(const Duration(days: 1)),
          dueAt: now.add(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now.subtract(const Duration(hours: 8)),
          attachments: [
            _attachment(
              'att-4',
              'grading-rubric.docx',
              'application/msword',
              940000,
            ),
            _attachment('att-5', 'prompt-pack.zip', 'application/zip', 2920000),
          ],
          students: _students(
            names: const [
              'Mazen Ashraf',
              'Yara Salah',
              'Mona Nabil',
              'Ibrahim Hesham',
            ],
            sectionLabel: 'Lab 1',
            statuses: const [
              SubmissionStatus.submitted,
              SubmissionStatus.late,
              SubmissionStatus.pending,
              SubmissionStatus.graded,
            ],
          ),
          submissions: [
            _submission(
              'sub-4',
              'Mazen Ashraf',
              SubmissionStatus.submitted,
              2,
              87,
            ),
            _submission('sub-5', 'Yara Salah', SubmissionStatus.late, 1, null),
            _submission(
              'sub-6',
              'Ibrahim Hesham',
              SubmissionStatus.graded,
              1,
              94,
            ),
          ],
          activity: [
            _activity(
              'act-task-1',
              'Late submission detected',
              'One student submitted after the soft due date',
              now.subtract(const Duration(hours: 9)),
              Icons.warning_amber_rounded,
              AppColors.warning,
            ),
            _activity(
              'act-task-2',
              'Grades synced',
              '14 grades entered by Dr. Nader',
              now.subtract(const Duration(hours: 2)),
              Icons.fact_check_rounded,
              AppColors.secondary,
            ),
          ],
          gradeBands: _gradeBands(const [2, 6, 12, 4]),
          permissions: const ContentPermissionSet(),
          assessmentSettings: const ContentAssessmentSettings(
            mode: AssessmentMode.fileSubmission,
            questionCount: 1,
            durationMinutes: 0,
            attemptsAllowed: 2,
            allowLateSubmission: true,
          ),
          enrollmentCount: 72,
          viewCount: 68,
          completionRate: 0.64,
          isPinned: true,
        ),
        ContentRecord(
          id: 'cnt-summary-cnn',
          title: 'CNN Optimization Summary',
          description:
              'A compact revision file for convolutional backpropagation, augmentation pipelines, and validation strategy.',
          type: ContentType.summary,
          status: ContentStatus.published,
          visibility: ContentVisibility.allStudents,
          subject: ai,
          section: sections[2],
          instructor: instructors.first,
          publishAt: now.subtract(const Duration(days: 5)),
          dueAt: null,
          createdAt: now.subtract(const Duration(days: 9)),
          updatedAt: now.subtract(const Duration(days: 1)),
          attachments: [
            _attachment('att-6', 'cnn-summary.pdf', 'application/pdf', 1580000),
          ],
          students: _students(
            names: const ['Malak Fathy', 'Hossam Ali', 'Sara Adel'],
            sectionLabel: 'Lab 1',
            statuses: const [
              SubmissionStatus.pending,
              SubmissionStatus.pending,
              SubmissionStatus.pending,
            ],
          ),
          submissions: const [],
          activity: [
            _activity(
              'act-summary-1',
              'Summary refreshed',
              'New revision package uploaded',
              now.subtract(const Duration(days: 1, hours: 1)),
              Icons.refresh_rounded,
              AppColors.info,
            ),
          ],
          gradeBands: _gradeBands(const [0, 0, 0, 0]),
          permissions: const ContentPermissionSet(canGrade: false),
          assessmentSettings: null,
          enrollmentCount: 72,
          viewCount: 63,
          completionRate: 0.91,
          isPinned: false,
        ),
        ContentRecord(
          id: 'cnt-exam-midterm',
          title: 'Midterm Practical Exam',
          description:
              'Timed practical exam with secure start window, restricted attempts, and rubric-based grading.',
          type: ContentType.exam,
          status: ContentStatus.draft,
          visibility: ContentVisibility.hidden,
          subject: networks,
          section: sections[3],
          instructor: instructors[2],
          publishAt: now.add(const Duration(days: 8)),
          dueAt: now.add(const Duration(days: 8, hours: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(minutes: 45)),
          attachments: [
            _attachment(
              'att-7',
              'exam-proctoring-guide.pdf',
              'application/pdf',
              820000,
            ),
          ],
          students: _students(
            names: const ['Nourhan Samy', 'Yousef Adel', 'Karim Wael'],
            sectionLabel: 'Section C',
            statuses: const [
              SubmissionStatus.pending,
              SubmissionStatus.pending,
              SubmissionStatus.pending,
            ],
          ),
          submissions: const [],
          activity: [
            _activity(
              'act-exam-1',
              'Draft updated',
              'Timing rules and restrictions edited',
              now.subtract(const Duration(minutes: 45)),
              Icons.edit_rounded,
              AppColors.primary,
            ),
          ],
          gradeBands: _gradeBands(const [0, 0, 0, 0]),
          permissions: const ContentPermissionSet(),
          assessmentSettings: const ContentAssessmentSettings(
            mode: AssessmentMode.timedExam,
            questionCount: 30,
            durationMinutes: 90,
            attemptsAllowed: 1,
            allowLateSubmission: false,
          ),
          enrollmentCount: 88,
          viewCount: 27,
          completionRate: 0.18,
          isPinned: false,
        ),
        ContentRecord(
          id: 'cnt-file-lab',
          title: 'Lab Assets Bundle',
          description:
              'Shared packet for router simulation files, topology sheets, and startup configs.',
          type: ContentType.file,
          status: ContentStatus.archived,
          visibility: ContentVisibility.enrolledOnly,
          subject: networks,
          section: sections[3],
          instructor: instructors[2],
          publishAt: now.subtract(const Duration(days: 30)),
          dueAt: null,
          createdAt: now.subtract(const Duration(days: 31)),
          updatedAt: now.subtract(const Duration(days: 14)),
          attachments: [
            _attachment(
              'att-8',
              'router-lab-assets.zip',
              'application/zip',
              9820000,
            ),
          ],
          students: _students(
            names: const ['Rania Ayman', 'Yahya Tamer'],
            sectionLabel: 'Section C',
            statuses: const [
              SubmissionStatus.pending,
              SubmissionStatus.pending,
            ],
          ),
          submissions: const [],
          activity: [
            _activity(
              'act-file-1',
              'Archive applied',
              'Legacy asset bundle moved to archive',
              now.subtract(const Duration(days: 14)),
              Icons.archive_rounded,
              AppColors.danger,
            ),
          ],
          gradeBands: _gradeBands(const [0, 0, 0, 0]),
          permissions: const ContentPermissionSet(canGrade: false),
          assessmentSettings: null,
          enrollmentCount: 88,
          viewCount: 12,
          completionRate: 0.22,
          isPinned: false,
        ),
      ],
    );
  }

  ContentAttachment _attachment(
    String id,
    String name,
    String mimeType,
    int sizeBytes,
  ) {
    return ContentAttachment(
      id: id,
      name: name,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      url: '#',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      uploadedBy: 'Admin',
    );
  }

  List<ContentStudentSnapshot> _students({
    required List<String> names,
    required String sectionLabel,
    required List<SubmissionStatus> statuses,
  }) {
    return List<ContentStudentSnapshot>.generate(names.length, (index) {
      return ContentStudentSnapshot(
        id: 'std-$index-${names[index].replaceAll(' ', '-').toLowerCase()}',
        name: names[index],
        sectionLabel: sectionLabel,
        engagementLabel: switch (statuses[index]) {
          SubmissionStatus.graded => 'High',
          SubmissionStatus.submitted => 'Strong',
          SubmissionStatus.late => 'Attention',
          SubmissionStatus.pending => 'At risk',
        },
        submissionStatus: statuses[index],
        gradeLabel: statuses[index] == SubmissionStatus.pending
            ? null
            : statuses[index] == SubmissionStatus.graded
            ? 'A'
            : 'B+',
      );
    });
  }

  ContentSubmissionRecord _submission(
    String id,
    String studentName,
    SubmissionStatus status,
    int attempts,
    double? grade,
  ) {
    return ContentSubmissionRecord(
      id: id,
      studentId: studentName.toLowerCase().replaceAll(' ', '-'),
      studentName: studentName,
      status: status,
      attempts: attempts,
      attachments: [
        _attachment(
          '$id-file',
          '${studentName.toLowerCase().replaceAll(' ', '_')}_submission.pdf',
          'application/pdf',
          780000,
        ),
      ],
      grade: grade,
      feedback: grade == null
          ? 'Waiting for grading'
          : 'Solid submission quality.',
      submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
    );
  }

  ContentActivityItem _activity(
    String id,
    String title,
    String subtitle,
    DateTime timestamp,
    IconData icon,
    Color tone,
  ) {
    return ContentActivityItem(
      id: id,
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      icon: icon,
      tone: tone,
    );
  }

  List<ContentGradeBand> _gradeBands(List<int> counts) {
    return [
      ContentGradeBand(
        label: 'A',
        count: counts[0],
        color: AppColors.secondary,
      ),
      ContentGradeBand(label: 'B', count: counts[1], color: AppColors.info),
      ContentGradeBand(label: 'C', count: counts[2], color: AppColors.warning),
      ContentGradeBand(label: 'D/F', count: counts[3], color: AppColors.danger),
    ];
  }
}
