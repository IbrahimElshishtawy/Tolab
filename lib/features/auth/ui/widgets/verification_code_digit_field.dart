import 'package:flutter/material.dart';

import 'auth_input_decoration.dart';

class VerificationCodeDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const VerificationCodeDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: buildAuthInputDecoration(
          hintText: '',
          icon: Icons.password_rounded,
        ).copyWith(prefixIcon: null),
        onChanged: onChanged,
      ),
    );
  }
}
