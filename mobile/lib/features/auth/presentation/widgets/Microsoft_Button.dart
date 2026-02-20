// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MicrosoftButton extends StatelessWidget {
  /// يتم استدعاؤه بعد التأكد من صحة الإيميل
  final VoidCallback onPressed;

  /// حالة التحميل من Redux
  final bool isLoading;

  /// هل الزر متاح أم لا (مثلاً لو الإيميل فاضي)
  final bool isEnabled;

  const MicrosoftButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || !isEnabled;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: disabled
                ? LinearGradient(
                    colors: [Colors.grey.shade600, Colors.grey.shade500],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0B4DFF), Color(0xFF4F8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: disabled ? null : onPressed,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'تسجيل الدخول باستخدام Microsoft',
                        key: const ValueKey('content'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
