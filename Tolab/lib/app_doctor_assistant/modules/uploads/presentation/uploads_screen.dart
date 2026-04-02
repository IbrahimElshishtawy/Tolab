import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../core/models/notification_models.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/uploads_actions.dart';

class UploadsScreen extends StatelessWidget {
  const UploadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _UploadsVm>(
      converter: (store) => _UploadsVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadUploadsAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Uploads',
          activePath: AppRoutes.uploads,
          items: buildNavigationItems(user),
          trailing: user.hasPermission('uploads.create')
              ? AppButton(
                  label: 'Upload file',
                  icon: Icons.upload_file_rounded,
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
                      withData: true,
                    );

                    final file = result?.files.singleOrNull;
                    if (file == null || file.bytes == null) {
                      return;
                    }

                    final formData = FormData.fromMap({
                      'file': MultipartFile.fromBytes(
                        file.bytes!,
                        filename: file.name,
                      ),
                    });
                    vm.upload(formData);
                  },
                )
              : null,
          body: ListView(
            children: [
              if (vm.progress > 0 && vm.progress < 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Uploading...', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: vm.progress),
                      ],
                    ),
                  ),
                ),
              if (vm.items == null)
                const LoadingStateView()
              else
                ...vm.items!.map(
                  (UploadModel item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(item.sizeLabel),
                        trailing: AppBadge(label: item.mimeType),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UploadsVm {
  const _UploadsVm({
    required this.user,
    required this.items,
    required this.progress,
    required this.upload,
  });

  final SessionUser? user;
  final List<UploadModel>? items;
  final double progress;
  final void Function(FormData formData) upload;

  factory _UploadsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _UploadsVm(
      user: getCurrentUser(store.state),
      items: store.state.uploadsState.data,
      progress: store.state.uploadsState.progress,
      upload: (formData) => store.dispatch(UploadFileAction(formData)),
    );
  }
}
