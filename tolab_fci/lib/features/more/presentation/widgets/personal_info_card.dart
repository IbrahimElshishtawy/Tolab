import 'package:flutter/material.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.end,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
              "المعلومات الشخصية",
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold),
            ),
          
          const SizedBox(height: 16),

          _infoRow(Icons.school_outlined, "الفرقة الرابعة"),
          _divider(),
          _infoRow(Icons.account_tree_outlined,
              "قسم نظم المعلومات (IS)"),
          _divider(),
          _infoRow(Icons.cake_outlined, "سكنن : 16"),
          _divider(),
          _infoRow(Icons.badge_outlined,
              "الرقم القومي : 30405010216414"),
          _divider(),
          _infoRow(Icons.email_outlined,
              "UG_2569874@icstanta.edu.eg"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xff1B4DB1),size: 24,),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 20),)),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 20);

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      );
}
