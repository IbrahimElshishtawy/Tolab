import '../../../core/models/session_user.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../models/doctor_assistant_models.dart';
import '../models/course_workspace_models.dart';

class CourseWorkspaceMockRepository {
  const CourseWorkspaceMockRepository._();

  static const CourseWorkspaceMockRepository instance =
      CourseWorkspaceMockRepository._();

  CourseWorkspace build({required int subjectId, required SessionUser user}) {
    final subject = DoctorAssistantMockRepository.instance.subjectById(
      subjectId,
    );
    final activeStudents = (subject.studentCount * 0.78).round();

    return CourseWorkspace(
      subjectId: subject.id,
      subjectCode: subject.code,
      subjectName: subject.name,
      department: subject.department,
      termLabel: subject.academicTerm,
      description: subject.description,
      studentCount: subject.studentCount,
      activeStudents: activeStudents,
      healthScore: (subject.progress * 100).round() + 12,
      healthSummary: user.isDoctor
          ? 'Course health is steady, but one assessment and a missing follow-up need action.'
          : 'Section delivery is stable, with a few students needing closer follow-up this week.',
      actionRequired: [
        const CourseActionItem(
          id: 'draft_quiz',
          title: 'Quiz draft still not published',
          caption:
              'Finalize the quiz window and publish it before the next class.',
          severity: 'High',
          targetTab: CourseWorkspaceTab.quizBuilder,
        ),
        const CourseActionItem(
          id: 'lecture_link',
          title: 'Upcoming lecture link is missing',
          caption:
              'Students still do not have a direct access link for the live session.',
          severity: 'Medium',
          targetTab: CourseWorkspaceTab.sessions,
        ),
        const CourseActionItem(
          id: 'late_submissions',
          title: '12 students missed the latest sheet deadline',
          caption:
              'Review engagement and publish a reminder before the next section.',
          severity: 'High',
          targetTab: CourseWorkspaceTab.students,
        ),
      ],
      todayFocus: [
        CourseFocusItem(
          id: 'lecture',
          title: '${subject.name} lecture',
          caption: 'Main lecture block',
          timeLabel: '09:00 - 11:00',
          targetTab: CourseWorkspaceTab.sessions,
        ),
        const CourseFocusItem(
          id: 'quiz',
          title: 'Quiz review window',
          caption: 'Finalize settings and send reminders',
          timeLabel: '12:30',
          targetTab: CourseWorkspaceTab.quizBuilder,
        ),
        const CourseFocusItem(
          id: 'group',
          title: 'Group clarification post',
          caption: 'Clarify task expectations before section time',
          timeLabel: '15:00',
          targetTab: CourseWorkspaceTab.group,
        ),
      ],
      studentInsights: [
        const CourseInsightItem(
          id: 'engagement',
          title: 'Active Students',
          value: '114',
          caption: 'Visited the course this week',
          tone: 'primary',
        ),
        const CourseInsightItem(
          id: 'risk',
          title: 'Need Attention',
          value: '18',
          caption: 'Low engagement or missing work',
          tone: 'danger',
        ),
        const CourseInsightItem(
          id: 'submissions',
          title: 'Pending Submissions',
          value: '27',
          caption: 'Students still have open deadlines',
          tone: 'warning',
        ),
      ],
      activityFeed: [
        const CourseFeedItem(
          id: 'feed_1',
          title: 'Announcement published',
          body: 'Office hours moved to Tuesday 13:00.',
          timeLabel: '18 min ago',
          type: 'announcement',
        ),
        const CourseFeedItem(
          id: 'feed_2',
          title: 'New group comment',
          body: 'Students asked for one more worked example before the quiz.',
          timeLabel: '1 hr ago',
          type: 'comment',
        ),
        const CourseFeedItem(
          id: 'feed_3',
          title: 'Submission sync completed',
          body: 'Latest sheet submissions were synced to the course ledger.',
          timeLabel: 'Today',
          type: 'submission',
        ),
      ],
      quizzes: _buildQuizzes(subject),
      announcements: _buildAnnouncements(subject),
      posts: _buildPosts(subject),
      sessions: _buildSessions(subject),
      events: _buildEvents(subject),
      students: _buildStudents(subject),
      analytics: _buildAnalytics(subject, activeStudents),
    );
  }

  List<CourseQuiz> _buildQuizzes(TeachingSubject subject) {
    return [
      CourseQuiz(
        id: '${subject.code.toLowerCase()}_quiz_draft',
        title: '${subject.name} Weekly Checkpoint',
        description:
            'A timed quiz that covers the core ideas from the most recent lecture and section.',
        startAt: DateTime(2026, 4, 16, 10, 0),
        endAt: DateTime(2026, 4, 16, 12, 0),
        durationMinutes: 45,
        publication: CourseQuizPublication.draft,
        mode: CourseQuizMode.graded,
        questions: const [
          CourseQuizQuestion(
            id: 'q_1',
            type: CourseQuestionType.multipleChoice,
            prompt: 'Which concept best explains the main lecture outcome?',
            options: [
              'Greedy local improvement',
              'Recursive decomposition',
              'State-space search',
              'Database normalization',
            ],
            correctOptionIndexes: {1},
            marks: 2,
          ),
          CourseQuizQuestion(
            id: 'q_2',
            type: CourseQuestionType.checkbox,
            prompt: 'Select the valid statements covered in the section.',
            options: [
              'Every solution is optimal by default',
              'Complexity should be justified',
              'Edge cases affect correctness',
              'Testing is optional for final answers',
            ],
            correctOptionIndexes: {1, 2},
            marks: 3,
          ),
          CourseQuizQuestion(
            id: 'q_3',
            type: CourseQuestionType.shortAnswer,
            prompt:
                'Write the most important takeaway from this week in one sentence.',
            correctAnswerText:
                'Students should articulate the core principle clearly.',
            marks: 2,
          ),
        ],
      ),
      CourseQuiz(
        id: '${subject.code.toLowerCase()}_quiz_published',
        title: '${subject.name} Practice Quiz',
        description: 'Practice-only self-check before the graded assessment.',
        startAt: DateTime(2026, 4, 13, 9, 0),
        endAt: DateTime(2026, 4, 20, 23, 0),
        durationMinutes: 25,
        publication: CourseQuizPublication.published,
        mode: CourseQuizMode.practice,
        questions: const [
          CourseQuizQuestion(
            id: 'q_4',
            type: CourseQuestionType.trueFalse,
            prompt:
                'The section examples reuse the same reasoning pattern as the lecture.',
            options: ['True', 'False'],
            correctOptionIndexes: {0},
            marks: 1,
          ),
        ],
      ),
    ];
  }

  List<CourseAnnouncement> _buildAnnouncements(TeachingSubject subject) {
    return [
      CourseAnnouncement(
        id: '${subject.code}_ann_1',
        title: 'Quiz window updated',
        body:
            'The graded quiz opens tomorrow at 10:00. Students should review the worked examples first.',
        priority: CourseAnnouncementPriority.urgent,
        isPublished: true,
        publishedAt: DateTime(2026, 4, 15, 8, 30),
      ),
      CourseAnnouncement(
        id: '${subject.code}_ann_2',
        title: 'Section materials uploaded',
        body:
            'Updated examples and an optional worksheet are now available for the next section.',
        priority: CourseAnnouncementPriority.important,
        isPublished: true,
        publishedAt: DateTime(2026, 4, 14, 18, 10),
        attachmentUrl: 'https://example.edu/files/worksheet.pdf',
      ),
    ];
  }

  List<CourseGroupPost> _buildPosts(TeachingSubject subject) {
    return [
      CourseGroupPost(
        id: '${subject.code}_post_1',
        authorName: 'Dr. Course Lead',
        body:
            'Please share the hardest concept from this week so we can cover it at the start of the next lecture.',
        createdAt: DateTime(2026, 4, 15, 9, 15),
        visibility: CoursePostVisibility.enrolled,
        reactionCount: 24,
        comments: [
          CoursePostComment(
            id: 'comment_1',
            authorName: 'Mariam N.',
            body: 'The proof pattern was the hardest part for me.',
            createdAt: DateTime(2026, 4, 15, 9, 24),
          ),
          CoursePostComment(
            id: 'comment_2',
            authorName: 'Ahmed R.',
            body: 'More examples on edge cases would help before the quiz.',
            createdAt: DateTime(2026, 4, 15, 9, 40),
          ),
        ],
      ),
      CourseGroupPost(
        id: '${subject.code}_post_2',
        authorName: 'Teaching Assistant',
        body:
            'Lab instructions are pinned. Bring your previous solution attempt to the section.',
        createdAt: DateTime(2026, 4, 14, 17, 5),
        visibility: CoursePostVisibility.sectionsOnly,
        reactionCount: 12,
        comments: const [],
      ),
    ];
  }

  List<CourseSessionLink> _buildSessions(TeachingSubject subject) {
    return [
      CourseSessionLink(
        id: '${subject.code}_lecture_1',
        kind: CourseSessionKind.lecture,
        title: '${subject.name} Lecture 08',
        deliveryMode: CourseDeliveryMode.online,
        scheduledAt: DateTime(2026, 4, 16, 9, 0),
        description: 'Live lecture with attendance check and short Q&A block.',
        isPublished: true,
        meetingLink:
            'https://meet.example.edu/${subject.code.toLowerCase()}-lecture',
      ),
      CourseSessionLink(
        id: '${subject.code}_section_1',
        kind: CourseSessionKind.section,
        title: '${subject.name} Section B1',
        deliveryMode: CourseDeliveryMode.offline,
        scheduledAt: DateTime(2026, 4, 17, 12, 0),
        description:
            'Hands-on section focused on solving representative exercises.',
        isPublished: false,
        locationLabel: 'Lab C1',
      ),
    ];
  }

  List<CourseScheduleEvent> _buildEvents(TeachingSubject subject) {
    return [
      CourseScheduleEvent(
        id: '${subject.code}_evt_1',
        title: 'Lecture delivery',
        type: CourseEventType.lecture,
        startsAt: DateTime(2026, 4, 16, 9, 0),
        endsAt: DateTime(2026, 4, 16, 11, 0),
        description: 'Main lecture block with attendance sync.',
        statusLabel: 'Scheduled',
      ),
      CourseScheduleEvent(
        id: '${subject.code}_evt_2',
        title: 'Quiz deadline',
        type: CourseEventType.quiz,
        startsAt: DateTime(2026, 4, 16, 10, 0),
        endsAt: DateTime(2026, 4, 16, 12, 0),
        description: 'Quiz window closes automatically at noon.',
        statusLabel: 'Upcoming',
      ),
      CourseScheduleEvent(
        id: '${subject.code}_evt_3',
        title: 'Sheet submission cutoff',
        type: CourseEventType.deadline,
        startsAt: DateTime(2026, 4, 18, 22, 0),
        endsAt: DateTime(2026, 4, 18, 23, 0),
        description: 'Late submissions require manual override.',
        statusLabel: 'Reminder',
      ),
    ];
  }

  List<CourseStudent> _buildStudents(TeachingSubject subject) {
    return [
      CourseStudent(
        id: 'stu_1',
        name: 'Menna Adel',
        code: '20230041',
        email: 'menna.adel@tolab.edu',
        activitySummary: 'Highly active in quizzes and group discussion.',
        quizCompletionRate: 96,
        submissionsCount: 7,
        lastActive: DateTime(2026, 4, 15, 8, 50),
        engagement: CourseEngagementLevel.high,
        completedSheets: 7,
        completedQuizzes: 5,
        averageGrade: 89.0,
      ),
      CourseStudent(
        id: 'stu_2',
        name: 'Youssef Hamdy',
        code: '20230072',
        email: 'youssef.hamdy@tolab.edu',
        activitySummary:
            'Strong attendance, but assignment delivery is slowing down.',
        quizCompletionRate: 78,
        submissionsCount: 5,
        lastActive: DateTime(2026, 4, 14, 19, 10),
        engagement: CourseEngagementLevel.medium,
        completedSheets: 5,
        completedQuizzes: 4,
        averageGrade: 74.5,
      ),
      CourseStudent(
        id: 'stu_3',
        name: 'Farah Tarek',
        code: '20230105',
        email: 'farah.tarek@tolab.edu',
        activitySummary:
            'Needs follow-up after missing two deadlines and one quiz.',
        quizCompletionRate: 43,
        submissionsCount: 2,
        lastActive: DateTime(2026, 4, 11, 12, 20),
        engagement: CourseEngagementLevel.low,
        completedSheets: 2,
        completedQuizzes: 2,
        averageGrade: 58.0,
      ),
      CourseStudent(
        id: 'stu_4',
        name: 'Omar Nasser',
        code: '20230124',
        email: 'omar.nasser@tolab.edu',
        activitySummary:
            'Regular participation with room to improve quiz speed.',
        quizCompletionRate: 82,
        submissionsCount: 6,
        lastActive: DateTime(2026, 4, 15, 7, 55),
        engagement: CourseEngagementLevel.medium,
        completedSheets: 6,
        completedQuizzes: 4,
        averageGrade: 71.0,
      ),
    ];
  }

  CourseAnalytics _buildAnalytics(TeachingSubject subject, int activeStudents) {
    return CourseAnalytics(
      totalStudents: subject.studentCount,
      activeStudents: activeStudents,
      quizCompleted: (subject.studentCount * 0.68).round(),
      pendingSubmissions: (subject.studentCount * 0.19).round(),
      averageGrade: 76.8,
      activityTrend: const [
        CourseChartPoint(label: 'Sat', value: 42),
        CourseChartPoint(label: 'Sun', value: 58),
        CourseChartPoint(label: 'Mon', value: 63),
        CourseChartPoint(label: 'Tue', value: 74),
        CourseChartPoint(label: 'Wed', value: 69),
        CourseChartPoint(label: 'Thu', value: 81),
      ],
      submissionsTrend: const [
        CourseChartPoint(label: 'W1', value: 38),
        CourseChartPoint(label: 'W2', value: 49),
        CourseChartPoint(label: 'W3', value: 55),
        CourseChartPoint(label: 'W4', value: 66),
      ],
      performanceDistribution: const [
        CourseChartPoint(label: 'High', value: 31),
        CourseChartPoint(label: 'Medium', value: 49),
        CourseChartPoint(label: 'Low', value: 20),
      ],
      completionBreakdown: const [
        CourseBreakdownSlice(
          label: 'Completed',
          value: 68,
          hexColor: 0xFF2F7AF8,
        ),
        CourseBreakdownSlice(label: 'Pending', value: 32, hexColor: 0xFF13B8A6),
      ],
      performerBreakdown: const [
        CourseBreakdownSlice(label: 'High', value: 31, hexColor: 0xFF2F7AF8),
        CourseBreakdownSlice(label: 'Medium', value: 49, hexColor: 0xFFF59E0B),
        CourseBreakdownSlice(label: 'Low', value: 20, hexColor: 0xFFEF4444),
      ],
    );
  }
}
