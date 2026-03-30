import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/moderation_models.dart';
import '../../state/moderation_state.dart';

String formatModerationDate(DateTime value) {
  return DateFormat('d MMM, HH:mm').format(value);
}

Future<bool> confirmModerationAction({
  required BuildContext context,
  required ModerationActionType actionType,
  required String subject,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${actionType.label} $subject?'),
        content: Text(
          'This moderation action will be applied immediately and the moderation queue will refresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          PremiumButton(
            label: actionType.label,
            icon: actionType.icon,
            isDestructive: actionType.isDestructive,
            isSecondary: !actionType.isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

void dispatchModerationCommand(
  BuildContext context, {
  required ModerationActionCommand command,
}) {
  StoreProvider.of<AppState>(context).dispatch(
    PerformModerationActionRequestedAction(
      command: command,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${command.actionType.label} completed.')),
        );
      },
      onError: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}
