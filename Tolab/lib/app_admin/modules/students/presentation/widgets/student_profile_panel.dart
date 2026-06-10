import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';
import '../../widgets/student_module_primitives.dart';

class StudentProfilePanel extends StatelessWidget {
  const StudentProfilePanel({
    super.key,
    required this.student,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.onApproveDocument,
    required this.onRejectDocument,
    this.height,
  });

  final StudentProfile student;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return StudentSectionCard(
      title: 'Student profile',
      subtitle:
          'Photo, contacts, courses, grades, attendance, documents, and activity feed.',
      height: height,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEditStudent,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onUploadDocuments,
            icon: const Icon(Icons.upload_file_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(name: student.fullName, radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${student.studentNumber} • ${student.department} • Year ${student.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StudentStatusPill(
                label: student.enrollmentStatus.label,
                color: student.isAtRisk ? AppColors.danger : AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _InfoTile(
                label: 'Email',
                value: student.contact.email,
                icon: Icons.alternate_email_rounded,
              ),
              _InfoTile(
                label: 'Phone',
                value: student.contact.phone,
                icon: Icons.phone_rounded,
              ),
              _InfoTile(
                label: 'Emergency',
                value:
                    '${student.emergencyContact.name} • ${student.emergencyContact.phone}',
                icon: Icons.health_and_safety_rounded,
              ),
              _InfoTile(
                label: 'Address',
                value: student.contact.address,
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StudentStatusPill(
                  label: 'GPA ${student.gpa.toStringAsFixed(2)}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StudentStatusPill(
                  label:
                      'Attendance ${student.attendanceRate.toStringAsFixed(0)}%',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StudentStatusPill(
                  label: 'Avg ${student.averageGrade.toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onExportTranscript,
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Transcript'),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onDownloadBundle,
                icon: const Icon(Icons.folder_zip_rounded),
                label: const Text('Docs bundle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Courses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final course in student.courses.take(3)) ...[
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text('${course.code} • ${course.title}'),
              subtitle: Text(
                '${course.grade} • ${course.score.toStringAsFixed(0)} • ${course.attendanceRate.toStringAsFixed(0)}% attendance',
              ),
              trailing: Text(course.semester),
            ),
            const Divider(height: 1),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Documents', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final document in student.documents.take(4)) ...[
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file_outlined),
                    title: Text(document.name),
                    subtitle: Text(
                      '${document.category} • ${document.sizeLabel}',
                    ),
                  ),
                ),
                StudentStatusPill(
                  label: document.status.label,
                  color: switch (document.status) {
                    StudentDocumentStatus.pending => AppColors.warning,
                    StudentDocumentStatus.approved => AppColors.success,
                    StudentDocumentStatus.rejected => AppColors.danger,
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: () => onApproveDocument(document),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                ),
                IconButton(
                  onPressed: () => onRejectDocument(document),
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final activity in student.activities.take(4)) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(switch (activity.type) {
                StudentActivityType.login => Icons.login_rounded,
                StudentActivityType.assignment => Icons.assignment_rounded,
                StudentActivityType.forumPost => Icons.forum_rounded,
                StudentActivityType.message =>
                  Icons.chat_bubble_outline_rounded,
                StudentActivityType.submission => Icons.upload_rounded,
                StudentActivityType.document => Icons.folder_rounded,
                StudentActivityType.approval => Icons.verified_rounded,
              }),
              title: Text(activity.title),
              subtitle: Text(activity.description),
              trailing: Text(
                DateFormat('MMM d').format(activity.occurredAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
