import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../models/group_models.dart';
import '../state/groups_actions.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({
    super.key,
    required this.subjectId,
    this.post,
  });

  final int subjectId;
  final GroupPostModel? post;

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();
  String _postType = 'announcement';
  String _priority = 'normal';
  bool _isPinned = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    if (post != null) {
      _titleController.text = post.title;
      _contentController.text = post.content;
      _attachmentController.text = post.attachmentLabel ?? '';
      _postType = post.type;
      _priority = post.priority;
      _isPinned = post.isPinned;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, VoidCallback>(
      converter: (store) => () {
        if (_formKey.currentState?.validate() != true) {
          return;
        }
        store.dispatch(
          SaveGroupPostAction(
            subjectId: widget.subjectId,
            payload: <String, dynamic>{
              'post_id': widget.post?.id,
              'title': _titleController.text.trim(),
              'content': _contentController.text.trim(),
              'post_type': _postType,
              'priority': _priority,
              'is_pinned': _isPinned,
              'attachment_label': _attachmentController.text.trim(),
            },
          ),
        );
        Navigator.of(context).maybePop();
      },
      builder: (context, submit) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.post == null ? 'Create Subject Post' : 'Edit Subject Post'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: DoctorAssistantFormLayout(
              title: 'Post Composer',
              subtitle:
                  'Publish a clean academic post with title, content, priority, and optional attachment label.',
              formKey: _formKey,
              primaryLabel: 'Publish post',
              secondaryLabel: 'Back',
              onSecondaryTap: () => Navigator.of(context).maybePop(),
              onSubmit: submit,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Post title'),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Content'),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _postType,
                        decoration: const InputDecoration(labelText: 'Post type'),
                        items: const ['announcement', 'post', 'activity']
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            _postType = value ?? 'announcement';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: const ['normal', 'high']
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            _priority = value ?? 'normal';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _attachmentController,
                  decoration: const InputDecoration(
                    labelText: 'Attachment label',
                    hintText: 'lecture-brief.pdf',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  value: _isPinned,
                  onChanged: (value) {
                    setState(() {
                      _isPinned = value;
                    });
                  },
                  title: const Text('Pin this post'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
