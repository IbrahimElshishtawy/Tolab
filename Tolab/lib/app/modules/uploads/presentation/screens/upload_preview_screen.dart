import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pdfx/pdfx.dart';
import 'package:redux/redux.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/upload_model.dart';
import '../../state/uploads_actions.dart';

class UploadPreviewScreen extends StatelessWidget {
  const UploadPreviewScreen({
    super.key,
    required this.uploadId,
    required this.uploadName,
  });

  final String uploadId;
  final String uploadName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 760),
        child: StoreConnector<AppState, _PreviewViewModel>(
          onInit: (Store<AppState> store) {
            store.dispatch(OpenUploadPreviewAction(uploadId));
          },
          onDispose: (Store<AppState> store) {
            store.dispatch(const CloseUploadPreviewAction());
          },
          converter: (store) => _PreviewViewModel(
            status: store.state.uploadsState.previewStatus,
            preview: store.state.uploadsState.previewData,
            errorMessage: store.state.uploadsState.errorMessage,
          ),
          builder: (context, vm) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              uploadName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Preview, inspect, and validate upload quality before sharing.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: switch (vm.status) {
                      LoadStatus.loading ||
                      LoadStatus.refreshing => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      LoadStatus.failure => _PreviewErrorState(
                        message:
                            vm.errorMessage ??
                            'We could not load the preview right now.',
                      ),
                      _ when vm.preview != null => _PreviewBody(
                        preview: vm.preview!,
                      ),
                      _ => const _PreviewErrorState(
                        message:
                            'No preview data is available for this upload.',
                      ),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreviewViewModel {
  const _PreviewViewModel({
    required this.status,
    required this.preview,
    required this.errorMessage,
  });

  final LoadStatus status;
  final UploadPreviewData? preview;
  final String? errorMessage;
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.preview});

  final UploadPreviewData preview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Center(
                child: switch (preview.kind) {
                  UploadPreviewKind.image => _ImagePreview(preview: preview),
                  UploadPreviewKind.pdf => _PdfPreview(preview: preview),
                  UploadPreviewKind.video => _VideoPreview(preview: preview),
                  _ => const _UnsupportedPreview(),
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaTile(
                label: 'Type',
                value: preview.mimeType,
                icon: Icons.category_rounded,
              ),
              _MetaTile(
                label: 'Size',
                value: _formatFileSize(preview.sizeBytes),
                icon: Icons.storage_rounded,
              ),
              if (preview.durationLabel != null)
                _MetaTile(
                  label: 'Duration',
                  value: preview.durationLabel!,
                  icon: Icons.timer_outlined,
                ),
              const Spacer(),
              if (preview.downloadUrl != null)
                PremiumButton(
                  label: 'Copy Download Link',
                  icon: Icons.content_copy_rounded,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: preview.downloadUrl!),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
              PremiumButton(
                label: 'Close Preview',
                icon: Icons.check_rounded,
                isSecondary: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.preview});

  final UploadPreviewData preview;

  @override
  Widget build(BuildContext context) {
    if (preview.bytes != null) {
      return InteractiveViewer(child: Image.memory(preview.bytes!));
    }
    if (preview.previewUrl != null) {
      return InteractiveViewer(child: Image.network(preview.previewUrl!));
    }
    return const _UnsupportedPreview();
  }
}

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({required this.preview});

  final UploadPreviewData preview;

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  PdfControllerPinch? _controller;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.preview.bytes != null) {
      _controller = PdfControllerPinch(
        document: PdfDocument.openData(widget.preview.bytes!),
      );
    } else if (widget.preview.previewUrl != null) {
      final bundle = NetworkAssetBundle(Uri.parse(widget.preview.previewUrl!));
      final data = await bundle.load(widget.preview.previewUrl!);
      _controller = PdfControllerPinch(
        document: PdfDocument.openData(data.buffer.asUint8List()),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return PdfViewPinch(controller: _controller!);
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.preview});

  final UploadPreviewData preview;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.preview.previewUrl == null) return;
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.preview.previewUrl!),
    );
    await controller.initialize();
    controller.setLooping(true);
    _controller = controller;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      if (widget.preview.thumbnailUrl != null) {
        return Image.network(widget.preview.thumbnailUrl!, fit: BoxFit.cover);
      }
      return const _UnsupportedPreview();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        const SizedBox(height: AppSpacing.md),
        PremiumButton(
          label: _controller!.value.isPlaying ? 'Pause' : 'Play',
          icon: _controller!.value.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onPressed: () {
            setState(() {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
            });
          },
        ),
      ],
    );
  }
}

class _PreviewErrorState extends StatelessWidget {
  const _PreviewErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _UnsupportedPreview extends StatelessWidget {
  const _UnsupportedPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.insert_drive_file_outlined,
          size: 54,
          color: AppColors.slate,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Rich preview is not available for this file.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return '${size.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}
