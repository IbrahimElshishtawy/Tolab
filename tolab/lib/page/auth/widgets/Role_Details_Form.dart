import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  bool isLoading = false;

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

  Future<void> saveRoleDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage("لم يتم العثور على المستخدم", isError: true);
      setState(() => isLoading = false);
      return;
    }

    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'role': widget.role,
        'nationalId': nationalIdController.text.trim(),
      };

      if (nameController.text.trim().isNotEmpty) {
        userData['name'] = nameController.text.trim();
      }

      if (widget.role == "Student") {
        userData['year'] = selectedYear;
        userData['department'] = selectedDepartment;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      _showMessage("تم الحفظ بنجاح ✅");
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      });
    } catch (e) {
      _showMessage("حدث خطأ أثناء الحفظ ❌", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
              // الاسم (اختياري)
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

              // الرقم القومي (إجباري لكل الأدوار)
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

              // لو طالب → السنة والقسم
              if (widget.role == "Student") ...[
                Text("السنة الدراسية", style: TextStyle(color: textColor)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  items: years
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
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
                        (dep) => DropdownMenuItem(value: dep, child: Text(dep)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedDepartment = val),
                  validator: (val) => val == null ? "اختر القسم" : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveRoleDetails,
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
  }
}
