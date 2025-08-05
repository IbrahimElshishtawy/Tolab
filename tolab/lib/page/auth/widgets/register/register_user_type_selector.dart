import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/page/auth/controllers/register/register_controller.dart';

class RegisterUserTypeSelector extends StatelessWidget {
  const RegisterUserTypeSelector({super.key});

  static const List<String> userTypes = ['طالب', 'معيد', 'دكتور'];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);
    return Column(
      children: [
        const Text(
          'نوع المستخدم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 15,
          children: userTypes.map((type) {
            final selected = controller.selectedUserType == type;
            return ChoiceChip(
              label: Text(type),
              selected: selected,
              onSelected: (_) => controller.setUserType(type),
              selectedColor: Colors.blue.shade300,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
