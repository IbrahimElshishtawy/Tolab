import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_button.dart';

Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Get.back(result: false),
        ),
        AppButton(label: confirmLabel, onPressed: () => Get.back(result: true)),
      ],
    ),
  );
  return result ?? false;
}
