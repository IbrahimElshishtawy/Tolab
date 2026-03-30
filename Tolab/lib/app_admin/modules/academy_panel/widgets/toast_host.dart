import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/academy_models.dart';
import '../state/academy_actions.dart';
import '../state/academy_state.dart';

class AcademyToastHost extends StatefulWidget {
  const AcademyToastHost({super.key});

  @override
  State<AcademyToastHost> createState() => _AcademyToastHostState();
}

class _AcademyToastHostState extends State<AcademyToastHost> {
  Timer? _dismissTimer;
  String? _visibleToastId;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AcademyAppState, AcademyToast?>(
      distinct: true,
      converter: (store) =>
          store.state.toastQueue.isEmpty ? null : store.state.toastQueue.first,
      builder: (context, toast) {
        if (toast != null && toast.id != _visibleToastId) {
          _visibleToastId = toast.id;
          _dismissTimer?.cancel();
          _dismissTimer = Timer(const Duration(seconds: 4), () {
            if (!mounted) return;
            StoreProvider.of<AcademyAppState>(
              context,
            ).dispatch(AcademyToastDequeuedAction(toast.id));
          });
        }

        return IgnorePointer(
          ignoring: toast == null,
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AnimatedSlide(
                  duration: AppMotion.medium,
                  offset: toast == null ? const Offset(1.2, 0) : Offset.zero,
                  child: AnimatedOpacity(
                    duration: AppMotion.medium,
                    opacity: toast == null ? 0 : 1,
                    child: toast == null
                        ? const SizedBox.shrink()
                        : SizedBox(
                            width: 360,
                            child: AppCard(
                              borderRadius: AppConstants.mediumRadius,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: BoxDecoration(
                                      color:
                                          (toast.accentColor ?? AppColors.info)
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.notifications_active_rounded,
                                      color:
                                          toast.accentColor ?? AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          toast.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(toast.message),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          toast.role.label,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      StoreProvider.of<AcademyAppState>(
                                        context,
                                      ).dispatch(
                                        AcademyToastDequeuedAction(toast.id),
                                      );
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
