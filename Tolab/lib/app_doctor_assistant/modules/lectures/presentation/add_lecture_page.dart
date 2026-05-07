import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/academic_models.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../lectures/state/lectures_actions.dart';
import '../../subjects/state/subjects_actions.dart';

class AddLecturePage extends StatefulWidget {
  const AddLecturePage({super.key, this.lectureId, this.initialSubjectId});

  final int? lectureId;
  final int? initialSubjectId;

  @override
  State<AddLecturePage> createState() => _AddLecturePageState();
}

class _AddLecturePageState extends State<AddLecturePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: '2026-04-24',
  );
  final TextEditingController _timeController = TextEditingController(
    text: '09:00',
  );
  final TextEditingController _meetingController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();

  int? _subjectId;
  String _deliveryMode = 'In person';
  bool _publishNow = false;
  bool _saveAsDraft = true;

  // Track initial state for dirty form detection
  late int? _initialSubjectId;
  late String _initialTitle;
  late String _initialDescription;
  late String _initialDate;
  late String _initialTime;
  late String _initialDeliveryMode;
  late String _initialMeetingUrl;
  late String _initialLocation;
  late String _initialAttachment;
  late bool _initialPublishNow;
  late bool _initialSaveAsDraft;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.initialSubjectId;
    _captureInitialState();
  }

  void _captureInitialState() {
    _initialSubjectId = _subjectId;
    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
    _initialDate = _dateController.text;
    _initialTime = _timeController.text;
    _initialDeliveryMode = _deliveryMode;
    _initialMeetingUrl = _meetingController.text;
    _initialLocation = _locationController.text;
    _initialAttachment = _attachmentController.text;
    _initialPublishNow = _publishNow;
    _initialSaveAsDraft = _saveAsDraft;
  }

  bool _isFormDirty() {
    return _initialSubjectId != _subjectId ||
        _initialTitle != _titleController.text ||
        _initialDescription != _descriptionController.text ||
        _initialDate != _dateController.text ||
        _initialTime != _timeController.text ||
        _initialDeliveryMode != _deliveryMode ||
        _initialMeetingUrl != _meetingController.text ||
        _initialLocation != _locationController.text ||
        _initialAttachment != _attachmentController.text ||
        _initialPublishNow != _publishNow ||
        _initialSaveAsDraft != _saveAsDraft;
  }

  Future<void> _handleBackPressed() async {
    // If form is clean, navigate back immediately
    if (!_isFormDirty()) {
      _navigateBack();
      return;
    }

    // Show confirmation dialog for unsaved changes
    if (!mounted) return;

    final shouldDiscard = await _showDiscardDialog();

    if (shouldDiscard == true && mounted) {
      _navigateBack();
    }
  }

  /// Safely navigate back using GoRouter
  ///
  /// This method:
  /// 1. Checks if the widget is still mounted
  /// 2. Verifies if there's a page to pop using context.canPop()
  /// 3. Pops the current page if possible
  /// 4. Falls back to home route if this is the root page
  /// 5. Uses addPostFrameCallback to prevent _debugLocked errors
  void _navigateBack() {
    if (!mounted) return;

    // Use addPostFrameCallback to ensure we're not in the middle of a frame
    // This prevents '_debugLocked' assertion errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        // Check if there's a page to pop in the navigation stack
        if (context.canPop()) {
          // Safe to pop - there's a previous page
          context.pop();
        } else {
          // This is the root page - navigate to home instead
          context.go('/workspace/lectures');
        }
      } catch (e) {
        debugPrint('Navigation error in _navigateBack: $e');
        // Fallback: navigate to home on any error
        if (mounted) {
          try {
            context.go('/home');
          } catch (fallbackError) {
            debugPrint('Fallback navigation also failed: $fallbackError');
          }
        }
      }
    });
  }

  /// Show confirmation dialog for discarding unsaved changes
  ///
  /// Returns:
  /// - true if user confirms discard
  /// - false if user cancels
  /// - false if dialog is dismissed
  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text(
                'You have unsaved changes. Are you sure you want to discard them?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Use Navigator for dialog dismissal (not GoRouter)
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Use Navigator for dialog dismissal (not GoRouter)
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Discard'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _meetingController.dispose();
    _locationController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _AddLectureVm>(
      onInit: (store) {
        store.dispatch(LoadSubjectsAction());
        store.dispatch(LoadLecturesAction());
      },
      converter: (store) => _AddLectureVm.fromStore(store),
      builder: (context, vm) {
        final lecture = widget.lectureId == null
            ? null
            : vm.lectures
                  .where((item) => item.id == widget.lectureId)
                  .firstOrNull;
        if (lecture != null && _titleController.text.isEmpty) {
          _subjectId = lecture.subjectId;
          _titleController.text = lecture.title;
          _descriptionController.text = lecture.description ?? '';
          _dateController.text =
              lecture.startsAt?.split('T').first ?? _dateController.text;
          _timeController.text = lecture.startsAt == null
              ? _timeController.text
              : lecture.startsAt!.split('T').last.substring(0, 5);
          _deliveryMode = lecture.deliveryMode == 'online'
              ? 'Online'
              : 'In person';
          _meetingController.text = lecture.meetingUrl ?? '';
          _locationController.text = lecture.locationLabel ?? '';
          _attachmentController.text = lecture.attachmentLabel ?? '';
          _publishNow = lecture.statusLabel == 'Published';
          _saveAsDraft = lecture.statusLabel == 'Draft';
          _captureInitialState();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.lectureId == null ? 'Add Lecture' : 'Edit Lecture',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: DoctorAssistantFormLayout(
              title: 'Lecture Publisher',
              subtitle:
                  'Choose one of your assigned subjects, prepare the lecture details, and either save as draft or publish on schedule.',
              formKey: _formKey,
              primaryLabel: 'Save lecture',
              secondaryLabel: 'Back',
              onSecondaryTap: _handleBackPressed,
              onSubmit: () => _submit(vm.store),
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: vm.subjects
                      .map(
                        (subject) => DropdownMenuItem<int>(
                          value: subject.id,
                          child: Text('${subject.code} · ${subject.name}'),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _subjectId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Lecture title'),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Publish date',
                        ),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Publish time',
                        ),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _deliveryMode,
                  decoration: const InputDecoration(labelText: 'Lecture type'),
                  items: const ['In person', 'Online']
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    setState(() {
                      _deliveryMode = value ?? 'In person';
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (_deliveryMode == 'Online')
                  TextFormField(
                    controller: _meetingController,
                    decoration: const InputDecoration(
                      labelText: 'Meeting link',
                    ),
                  )
                else
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _attachmentController,
                  decoration: const InputDecoration(
                    labelText: 'Attachment label',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  value: _publishNow,
                  onChanged: (value) {
                    setState(() {
                      _publishNow = value;
                      if (value) {
                        _saveAsDraft = false;
                      }
                    });
                  },
                  title: const Text('Publish now'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _saveAsDraft,
                  onChanged: (value) {
                    setState(() {
                      _saveAsDraft = value;
                      if (value) {
                        _publishNow = false;
                      }
                    });
                  },
                  title: const Text('Save as draft'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(Store<DoctorAssistantAppState> store) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    store.dispatch(
      SaveLectureAction(<String, dynamic>{
        'lecture_id': widget.lectureId,
        'subject_id': _subjectId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'publish_date': _dateController.text.trim(),
        'publish_time': _timeController.text.trim(),
        'delivery_mode': _deliveryMode,
        'meeting_url': _meetingController.text.trim(),
        'location_label': _locationController.text.trim(),
        'attachment_label': _attachmentController.text.trim(),
        'publish_now': _publishNow,
        'save_as_draft': _saveAsDraft,
      }),
    );
    Navigator.of(context).pop();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _AddLectureVm {
  const _AddLectureVm({
    required this.subjects,
    required this.lectures,
    required this.store,
  });

  final List<SubjectModel> subjects;
  final List<dynamic> lectures;
  final Store<DoctorAssistantAppState> store;

  factory _AddLectureVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _AddLectureVm(
      subjects: store.state.subjectsState.list.data ?? const [],
      lectures: store.state.lecturesState.data ?? const [],
      store: store,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
