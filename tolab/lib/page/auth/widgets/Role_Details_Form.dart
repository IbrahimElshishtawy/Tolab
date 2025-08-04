import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/cupertino.dart';
import 'package:tolab/page/auth/widgets/Role_Details_Cubit.dart';
import 'package:tolab/page/auth/widgets/role_details_state.dart';

class RoleDetailsForm extends StatefulWidget {
  final String role;
  const RoleDetailsForm({super.key, required this.role});

  @override
  State<RoleDetailsForm> createState() => _RoleDetailsFormState();
}

class _RoleDetailsFormState extends State<RoleDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nationalIdController = TextEditingController();

  String? selectedYear;
  String? selectedDepartment;

  final List<String> years = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year',
  ];

  List<String> getDepartments(String? year) {
    if (year == 'First Year' || year == 'Second Year') {
      return ['General', 'AI'];
    }
    return ['CS', 'IT', 'IS', 'AI', 'SE', 'General'];
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;

    return BlocProvider(
      create: (_) => RoleDetailsCubit(),
      child: BlocConsumer<RoleDetailsCubit, RoleDetailsState>(
        listener: (context, state) {
          if (state is RoleDetailsError) {
            _showMessage(state.message, isError: true);
          } else if (state is RoleDetailsSuccess) {
            _showMessage("تم الحفظ بنجاح ✅");
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (_) => false);
              }
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is RoleDetailsLoading;

          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: const Text("تفاصيل الحساب"),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: textColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text("الاسم (اختياري)", style: TextStyle(color: textColor)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "الاسم",
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("الرقم القومي", style: TextStyle(color: textColor)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nationalIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "الرقم القومي مطلوب";
                        } else if (val.length != 14) {
                          return "الرقم القومي يجب أن يكون 14 رقم";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "أدخل الرقم القومي",
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (widget.role == "Student") ...[
                      Text(
                        "السنة الدراسية",
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedYear,
                        items: years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedYear = val;
                            selectedDepartment = null;
                          });
                        },
                        validator: (val) =>
                            val == null ? "اختر السنة الدراسية" : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text("القسم", style: TextStyle(color: textColor)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        items: getDepartments(selectedYear)
                            .map(
                              (dep) => DropdownMenuItem(
                                value: dep,
                                child: Text(dep),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedDepartment = val),
                        validator: (val) => val == null ? "اختر القسم" : null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context
                                      .read<RoleDetailsCubit>()
                                      .saveRoleDetails(
                                        role: widget.role,
                                        nationalId: nationalIdController.text
                                            .trim(),
                                        name: nameController.text.trim(),
                                        year: selectedYear,
                                        department: selectedDepartment,
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CupertinoActivityIndicator()
                            : const Text(
                                "حفظ والمتابعة",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
