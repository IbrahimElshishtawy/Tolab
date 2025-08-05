// lib/ui/role_details_form.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tolab/core/config/User_Provider.dart';
import 'package:tolab/page/auth/widgets/role/Role_Details_Cubit.dart';
import 'package:tolab/page/auth/widgets/role/role_details_state.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? selectedYear, selectedDepartment;

  final years = ['First Year', 'Second Year', 'Third Year', 'Fourth Year'];

  List<String> getDepartments(String? year) {
    if (year == 'First Year' || year == 'Second Year') {
      return ['General', 'AI'];
    }
    return ['CS', 'IT', 'IS', 'AI', 'SE', 'General'];
  }

  void _showMessage(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, textAlign: TextAlign.center),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleDetailsCubit(),
      child: BlocConsumer<RoleDetailsCubit, RoleDetailsState>(
        listener: (context, state) async {
          if (state is RoleDetailsError) {
            _showMessage(state.message, isError: true);
          } else if (state is RoleDetailsSuccess) {
            _showMessage("تم الحفظ بنجاح ✅");
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              await context.read<UserProvider>().setUser(user);
            }
            await Future.delayed(const Duration(seconds: 1));
            if (mounted)
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (_) => false);
          }
        },
        builder: (context, state) {
          final isLoading = state is RoleDetailsLoading;
          return Scaffold(
            appBar: AppBar(
              title: const Text("تفاصيل الحساب"),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // نفس الحقول ...
                    ElevatedButton(
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
                      child: isLoading
                          ? const CupertinoActivityIndicator()
                          : const Text("حفظ والمتابعة"),
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
