import 'package:flutter_test/flutter_test.dart';
import 'package:tolab_fci/app_doctor_assistant/core/models/dashboard_models.dart';

void main() {
  test('dashboard snapshot parses the structured control center payload', () {
    final snapshot = DashboardSnapshot.fromJson({
      'header': {
        'user': {
          'id': 9,
          'name': 'Dr. Ahmed',
          'role': 'DOCTOR',
          'greeting': 'Good morning, Dr. Ahmed',
          'subtitle': 'Here is your academic overview for today.',
          'departments': ['Computer Science'],
          'academic_years': ['Third Year'],
        },
        'notification_badge': 2,
        'generated_at': '2026-04-14T08:00:00Z',
      },
      'quick_actions': [
        {
          'id': 'add_lecture',
          'label': 'Add Lecture',
          'description': 'Publish lecture content before the next session.',
          'route': '/workspace/lectures',
          'permission': 'lectures.create',
          'icon': 'lecture',
          'tone': 'primary',
        },
      ],
      'action_center': {
        'summary': '1 high-priority and 0 medium-priority decisions are ready for action.',
        'items': [
          {
            'id': 'grading_pending_1',
            'type': 'PENDING_GRADING',
            'priority': 'HIGH',
            'title': '4 submissions need grading',
            'explanation': 'Task still has work waiting for review.',
            'cta_label': 'Review',
            'route': '/workspace/tasks',
            'meta': {'task_id': 1},
          },
        ],
      },
      'today_focus': {
        'headline': '1 urgent item needs attention first.',
        'summary': 'Task still has work waiting for review.',
        'primary_action': {
          'id': 'grading_pending_1',
          'type': 'PENDING_GRADING',
          'priority': 'HIGH',
          'title': '4 submissions need grading',
          'explanation': 'Task still has work waiting for review.',
          'cta_label': 'Review',
          'route': '/workspace/tasks',
        },
        'metrics': [
          {'label': 'Sessions today', 'value': 2, 'tone': 'primary'},
        ],
      },
      'timeline': {
        'groups': [
          {
            'id': 'today',
            'label': 'Today',
            'items': [
              {
                'id': 'schedule_1',
                'type': 'LECTURE',
                'title': 'Week 6 Lecture',
                'subject_name': 'Software Engineering',
                'when_label': 'Tue, 9:00 AM',
                'status': 'Room',
                'route': '/workspace/schedule',
              },
            ],
          },
        ],
      },
      'subjects_overview': {
        'summary': '1 active subject is assigned to this workspace.',
        'items': [
          {
            'id': 1,
            'name': 'Software Engineering',
            'code': 'SE301',
            'department': 'Computer Science',
            'academic_year': 'Third Year',
            'batch': 'Level 3',
            'student_count': 42,
            'groups_count': 3,
            'sections_count': 2,
            'health_score': 78,
            'risk_level': 'WATCH',
            'quick_actions': [
              {'label': 'Open Subject', 'route': '/workspace/subjects/1'},
            ],
          },
        ],
      },
      'students_attention': {
        'count': 1,
        'items': [
          {
            'student_id': 7,
            'name': 'Omar Ali',
            'reason': 'Missed 2 task submissions',
            'severity': 'HIGH',
            'cta_label': 'Review',
            'route': '/workspace/subjects/1',
            'details': ['Missed 2 task submissions'],
          },
        ],
      },
      'student_activity_insights': {
        'summary': '32 of 42 students showed recent activity this week.',
        'active_students': 20,
        'inactive_students': 4,
        'missing_submissions': 3,
        'new_comments': 1,
        'unread_messages': 2,
        'low_engagement_count': 6,
        'engagement_rate': 86,
        'students_needing_attention': 1,
        'items': [],
      },
      'course_health': {
        'overall_score': 78,
        'status': 'WATCH',
        'summary': '1 subject area needs intervention this week.',
        'metrics': [
          {'label': 'Healthy subjects', 'value': 0, 'tone': 'success'},
        ],
        'subjects': [
          {
            'subject_id': 1,
            'subject_name': 'Software Engineering',
            'score': 78,
            'status': 'WATCH',
          },
        ],
      },
      'group_activity_feed': {
        'items': [
          {
            'id': 'post_1',
            'activity_type': 'POST',
            'subject_name': 'Software Engineering',
            'group_name': 'SE Group',
            'author_name': 'Mona Adel',
            'content': 'Can you review the task notes?',
            'timestamp': '2026-04-14T07:00:00Z',
            'route': '/workspace/subjects/1',
          },
        ],
      },
      'notifications_preview': {
        'unread_count': 2,
        'items': [
          {
            'id': 1,
            'title': 'New student question',
            'body': 'A student commented on Software Engineering.',
            'category': 'group',
            'route': '/workspace/notifications',
            'time': '2026-04-14T07:30:00Z',
            'is_unread': true,
          },
        ],
      },
      'pending_grading': {
        'can_manage': true,
        'count': 4,
        'summary': '4 submissions are waiting across 1 task.',
        'items': [
          {
            'task_id': 1,
            'title': 'Iteration Assignment',
            'subject_name': 'Software Engineering',
            'pending_count': 4,
            'cta_label': 'Grade',
            'route': '/workspace/tasks',
          },
        ],
      },
      'performance_analytics': {
        'is_limited': false,
        'summary': 'Average graded performance is 71.5% across 12 grade records.',
        'average_score': 71.5,
        'trend': [
          {'label': 'Software Engineering', 'value': 71.5},
        ],
        'top_performers': [
          {'student_name': 'Mona Adel', 'average_score': 92},
        ],
        'low_performers': [
          {'student_name': 'Omar Ali', 'average_score': 48},
        ],
      },
      'risk_alerts': {
        'count': 1,
        'items': [
          {
            'id': 'health_1',
            'severity': 'HIGH',
            'title': 'Software Engineering is at risk',
            'explanation': 'Health score dropped to 78.',
            'cta_label': 'Open Subject',
            'route': '/workspace/subjects/1',
          },
        ],
      },
      'weekly_summary': {
        'headline': '2 sessions, 1 quiz, and 1 task deadline are scheduled this week.',
        'items': [
          {
            'label': 'Sessions',
            'value': 2,
            'tone': 'primary',
            'caption': 'Lectures and sections on the timetable',
          },
        ],
      },
      'smart_suggestions': {
        'items': [
          {
            'id': 'grading_sprint',
            'title': 'Run a grading sprint today',
            'explanation': 'Clearing the grading queue first will improve feedback speed.',
            'cta_label': 'Open grading queue',
            'route': '/workspace/tasks',
          },
        ],
      },
    });

    expect(snapshot.header.user.name, 'Dr. Ahmed');
    expect(snapshot.actionCenter.items.single.type, 'PENDING_GRADING');
    expect(snapshot.timeline.hasItems, isTrue);
    expect(snapshot.subjectsOverview.items.single.healthScore, 78);
    expect(snapshot.pendingGrading.count, 4);
    expect(snapshot.performanceAnalytics.averageScore, 71.5);
    expect(snapshot.hasContent, isTrue);
  });

  test('dashboard snapshot reports empty content when sections are empty', () {
    final snapshot = DashboardSnapshot.fromJson({
      'header': {
        'user': {
          'id': 1,
          'name': 'Dr. Empty',
          'role': 'DOCTOR',
          'greeting': 'Good evening, Dr. Empty',
          'subtitle': 'Here is your academic overview for today.',
        },
        'notification_badge': 0,
      },
      'quick_actions': [],
      'action_center': {'summary': '', 'items': []},
      'today_focus': {'headline': '', 'summary': '', 'metrics': []},
      'timeline': {'groups': []},
      'subjects_overview': {'summary': '', 'items': []},
      'students_attention': {'count': 0, 'items': []},
      'student_activity_insights': {},
      'course_health': {},
      'group_activity_feed': {'items': []},
      'notifications_preview': {'unread_count': 0, 'items': []},
      'pending_grading': {'can_manage': false, 'count': 0, 'summary': '', 'items': []},
      'performance_analytics': {'is_limited': true, 'summary': ''},
      'risk_alerts': {'count': 0, 'items': []},
      'weekly_summary': {'headline': '', 'items': []},
      'smart_suggestions': {'items': []},
    });

    expect(snapshot.hasContent, isFalse);
    expect(snapshot.header.notificationBadge, 0);
  });
}
