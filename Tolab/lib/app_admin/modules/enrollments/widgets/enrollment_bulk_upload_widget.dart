import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../models/enrollment_models.dart';

class EnrollmentBulkUploadWidget extends StatefulWidget {
  const EnrollmentBulkUploadWidget({
    super.key,
    required this.lookups,
    this.preview,
    required this.onPreviewPrepared,
    required this.onSubmit,
    this.onClose,
  });

  final EnrollmentLookupBundle lookups;
  final EnrollmentBulkPreview? preview;
  final ValueChanged<EnrollmentBulkPreview> onPreviewPrepared;
  final ValueChanged<List<EnrollmentUpsertPayload>> onSubmit;
  final VoidCallback? onClose;

  @override
  State<EnrollmentBulkUploadWidget> createState() =>
      _EnrollmentBulkUploadWidgetState();
}

class _EnrollmentBulkUploadWidgetState
    extends State<EnrollmentBulkUploadWidget> {
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulk enrollments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Upload a CSV or Excel file, review row-level validation, then save the approved rows to the enrollment API.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accepted columns',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'student_id | student_name, course_offering_id | course_code | course_name, section_id | section_name, semester, academic_year | year, status, doctor_id, assistant_id',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PremiumButton(
                      label: _isPicking ? 'Reading file...' : 'Choose file',
                      icon: Icons.upload_file_rounded,
                      onPressed: _isPicking ? null : _pickFile,
                    ),
                    if (preview != null)
                      PremiumButton(
                        label: 'Import ${preview.validCount} valid rows',
                        icon: Icons.playlist_add_check_circle_rounded,
                        isSecondary: true,
                        onPressed: preview.validCount == 0
                            ? null
                            : () => widget.onSubmit(preview.validPayloads),
                      ),
                    if (widget.onClose != null)
                      TextButton(
                        onPressed: widget.onClose,
                        child: const Text('Close'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview.fileName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM, HH:mm').format(preview.generatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _CounterChip(
                        label: 'Rows',
                        value: preview.rows.length.toString(),
                        color: AppColors.primary,
                      ),
                      _CounterChip(
                        label: 'Valid',
                        value: preview.validCount.toString(),
                        color: AppColors.secondary,
                      ),
                      _CounterChip(
                        label: 'Errors',
                        value: preview.invalidCount.toString(),
                        color: preview.invalidCount == 0
                            ? AppColors.info
                            : AppColors.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 420,
              child: ListView.separated(
                itemCount: preview.rows.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final row = preview.rows[index];
                  return AppCard(
                    borderColor: row.isValid
                        ? AppColors.secondary.withValues(alpha: 0.18)
                        : AppColors.danger.withValues(alpha: 0.18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Row ${row.rowNumber}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (row.isValid
                                            ? AppColors.secondary
                                            : AppColors.danger)
                                        .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                row.isValid ? 'Ready' : 'Needs attention',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: row.isValid
                                          ? AppColors.secondary
                                          : AppColors.danger,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${row.previewStudent} • ${row.previewCourse} • ${row.previewSection}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${row.previewSemester} • ${row.previewAcademicYear} • ${row.previewStatus}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (row.errors.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          ...row.errors.map(
                            (error) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Text(
                                '• $error',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        withData: true,
        allowedExtensions: const ['csv', 'xlsx', 'xls'],
      );
      final files = result?.files;
      final file = files == null || files.isEmpty ? null : files.first;
      if (file == null || file.bytes == null) return;
      final preview = _buildPreview(file.name, file.bytes!);
      widget.onPreviewPrepared(preview);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  EnrollmentBulkPreview _buildPreview(String fileName, Uint8List bytes) {
    final rows = fileName.toLowerCase().endsWith('.csv')
        ? _parseCsv(bytes)
        : _parseExcel(bytes);
    return EnrollmentBulkPreview(
      fileName: fileName,
      rows: rows,
      generatedAt: DateTime.now(),
    );
  }

  List<EnrollmentBulkRowDraft> _parseCsv(Uint8List bytes) {
    final raw = utf8.decode(bytes, allowMalformed: true);
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    if (lines.isEmpty) return const <EnrollmentBulkRowDraft>[];
    final headers = _splitCsvLine(lines.first);
    return List<EnrollmentBulkRowDraft>.generate(lines.length - 1, (index) {
      final values = _splitCsvLine(lines[index + 1]);
      final row = <String, String>{};
      for (var column = 0; column < headers.length; column++) {
        row[headers[column]] = column < values.length ? values[column] : '';
      }
      return _mapDraft(index + 2, row);
    });
  }

  List<String> _splitCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;
    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    values.add(buffer.toString().trim());
    return values
        .map((value) => value.replaceAll('"', '').trim())
        .toList(growable: false);
  }

  List<EnrollmentBulkRowDraft> _parseExcel(Uint8List bytes) {
    final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: false);
    if (decoder.tables.isEmpty) {
      return const <EnrollmentBulkRowDraft>[];
    }
    final table = decoder.tables.values.first;
    if (table.rows.isEmpty) {
      return const <EnrollmentBulkRowDraft>[];
    }
    final headers = table.rows.first
        .map((cell) => (cell?.toString() ?? '').trim())
        .toList(growable: false);
    return List<EnrollmentBulkRowDraft>.generate(table.rows.length - 1, (
      index,
    ) {
      final rowData = table.rows[index + 1];
      final row = <String, String>{};
      for (var column = 0; column < headers.length; column++) {
        row[headers[column]] = column < rowData.length
            ? rowData[column]?.toString() ?? ''
            : '';
      }
      return _mapDraft(index + 2, row);
    });
  }

  EnrollmentBulkRowDraft _mapDraft(int rowNumber, Map<String, String> row) {
    final normalized = {
      for (final entry in row.entries)
        _normalizeHeader(entry.key): entry.value.trim(),
    };
    final errors = <String>[];

    final student = _resolveStudent(normalized);
    if (student == null) {
      errors.add('Student could not be matched to the lookup directory.');
    }

    final status = EnrollmentStatusX.fromJson(
      normalized['status']?.isEmpty ?? true ? 'pending' : normalized['status'],
    );

    final offering = _resolveOffering(normalized);
    if (offering == null) {
      errors.add(
        'Course offering could not be matched from course, section, semester, and year.',
      );
    }

    final payload = student != null && offering != null
        ? EnrollmentUpsertPayload(
            studentId: student.id,
            courseOfferingId: offering.id,
            courseId: offering.courseId,
            sectionId: offering.sectionId,
            semester: offering.semester,
            academicYear: offering.academicYear,
            status: status,
            doctorId: normalized['doctor_id']?.isNotEmpty == true
                ? normalized['doctor_id']!
                : offering.doctorId,
            assistantId: normalized['assistant_id']?.isNotEmpty == true
                ? normalized['assistant_id']!
                : offering.assistantId,
          )
        : null;

    return EnrollmentBulkRowDraft(
      rowNumber: rowNumber,
      source: row,
      previewStudent:
          student?.name ??
          normalized['student_name'] ??
          normalized['student_id'] ??
          'Unknown student',
      previewCourse:
          offering?.courseLabel ??
          normalized['course_code'] ??
          normalized['course_name'] ??
          normalized['course_offering_id'] ??
          'Unknown course',
      previewSection:
          offering?.sectionName ??
          normalized['section_name'] ??
          normalized['section_id'] ??
          'Unknown section',
      previewSemester:
          offering?.semester ?? normalized['semester'] ?? 'Unknown semester',
      previewAcademicYear:
          offering?.academicYear ??
          normalized['academic_year'] ??
          normalized['year'] ??
          'Unknown year',
      previewStatus: status.label,
      errors: List<String>.unmodifiable(errors),
      payload: payload,
    );
  }

  EnrollmentStudentOption? _resolveStudent(Map<String, String> row) {
    final studentId = row['student_id'] ?? row['student_user_id'];
    if (studentId != null && studentId.isNotEmpty) {
      for (final student in widget.lookups.students) {
        if (student.id.toLowerCase() == studentId.toLowerCase()) {
          return student;
        }
      }
    }
    final studentName = row['student_name'];
    if (studentName != null && studentName.isNotEmpty) {
      for (final student in widget.lookups.students) {
        if (student.name.toLowerCase() == studentName.toLowerCase()) {
          return student;
        }
      }
    }
    return null;
  }

  EnrollmentOfferingOption? _resolveOffering(Map<String, String> row) {
    final offeringId = row['course_offering_id'];
    if (offeringId != null && offeringId.isNotEmpty) {
      for (final offering in widget.lookups.offerings) {
        if (offering.id.toLowerCase() == offeringId.toLowerCase()) {
          return offering;
        }
      }
    }

    final courseCode = row['course_code'];
    final courseName = row['course_name'];
    final section = row['section_id'] ?? row['section_name'];
    final semester = row['semester'];
    final year = row['academic_year'] ?? row['year'];

    for (final offering in widget.lookups.offerings) {
      final matchesCourse =
          (courseCode != null && courseCode.isNotEmpty
              ? offering.courseCode.toLowerCase() == courseCode.toLowerCase()
              : true) &&
          (courseName != null && courseName.isNotEmpty
              ? offering.courseName.toLowerCase() == courseName.toLowerCase()
              : true);
      final matchesSection = section == null || section.isEmpty
          ? true
          : offering.sectionId.toLowerCase() == section.toLowerCase() ||
                offering.sectionName.toLowerCase() == section.toLowerCase();
      final matchesSemester = semester == null || semester.isEmpty
          ? true
          : offering.semester.toLowerCase() == semester.toLowerCase();
      final matchesYear = year == null || year.isEmpty
          ? true
          : offering.academicYear.toLowerCase() == year.toLowerCase();

      if (matchesCourse && matchesSection && matchesSemester && matchesYear) {
        return offering;
      }
    }
    return null;
  }

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_');
  }
}

class _CounterChip extends StatelessWidget {
  const _CounterChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
