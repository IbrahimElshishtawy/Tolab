import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Center(
            child: Text(
              "اللغة",
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 12),

          RadioListTile(
            value: "ar",
            groupValue: "ar",
            onChanged: null,
            title: Text("العربية"),
          ),
          RadioListTile(
            value: "en",
            groupValue: "ar",
            onChanged: null,
            title: Text("English"),
          ),
        ],
      ),
    );
  }

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
